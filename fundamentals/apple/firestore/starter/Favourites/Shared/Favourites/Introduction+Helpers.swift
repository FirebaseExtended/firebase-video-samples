//
//  Introduction+Helpers.swift
//  Favourites (iOS)
//
//  Created by Peter Friese on 02.12.23.
//  Copyright © 2021 Google LLC. All rights reserved.
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
import SwiftUI
import LoremSwiftum

extension MyFavourite {
  static func randomNumber() -> Int {
    Int.random(in: 1...100)
  }

  static func randomColor() -> Color {
    Color(UIColor(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1),
      alpha: 1.0
    ))
  }

  static func randomMovie() -> String {
    Lorem.title
  }

  static var sampleFood = ["Pizza", "Pasta", "Sushi", "Burger", "Fried Green Asparagus"]
  static func randomFood() -> String {
    let index = Int.random(in: 0..<sampleFood.count)
    return sampleFood[index]
  }

  static var sampleCities = ["London", "New York City", "Hamburg", "San Francisco", "Sydney"]
  static func randomCity() -> String {
    let index = Int.random(in: 0..<sampleCities.count)
    return sampleCities[index]
  }

  static func randomUserID() -> String {
    Lorem.fullName.replacingOccurrences(of: " ", with: "").lowercased()
  }
}
