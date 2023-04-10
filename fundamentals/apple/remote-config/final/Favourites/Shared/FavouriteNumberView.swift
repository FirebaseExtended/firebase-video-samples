//
// FavouriteNumberView.swift
// Shared
//
// Created by Peter Friese on 05.07.22.
// Copyright © 2023 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseRemoteConfig
import FirebaseRemoteConfigSwift

class FavouriteNumberViewModel: ObservableObject {
  @Published var favouriteNumber = 42
  private var defaults = UserDefaults.standard
  private let favouriteNumberKey = "favouriteNumber"
  private var cancellables = Set<AnyCancellable>()

  init() {
    if let number = defaults.object(forKey: favouriteNumberKey) as? Int {
      favouriteNumber = number
    }
    $favouriteNumber
      .sink { number in
        self.defaults.set(number, forKey: self.favouriteNumberKey)
        Analytics.logEvent("stepper", parameters: ["value" : number])
      }
      .store(in: &cancellables)
  }

  func feelingLucky() {
    favouriteNumber = Int.random(in: 0..<100)
  }
}

struct ShadowConfiguration: Codable {
  var colorValue: String
  var offsetX: CGFloat
  var offsetY: CGFloat
  var radius: CGFloat
}

extension ShadowConfiguration {
  var color: Color {
    return Color(hex: colorValue)
  }
  static var `default` = ShadowConfiguration(colorValue: "#123456", offsetX: 4, offsetY: 4, radius: 8)
}

struct FavouriteNumberView: View {
  @StateObject var viewModel = FavouriteNumberViewModel()
  @RemoteConfigProperty(key: "enable_feeling_lucky",
                        fallback: false) var isFeelingLuckyEnabled

  @RemoteConfigProperty(key: "cardColor",
                        fallback: "#ff2d55") var cardColor

  @RemoteConfigProperty(key: "cardShadow",
                        fallback: .default) var cardShadow: ShadowConfiguration

  @RemoteConfigProperty(key: "maxValue",
                        fallback: 100) var maxValue

  @RemoteConfigProperty(key: "minValue",
                        fallback: 0) var minValue

  var body: some View {
    VStack {
      Text("What's your favourite number?")
        .font(.title)
        .multilineTextAlignment(.center)
      Spacer()
      Stepper(value: $viewModel.favouriteNumber, in: minValue...maxValue) {
        Text("\(viewModel.favouriteNumber)")
      }
      if isFeelingLuckyEnabled {
        Button(action: viewModel.feelingLucky) {
          Text("I'm feeling lucky")
        }
      }
    }
    .frame(maxHeight: 150)
    .foregroundColor(.white)
    .padding()
    #if os(iOS)
    .background(Color(hex: cardColor))
    #endif
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .shadow(color: cardShadow.color, radius: cardShadow.radius, x: cardShadow.offsetX, y: cardShadow.offsetY)
    .navigationTitle("Favourite Number")
    .analyticsScreen(name: "\(FavouriteNumberView.self)")
    .onAppear {
      Task {
        do {
          try await RemoteConfig.remoteConfig().fetchAndActivate()
        }
        catch {
          print(error.localizedDescription)
        }
      }
    }
    .onAppear() {
      RemoteConfig.remoteConfig().addOnConfigUpdateListener { configurationUpdate, error in
        guard let _ = configurationUpdate, error == nil else {
          print(error?.localizedDescription)
          return
        }
        RemoteConfig.remoteConfig().activate()
      }
    }
  }
}

struct FavouriteNumberView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      FavouriteNumberView()
    }
  }
}
