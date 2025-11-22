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

class UsageTrackingService {
  static let shared = UsageTrackingService()

  private let userDefaults = UserDefaults.standard
  private let generationCountKey = "generationCount"
  private let lastGenerationDateKey = "lastGenerationDate"

  private init() {}

  func canGenerate() -> Bool {
    resetCountIfNeeded()
    let count = userDefaults.integer(forKey: generationCountKey)
    let maxImagesPerDay = RemoteConfigService.shared.maxImagesPerDay
    print("Checking if user can generate images. Count: \(count), Max: \(maxImagesPerDay)")
    return count < maxImagesPerDay
  }

  func incrementGenerationCount() {
    resetCountIfNeeded()
    let count = userDefaults.integer(forKey: generationCountKey)
    userDefaults.set(count + 1, forKey: generationCountKey)
  }

  private func resetCounter() {
    userDefaults.set(Date(), forKey: lastGenerationDateKey)
    userDefaults.set(0, forKey: generationCountKey)
  }

  private func resetCountIfNeeded() {
    guard let lastGenerationDate = userDefaults.object(forKey: lastGenerationDateKey) as? Date else {
      resetCounter()
      return
    }

    if !Calendar.current.isDateInToday(lastGenerationDate) {
      resetCounter()
    }
  }
}
