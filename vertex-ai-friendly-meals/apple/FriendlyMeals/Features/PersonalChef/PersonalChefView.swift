import SwiftUI
import ConversationKit

@MainActor
struct PersonalChefView {
  @State private var messages: [Message] = [
    Message(content: "Hello! I'm your personal chef assistant. I can help you find recipes, suggest meal ideas, and answer cooking questions. What would you like to cook today?", participant: .other)
  ]
  
  private func handleUserMessage(_ message: Message) {
    // Add loading state
    var responseMessage = Message(content: "Thinking...", participant: .other)
    messages.append(responseMessage)
    
    // Simulate chef's response
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      responseMessage.content = "I'd love to help you with that! Could you tell me about any dietary restrictions or preferences you have?"
      if let index = messages.firstIndex(where: { $0.id == responseMessage.id }) {
        messages[index] = responseMessage
      }
    }
  }
}

extension PersonalChefView: View {
  var body: some View {
    NavigationStack {
      ConversationView(messages: $messages)
        .onSendMessage { userMessage in
          handleUserMessage(userMessage)
        }
        .navigationTitle("Personal Chef")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
