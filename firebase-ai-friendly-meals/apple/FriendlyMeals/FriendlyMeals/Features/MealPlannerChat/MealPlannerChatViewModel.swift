//
// FriendlyMeals
//
// Copyright © 2025 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ConversationKit
import FirebaseAI
import SwiftUI

@Observable
@MainActor
class MealPlannerChatViewModel {
  var messages: [DefaultMessage] = []

  private var timer: Timer?
  private var remainingTime: Int = 0
  
  private var isTimerRunning: Bool {
    timer != nil
  }

  private var model: GenerativeModel
  private var chat: Chat

  private enum Tool: String, CaseIterable {
    case startTimer
    case getRemainingTime
    
    init?(_ value: String) {
      self.init(rawValue: value)
    }

    var declaration: FunctionDeclaration {
      switch self {
      case .startTimer:
        return FunctionDeclaration(
          name: rawValue,
          description: "Starts a timer for the specified number of minutes",
          parameters: [
            "minutes": .integer(description: "The number of minutes to count down")
          ]
        )
      case .getRemainingTime:
        return FunctionDeclaration(
          name: rawValue,
          description: "Gets the remaining time for the active timer in seconds",
          parameters: [:]
        )
      }
    }
  }

  init() {
    let model =
      FirebaseAI
      .firebaseAI(backend: .googleAI())
      .generativeModel(
        modelName: "gemini-2.5-flash",
        tools: [.functionDeclarations(Tool.allCases.map(\.declaration))],
        systemInstruction: ModelContent(
          role: "system",
          parts: "You are a meal planner. Please reply in the style of a spicy celebrity chef."
        ),
      )
    let chat = model.startChat(history: [
      ModelContent(
        role: "model",
        parts: "Greetings from the kitchen! What would you like to eat today?"
      )
    ])

    self.model = model
    self.chat = chat
  }
  
  func startTimer(minutes: Int) {
    timer?.invalidate()

    remainingTime = minutes * 60

    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self = self else { return }

        if self.remainingTime > 0 {
          self.remainingTime -= 1
        } else {
          self.timer?.invalidate()
          self.timer = nil
        }
      }
    }

    print("Starting timer for \(minutes) minutes")
  }

  func getRemainingTime() -> Int? {
    return isTimerRunning ? remainingTime : nil
  }

  func sendMessage(_ userMessage: any Message) async {
    guard let chatMessage = userMessage as? DefaultMessage else { return }
    messages.append(chatMessage)

    do {
      let response = try await chat.sendMessage(chatMessage.content ?? "")

      // 1. If the model provided text alongside the function call, display it.
      if let text = response.text, !text.isEmpty {
        let responseMessage = DefaultMessage(content: text, participant: .other)
        messages.append(responseMessage)
      }

      let functionCalls = response.functionCalls
      if !functionCalls.isEmpty {
        let functionResponses = functionCalls.compactMap { handleFunctionCall($0) }
        let finalResponse = try await chat.sendMessage(
          [ModelContent(role: "function", parts: functionResponses)]
        )
        let responseMessage = DefaultMessage(content: finalResponse.text, participant: .other)
        messages.append(responseMessage)
        print(finalResponse)
      }
    } catch {
      let errorMessage = DefaultMessage(
        content: error.localizedDescription,
        participant: .other,
        error: error
      )
      messages.append(errorMessage)
    }
  }

  func sendMessageStreaming(_ userMessage: any Message) async {
    guard let chatMessage = userMessage as? DefaultMessage else { return }
    messages.append(chatMessage)

    do {
      let responseStream = try chat.sendMessageStream(userMessage.content ?? "")
      var accumulatedFunctionCalls = [FunctionCallPart]()
      var responseIndex: Int?

      for try await chunk in responseStream {
        if let text = chunk.text, !text.isEmpty {
          if let index = responseIndex {
            messages[index].content?.append(text)
          } else {
            messages.append(DefaultMessage(content: text, participant: .other))
            responseIndex = messages.endIndex - 1
          }
        }

        // Accumulate function calls from each chunk in the stream.
        accumulatedFunctionCalls.append(contentsOf: chunk.functionCalls)
      }

      // Check if the accumulated response contains function calls
      if !accumulatedFunctionCalls.isEmpty {
        let functionResponses = accumulatedFunctionCalls.compactMap { handleFunctionCall($0) }

        // Send function responses back to the AI and stream the final response
        let finalResponseStream = try chat.sendMessageStream(
          [ModelContent(role: "function", parts: functionResponses)]
        )

        var finalIndex: Int?

        for try await chunk in finalResponseStream {
          if let text = chunk.text, !text.isEmpty {
            if let index = finalIndex {
              messages[index].content?.append(text)
            } else {
              messages.append(DefaultMessage(content: text, participant: .other))
              finalIndex = messages.endIndex - 1
            }
          }
        }
      }
    } catch {
      let errorMessage = DefaultMessage(
        content: error.localizedDescription,
        participant: .other,
        error: error
      )
      messages.append(errorMessage)
    }
  }
  
  private func handleFunctionCall(_ call: FunctionCallPart) -> FunctionResponsePart? {
    guard let tool = Tool(call.name) else { return nil }

    switch tool {
    case .startTimer:
      guard case .number(let minutesValue) = call.args["minutes"],
        let minutes = Int(exactly: minutesValue)
      else {
        print(
          "Error: Invalid 'minutes' argument received: \(String(describing: call.args["minutes"])))"
        )
        return nil
      }
      startTimer(minutes: minutes)
      return FunctionResponsePart(name: tool.rawValue, response: .init())

    case .getRemainingTime:
      let remainingSeconds = getRemainingTime()
      let response: JSONObject
      if let seconds = remainingSeconds {
        response = ["remainingSeconds": .number(Double(seconds))]
      } else {
        response = ["status": .string("No timer is currently running")]
      }
      return FunctionResponsePart(name: tool.rawValue, response: response)
    }
  }
}
