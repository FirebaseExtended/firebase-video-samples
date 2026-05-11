import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
  @Environment(\.dismiss) var dismiss
  @State private var email = ""
  @State private var password = ""
  @State private var isSignUp = false
  @State private var errorMessage = ""
  @State private var isLoading = false

  var isLinking: Bool {
    Auth.auth().currentUser?.isAnonymous ?? false
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
          SecureField("Password", text: $password)
        } footer: {
          if !errorMessage.isEmpty {
            Text(errorMessage)
              .foregroundColor(.red)
          }
        }

        Section {
          Button {
            Task {
              await performAction()
            }
          } label: {
            if isLoading {
              ProgressView()
            } else {
              Text(buttonTitle)
            }
          }
          .disabled(email.isEmpty || password.isEmpty || isLoading)
        }

        Section {
          Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
            isSignUp.toggle()
          }
        }
      }
      .navigationTitle(navigationTitle)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }

  private var navigationTitle: String {
    if isLinking {
      return "Link Account"
    }
    return isSignUp ? "Sign Up" : "Sign In"
  }

  private var buttonTitle: String {
    if isLinking {
      return "Link Account"
    }
    return isSignUp ? "Sign Up" : "Sign In"
  }

  private func performAction() async {
    isLoading = true
    errorMessage = ""
    do {
      if isLinking {
        try await AuthenticationService.shared.linkAccount(email: email, password: password)
      } else if isSignUp {
        try await AuthenticationService.shared.signUp(email: email, password: password)
      } else {
        try await AuthenticationService.shared.signIn(email: email, password: password)
      }
      dismiss()
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }
}

#Preview {
  AuthenticationView()
}
