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
import FirebaseAI

extension ResponseModality: @retroactive Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    switch rawValue {
    case "TEXT":
      self = .text
    case "IMAGE":
      self = .image
    default:
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid ResponseModality raw value '\(rawValue)'"
      )
    }
  }
}

extension GenerationConfig: @retroactive Decodable {
  private enum CodingKeys: String, CodingKey {
    case temperature
    case topP
    case topK
    case maxOutputTokens
    case responseModalities
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let temperature = try container.decodeIfPresent(Float.self, forKey: .temperature)
    let topP = try container.decodeIfPresent(Float.self, forKey: .topP)
    let topK = try container.decodeIfPresent(Int.self, forKey: .topK)
    let maxOutputTokens = try container.decodeIfPresent(Int.self, forKey: .maxOutputTokens)
    let responseModalities = try container.decodeIfPresent([ResponseModality].self, forKey: .responseModalities) ?? []

    self.init(temperature: temperature, topP: topP, topK: topK, maxOutputTokens: maxOutputTokens, responseModalities: responseModalities)
  }
}
