import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
  @Environment(\.dismiss) var dismiss
  @State private var isShowingAuthView = false
  @State private var user = Auth.auth().currentUser

  var body: some View {
    NavigationStack {
      List {
        Section("User Info") {
          if let user = user {
            if user.isAnonymous {
              Text("Anonymous User")
              Text("ID: \(user.uid)")
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
              Text("Email: \(user.email ?? "No email")")
              Text("ID: \(user.uid)")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          } else {
            Text("Not logged in")
          }
        }

        Section {
          if let user = user, user.isAnonymous {
            Button("Sign In") {
              isShowingAuthView = true
            }
          } else if user == nil {
            Button("Sign In") {
              isShowingAuthView = true
            }
          }

          if let user = user, !user.isAnonymous {
            Button("Sign Out", role: .destructive) {
              do {
                try AuthenticationService.shared.signOut()
                dismiss()
                // Re-sign in anonymously after logout to keep the app working
                Task {
                  try await AuthenticationService.shared.signIn()
                }
              } catch {
                print("Error signing out: \(error.localizedDescription)")
              }
            }
          }
        }
      }
      .navigationTitle("Profile")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .sheet(isPresented: $isShowingAuthView) {
        AuthenticationView()
      }
      .onReceive(Auth.auth().authStateDidChange()) { _ in
        self.user = Auth.auth().currentUser
      }
    }
  }
}

extension Auth {
  func authStateDidChange() -> NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: NSNotification.Name("AuthStateDidChange"))
  }
}

// Note: To make the extension above work, we need to post a notification when auth state changes.
// Firebase doesn't post a standard notification, but we can add a listener in the app.
// For simplicity in this UI, we can also use a state variable passed from the parent or an observable object.

#Preview {
  UserProfileView()
}
