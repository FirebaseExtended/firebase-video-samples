import FirebaseAuth
import Foundation
import os

class AuthenticationService {
  static let shared = AuthenticationService()
  private let logger = Logger(subsystem: "com.google.firebase.example.MakeItSo", category: "Authentication")

  private init() {}

  func signIn() async throws {
    if Auth.auth().currentUser == nil {
      try await Auth.auth().signInAnonymously()
      logger.log("Successfully signed in anonymously!")
    } else {
      logger.log("Already signed in as \(Auth.auth().currentUser?.uid ?? "")")
    }
  }

  func signUp(email: String, password: String) async throws {
    try await Auth.auth().createUser(withEmail: email, password: password)
    logger.log("Successfully created user with email: \(email)")
  }

  func signIn(email: String, password: String) async throws {
    try await Auth.auth().signIn(withEmail: email, password: password)
    logger.log("Successfully signed in with email: \(email)")
  }

  func linkAccount(email: String, password: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user to link"])
    }
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await user.link(with: credential)
    logger.log("Successfully linked anonymous account to email: \(email)")
  }

  func signOut() throws {
    try Auth.auth().signOut()
    logger.log("Successfully signed out")
  }
}
