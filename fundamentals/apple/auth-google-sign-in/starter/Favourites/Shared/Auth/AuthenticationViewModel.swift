//
// AuthenticationViewModel.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2021 Google LLC. All rights reserved.
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
import FirebaseCore
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

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var confirmPassword: String = ""

  @Published var flow: AuthenticationFlow = .login

  @Published var isValid: Bool  = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage: String = ""
  @Published var user: User?
  @Published var displayName: String = ""

  init() {
    registerAuthStateHandler()

    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
        ? !(email.isEmpty || password.isEmpty)
        : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
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
    catch { }
  }

  func reset() {
    flow = .login
    email = ""
    password = ""
    confirmPassword = ""
  }
}

// MARK: - Sign in with Email and Password

extension AuthenticationViewModel {
  func signInWithEmailPassword() async -> Bool {
    authenticationState = .authenticating
    do {
      try await Auth.auth().signIn(withEmail: self.email, password: self.password)
      return true
    }
    catch  {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signUpWithEmailPassword() async -> Bool {
    authenticationState = .authenticating
    do  {
      try await Auth.auth().createUser(withEmail: email, password: password)
      return true
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
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

// MARK: - Google Sign-In

extension AuthenticationViewModel {
  func signInWithGoogle() async -> Bool {
    return false  // replace this with the implementation
  }
}
