import FirebaseAuth
import Foundation

class AuthenticationService {
  static let shared = AuthenticationService()

  private init() {}

  func signIn() {
    if Auth.auth().currentUser == nil {
      Auth.auth().signInAnonymously { authResult, error in
        if let error = error {
          print("Error signing in anonymously: \(error.localizedDescription)")
        } else {
          print("Successfully signed in anonymously!")
        }
      }
    }
  }
}
