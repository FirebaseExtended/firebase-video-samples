//
// Color+Hex.swift
// Favourites
//
// Created by Peter Friese on 04.04.23.
// Copyright © 2023 Google LLC.
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

extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
    var hexNumber: UInt64 = 0
    if scanner.scanHexInt64(&hexNumber) {
      self.init(
        red: Double((hexNumber & 0xff0000) >> 16) / 255,
        green: Double((hexNumber & 0x00ff00) >> 8) / 255,
        blue: Double(hexNumber & 0x0000ff) / 255
      )
      return
    }
    self.init(red: 0, green: 0, blue: 0)
  }
}
