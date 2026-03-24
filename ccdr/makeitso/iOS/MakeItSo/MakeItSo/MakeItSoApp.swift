import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Task {
      do {
        try await AuthenticationService.shared.signIn()
      } catch {
        print("Error signing in: \(error.localizedDescription)")
      }
    }
    return true
  }
}

@main
struct MakeItSoApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ListsHomeView()
        .onOpenURL { url in
          handleIncomingURL(url)
        }
    }
  }

  private func handleIncomingURL(_ url: URL) {
    let pathComponents = url.pathComponents
    guard pathComponents.count >= 3, pathComponents[1] == "join" else { return }
    let listId = pathComponents[2]
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
          let token = components.queryItems?.first(where: { $0.name == "token" })?.value else { return }
    
    Task {
      do {
        try await ListJoinService.shared.joinList(listId: listId, shareToken: token)
        print("Successfully joined list \(listId)")
      } catch {
        print("Error joining list: \(error.localizedDescription)")
      }
    }
}

import FirebaseAuth

class ListJoinService {
  static let shared = ListJoinService()
  
  func joinList(listId: String, shareToken: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
    }
    
    let idToken = try await user.getIDToken()
    let url = URL(string: "https://us-central1-make-it-so-live-ccdr-01.cloudfunctions.net/joinList")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
    
    let body: [String: Any] = [
      "data": [
        "listId": listId,
        "shareToken": shareToken
      ]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
      let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
      throw NSError(domain: "CloudFunctions", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
    }
  }
}
