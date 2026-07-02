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
        // Reset the internal event database on every launch to prevent MDB_MAP_FULL errors.
        clearFirebaseCache()
        
        let providerFactory = TripPlannerAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        // Stability hardening: Disable high-frequency logging
        // to prevent MDB_MAP_FULL storage errors during the live session.
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        
        FirebaseApp.configure()
    }
    
    private func clearFirebaseCache() {
        let fileManager = FileManager.default
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        
        let foldersToClear = ["google-sdks-events", "google-app-measurement"]
        
        for folder in foldersToClear {
            let folderUrl = cacheDir.appendingPathComponent(folder)
            if fileManager.fileExists(atPath: folderUrl.path) {
                try? fileManager.removeItem(at: folderUrl)
                print("DEBUG: Cleared internal Firebase storage at: \(folder)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            LandmarksView()
                .environment(modelData)
                .tint(.blue)
        }
    }
}
