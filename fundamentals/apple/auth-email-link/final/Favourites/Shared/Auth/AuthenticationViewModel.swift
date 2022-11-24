//
// AuthenticationViewModel.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2022 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import FirebaseAuth

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}

enum EmailLinkStatus {
  case none
  case pending
}

//struct EmailLinkFlow {
//  var email: String? {
//    set {
//      UserDefaults.standard.set(newValue, forKey: "email-link")
//    }
//    get {
//      let email = UserDefaults.standard.string(forKey: "email-link") ?? nil
//      print(email)
//      return email
//    }
//  }
//
//  var isActive: Bool {
//    self.email != nil
//  }
//}

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var email = ""

  @Published var flow: AuthenticationFlow = .login

  @Published var isValid  = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage = ""
  @Published var user: User?
  @Published var displayName = ""

  @Published var emailLinkStatus = EmailLinkStatus.none

//  @Published var emailLinkFlow = EmailLinkFlow()

  init() {
    registerAuthStateHandler()
    retrieveEmailLinkDetails()

    $email
      .map { email in
        !email.isEmpty
      }
      .assign(to: &$isValid)
  }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.authenticationState = user == nil ? .unauthenticated : .authenticated
        self.displayName = user?.email ?? ""
      }
    }
  }

  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  private func wait() async {
    do {
      print("Wait")
      try await Task.sleep(nanoseconds: 1_000_000_000)
      print("Done")
    }
    catch {
      print(error.localizedDescription)
    }
  }

  func reset() {
    flow = .login
    email = ""
    resetEmailLinkDetails()
  }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
  func sendSignInLink() async {
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.url = URL(string: "https://favourites.page.link/email-link-login")
    actionCodeSettings.handleCodeInApp = true

    do {
      try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
      storeEmailLinkDetails()
    }
    catch {
      print(error.localizedDescription)
      errorMessage = error.localizedDescription
    }
  }

  func storeEmailLinkDetails() {
    UserDefaults.standard.set(email, forKey: "email-link")
    emailLinkStatus = .pending
  }

  func resetEmailLinkDetails() {
    UserDefaults.standard.removeObject(forKey: "email-link")
    emailLinkStatus = .none
  }

  func retrieveEmailLinkDetails() {
    if let emailLink = UserDefaults.standard.string(forKey: "email-link") {
      email = emailLink
      emailLinkStatus = .pending
    }
    else {
      emailLinkStatus = .none
    }
  }

  func handleSignInLink(_ url: URL) async {
    let link = url.absoluteString
    if Auth.auth().isSignIn(withEmailLink: link) {
      do {
        let result = try await Auth.auth().signIn(withEmail: email, link: link)
        let user = result.user
        print("User \(user.uid) signed in with email \(user.email ?? "(unknown)"). The email is \(user.isEmailVerified ? "" : "NOT") verified")
        emailLinkStatus = .none
      }
      catch {
        print(error.localizedDescription)
        self.errorMessage = error.localizedDescription
      }
    }
  }

  func signOut() {
    do {
      try Auth.auth().signOut()
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
    }
  }

  func deleteAccount() async -> Bool {
    do {
      try await user?.delete()
      return true
    }
    catch {
      errorMessage = error.localizedDescription
      return false
    }
  }
}
