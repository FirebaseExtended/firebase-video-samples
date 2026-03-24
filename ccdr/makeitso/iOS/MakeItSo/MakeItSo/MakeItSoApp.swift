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
}
