//
//  GenerationConfig+Decodable.swift
//  FriendlyMeals
//
//  Created by Peter Friese on 26.09.25.
//

import Foundation
import FirebaseAI

extension ResponseModality: Decodable {
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

extension GenerationConfig: Decodable {
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
