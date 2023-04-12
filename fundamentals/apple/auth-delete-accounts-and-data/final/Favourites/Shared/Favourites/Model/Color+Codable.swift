//
// Color+Codable.swift
// Favourites (iOS)
//
// Created by Peter Friese on 24.11.22.
// Copyright © 2021 Google LLC.
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

import SwiftUI

// Inspired by https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift
// Make Color codable. This includes support for transparency.
// See https://www.digitalocean.com/community/tutorials/css-hex-code-colors-alpha-values
extension Color: Codable {
  init(hex: String) {
    let rgba = hex.toRGBA()

    self.init(.sRGB,
              red: Double(rgba.r),
              green: Double(rgba.g),
              blue: Double(rgba.b),
              opacity: Double(rgba.alpha))
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let hex = try container.decode(String.self)

    let rgba = hex.toRGBA()

    self.init(.sRGB,
              red: Double(rgba.r),
              green: Double(rgba.g),
              blue: Double(rgba.b),
              opacity: Double(rgba.alpha))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(toHex)
  }

  var toHex: String? {
    return toHex()
  }

  func toHex(alpha: Bool = false) -> String? {
    guard let components = cgColor?.components, components.count >= 3 else {
      return nil
    }

    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    var a = Float(1.0)

    if components.count >= 4 {
      a = Float(components[3])
    }

    if alpha {
      return String(format: "#%02lX%02lX%02lX%02lX",
                    lroundf(r * 255),
                    lroundf(g * 255),
                    lroundf(b * 255),
                    lroundf(a * 255)).lowercased()
    }
    else {
      return String(format: "#%02lX%02lX%02lX",
                    lroundf(r * 255),
                    lroundf(g * 255),
                    lroundf(b * 255)).lowercased()
    }
  }
}

extension String {
  func toRGBA() -> (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
    var hexSanitized = self.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0

    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0

    let length = hexSanitized.count

    Scanner(string: hexSanitized).scanHexInt64(&rgb)

    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0
    }
    else if length == 8 {
      r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x000000FF) / 255.0
    }

    return (r, g, b, a)
  }
}
