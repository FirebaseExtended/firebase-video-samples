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

  init() {
    let startTimerTool = FunctionDeclaration(
      name: "startTimer",
      description: "Starts a timer for the specified number of minutes",
      parameters: [
        "minutes": .integer(description: "The number of minutes to count down")
      ]
    )

    let getRemainingTimeTool = FunctionDeclaration(
      name: "getRemainingTime",
      description: "Gets the remaining time for the active timer in seconds",
      parameters: [:]
    )

    let model =
      FirebaseAI
      .firebaseAI(backend: .googleAI())
      .generativeModel(
        modelName: "gemini-2.5-flash",
        tools: [.functionDeclarations([startTimerTool, getRemainingTimeTool])],
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
    isTimerRunning = true

    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self = self else { return }

        if self.remainingTime > 0 {
          self.remainingTime -= 1
        } else {
          self.isTimerRunning = false
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

      var functionResponses = [FunctionResponsePart]()
      let functionCalls = response.functionCalls
      if !functionCalls.isEmpty {
        functionCalls.forEach { call in
          if call.name == "startTimer" {
            guard case .number(let minutesValue) = call.args["minutes"], let minutes = Int(exactly: minutesValue) else {
              print("Error: Invalid 'minutes' argument received: \(String(describing: call.args["minutes"]))")
              return // Skips this function call inside the forEach
            }
            startTimer(minutes: minutes)

            functionResponses.append(FunctionResponsePart(name: call.name, response: .init()))
          } else if call.name == "getRemainingTime" {
            let remainingSeconds = getRemainingTime()
            let response: JSONObject

            if let seconds = remainingSeconds {
              response = ["remainingSeconds": .number(Double(seconds))]
            } else {
              response = ["status": .string("No timer is currently running")]
            }

            functionResponses.append(FunctionResponsePart(name: call.name, response: response))
          }
        }
        let finalResponse = try await chat.sendMessage(
          [ModelContent(role: "function", parts: functionResponses)]
        )
        let responseMessage = DefaultMessage(content: finalResponse.text, participant: .other)
        messages.append(responseMessage)
        print(finalResponse)
      } else {
        let responseMessage = DefaultMessage(content: response.text, participant: .other)
        messages.append(responseMessage)
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
        if let text = chunk.text {
          // Only create the response message when we have actual text to display
          if responseIndex == nil {
            let responseMessage = DefaultMessage(content: text, participant: .other)
            messages.append(responseMessage)
            responseIndex = messages.count - 1
          } else {
            var message = messages[responseIndex!]
            message.content = (message.content ?? "") + text
            messages[responseIndex!] = message
          }
        }

        // Accumulate function calls from each chunk in the stream.
        accumulatedFunctionCalls.append(contentsOf: chunk.functionCalls)
      }

      // Check if the accumulated response contains function calls
      if !accumulatedFunctionCalls.isEmpty {
        var functionResponses = [FunctionResponsePart]()

        accumulatedFunctionCalls.forEach { call in
          if call.name == "startTimer" {
            guard case .number(let minutesValue) = call.args["minutes"], let minutes = Int(exactly: minutesValue) else {
              print("Error: Invalid 'minutes' argument received: \(String(describing: call.args["minutes"]))")
              return // Skips this function call inside the forEach
            }
            startTimer(minutes: minutes)

            functionResponses.append(FunctionResponsePart(name: call.name, response: .init()))
          } else if call.name == "getRemainingTime" {
            let remainingSeconds = getRemainingTime()
            let response: JSONObject

            if let seconds = remainingSeconds {
              response = ["remainingSeconds": .number(Double(seconds))]
            } else {
              response = ["status": .string("No timer is currently running")]
            }

            functionResponses.append(FunctionResponsePart(name: call.name, response: response))
          }
        }

        // Check if the first response is empty and remove it if so
        if responseIndex != nil, let content = messages[responseIndex!].content, content.isEmpty {
          messages.remove(at: responseIndex!)
        }

        // Send function responses back to the AI and stream the final response
        let finalResponseStream = try chat.sendMessageStream(
          [ModelContent(role: "function", parts: functionResponses)]
        )

        var finalIndex: Int?

        for try await chunk in finalResponseStream {
          if let text = chunk.text {
            if finalIndex == nil {
              // Create the final message only when we have text
              let finalMessage = DefaultMessage(content: text, participant: .other)
              messages.append(finalMessage)
              finalIndex = messages.count - 1
            } else {
              var message = messages[finalIndex!]
              message.content = (message.content ?? "") + text
              messages[finalIndex!] = message
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
}
