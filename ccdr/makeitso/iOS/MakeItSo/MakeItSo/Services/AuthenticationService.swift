import FirebaseAuth
import Foundation

class AuthenticationService {
  static let shared = AuthenticationService()

  private init() {}

  func signIn() async throws {
    if Auth.auth().currentUser == nil {
      try await Auth.auth().signInAnonymously()
      print("Successfully signed in anonymously!")
    }
  }
}
