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

  private var model: GenerativeModel
  private var chat: Chat

  init() {
    let model =
      FirebaseAI
      .firebaseAI(backend: .googleAI())
      .generativeModel(
        modelName: "gemini-2.5-flash",
        systemInstruction: ModelContent(
          role: "system",
          parts: "You are a meal planner. Please reply in the style of Gordon Ramsay."
        )
      )
    let chat = model.startChat(history:
                                [ModelContent(role: "model",
                                              parts: "Greetings from the kitchen! What would you like to eat today?")])

    self.model = model
    self.chat = chat
  }

  // If you want to use non-streaming chat, use this method
  func sendMessageNonStreaming(_ userMessage: DefaultMessage) async {
    messages.append(userMessage)
    
    do {
      let response = try await chat.sendMessage(userMessage.content ?? "")
      let responseMessage = DefaultMessage(content: response.text, participant: .other)
      messages.append(responseMessage)
    } catch {
      let errorMessage = DefaultMessage(content:  error.localizedDescription,
                                        participant: .other)
      messages.append(errorMessage)
    }
  }
  
  func sendMessage(_ userMessage: any Message) async {
    if let defaultMessage = userMessage as? DefaultMessage {
      messages.append(defaultMessage)
    }
    
    let responseMessage = DefaultMessage(content: "", participant: .other)
    messages.append(responseMessage)
    let responseIndex = messages.count - 1
    
    do {
      let responseStream = try chat.sendMessageStream(userMessage.content ?? "")
      for try await chunk in responseStream {
        if let text = chunk.text {
          let currentContent = messages[responseIndex].content ?? ""
          messages[responseIndex] = DefaultMessage(content: currentContent + text, participant: .other)
        }
      }
    }
    catch {
      messages[responseIndex] = DefaultMessage(content: error.localizedDescription, participant: .other)
    }
  }
}
