//
// FriendlyMeals
//
// Copyright © 2025 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import FirebaseRemoteConfig
import FirebaseAI

fileprivate enum RemoteConfigKey: String {
  case maxImagesPerDay = "max_images_per_day"
  case modelName = "model_name"
  case generationConfig = "generation_config"
}

@Observable
class RemoteConfigService {
  static let shared = RemoteConfigService()

  var maxImagesPerDay: Int = 5
  var modelName: String = "gemini-2.0-flash-preview-image-generation"
  var generationConfig: GenerationConfig?

  private var remoteConfig: RemoteConfig

  private init() {
    remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 0
    remoteConfig.configSettings = settings
    setDefaults()
    listenForUpdates()
  }

  private func setDefaults() {
    remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
  }

  private func listenForUpdates() {
    remoteConfig.addOnConfigUpdateListener { [weak self] configUpdate, error in
      guard let self = self else { return }
      if let error = error {
        print("Error listening for config updates: \(error.localizedDescription)")
        return
      }

      print("Updated keys: \(String(describing: configUpdate?.updatedKeys))")
      Task { @MainActor in
        do {
          let changed = try await self.remoteConfig.activate()
          if changed {
            self.updateParameters()
          }
        }
        catch {
          print("Error activating config: \(error.localizedDescription)")
        }
      }
    }
  }

  private func updateParameters() {
    maxImagesPerDay = remoteConfig[RemoteConfigKey.maxImagesPerDay.rawValue].numberValue.intValue
    modelName = remoteConfig[RemoteConfigKey.modelName.rawValue].stringValue
    do {
      generationConfig = try remoteConfig[RemoteConfigKey.generationConfig.rawValue].decoded(asType: GenerationConfig.self)
    }
    catch {
      print("Error decoding generation config: \(error.localizedDescription)")
    }
  }

  func fetchConfig() async throws {
    try await remoteConfig.fetch()
    try await remoteConfig.activate()
    updateParameters()
  }
}
