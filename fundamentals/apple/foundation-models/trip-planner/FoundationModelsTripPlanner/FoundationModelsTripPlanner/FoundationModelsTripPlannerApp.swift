/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main function for the FoundationModelsTripPlanner app.
*/

import SwiftUI
import FirebaseCore
import FirebaseAILogic
import FirebaseAppCheck

class TripPlannerAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    #if targetEnvironment(simulator)
    return AppCheckDebugProvider(app: app)
    #else
    return AppAttestProvider(app: app)
    #endif
  }
}

@main
struct FoundationModelsTripPlannerApp: App {
    private var modelData = ModelData.shared

    init() {
        let providerFactory = TripPlannerAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LandmarksView()
                .environment(modelData)
                .tint(.blue)
        }
    }
}
