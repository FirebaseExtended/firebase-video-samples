import FirebaseCore
import FirebaseAuth
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.google.firebase.example.MakeItSo", category: "DeepLink")

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Auth.auth().addStateDidChangeListener { _, user in
      NotificationCenter.default.post(name: NSNotification.Name("AuthStateDidChange"), object: nil)
    }
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
    logger.log("handleIncomingURL: Received URL: \(url.absoluteString)")
    
    var listId: String?
    var token: String?
    
    // Handle both https://.../join/ID and makeitso://join/ID
    if url.scheme == "https" {
      let pathComponents = url.pathComponents
      if pathComponents.count >= 3 && pathComponents[1] == "join" {
        listId = pathComponents[2]
      }
    } else if url.scheme == "makeitso" {
      if url.host == "join" {
        listId = url.pathComponents.dropFirst().first
      }
    }
    
    guard let listId = listId else {
      logger.error("handleIncomingURL: Could not parse listId from URL")
      return
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
          let extractedToken = components.queryItems?.first(where: { $0.name == "token" })?.value else {
      logger.error("handleIncomingURL: Could not parse token from URL")
      return
    }
    
    token = extractedToken
    
    logger.log("handleIncomingURL: Attempting to join list \(listId) with token \(token!)")
    
    Task {
      do {
        try await ListJoinService.shared.joinList(listId: listId, shareToken: token!)
        logger.log("handleIncomingURL: Successfully joined list \(listId)")
      } catch {
        logger.error("handleIncomingURL: Error joining list: \(error.localizedDescription)")
      }
    }
  }
}
