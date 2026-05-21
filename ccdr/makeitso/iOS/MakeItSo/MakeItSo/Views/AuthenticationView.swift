import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
  @Environment(\.dismiss) var dismiss
  @State private var email = ""
  @State private var password = ""

  enum AuthMode {
    case link, signIn, signUp
  }

  @State private var mode: AuthMode = .signIn
  @State private var showingCollisionAlert = false
  @State private var errorMessage = ""
  @State private var isLoading = false

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
          let isAnonymous = Auth.auth().currentUser?.isAnonymous ?? false
          if isAnonymous {
            switch mode {
            case .link:
              Button("Already have an account? Sign In") {
                mode = .signIn
              }
            case .signIn:
              VStack(alignment: .leading, spacing: 12) {
                Button("Don't have an account? Sign Up") {
                  mode = .signUp
                }
                Button("Link this session instead? Link Account") {
                  mode = .link
                }
              }
            case .signUp:
              VStack(alignment: .leading, spacing: 12) {
                Button("Already have an account? Sign In") {
                  mode = .signIn
                }
                Button("Link this session instead? Link Account") {
                  mode = .link
                }
              }
            }
          } else {
            Button(mode == .signUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
              mode = (mode == .signUp) ? .signIn : .signUp
            }
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
      .alert("Account Already Exists", isPresented: $showingCollisionAlert) {
        Button("Sign In Anyway", role: .destructive) {
          Task {
            isLoading = true
            errorMessage = ""
            do {
              try await AuthenticationService.shared.signIn(email: email, password: password)
              dismiss()
            } catch {
              errorMessage = error.localizedDescription
            }
            isLoading = false
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("There's already an account linked to that email. If you sign in anyway, you will lose all current data.")
      }
    }
  }

  private var navigationTitle: String {
    switch mode {
    case .link: return "Link Account"
    case .signIn: return "Sign In"
    case .signUp: return "Sign Up"
    }
  }

  private var buttonTitle: String {
    switch mode {
    case .link: return "Link Account"
    case .signIn: return "Sign In"
    case .signUp: return "Sign Up"
    }
  }

  private func performAction() async {
    isLoading = true
    errorMessage = ""
    let isAnonymous = Auth.auth().currentUser?.isAnonymous ?? false
    
    do {
      if mode == .signIn && isAnonymous {
        do {
          try await AuthenticationService.shared.linkAccount(email: email, password: password)
          dismiss()
        } catch {
          let nsError = error as NSError
          if nsError.domain == "FIRAuthErrorDomain" && (nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue || nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue || nsError.code == 17007 || nsError.code == 17025) {
            showingCollisionAlert = true
          } else {
            errorMessage = error.localizedDescription
          }
        }
      } else {
        switch mode {
        case .link:
          try await AuthenticationService.shared.linkAccount(email: email, password: password)
        case .signUp:
          try await AuthenticationService.shared.signUp(email: email, password: password)
        case .signIn:
          try await AuthenticationService.shared.signIn(email: email, password: password)
        }
        dismiss()
      }
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }
}

#Preview {
  AuthenticationView()
}
