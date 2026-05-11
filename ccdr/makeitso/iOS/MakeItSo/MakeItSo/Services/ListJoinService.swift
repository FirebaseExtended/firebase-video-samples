import Foundation
import FirebaseAuth
import FirebaseFirestore

class ListJoinService {
  static let shared = ListJoinService()
  private let db = Firestore.firestore()
  
  func joinList(listId: String, shareToken: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
    }
    
    // Direct Firestore update using the 'joinToken' handshake required by security rules
    try await db.collection("lists").document(listId).updateData([
      "sharedWith": FieldValue.arrayUnion([user.uid]),
      "joinToken": shareToken
    ])
  }
}
