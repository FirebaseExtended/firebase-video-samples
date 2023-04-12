//
// Favourite.swift
// Favourites (iOS)
//
// Created by Peter Friese on 24.11.22.
// Copyright © 2021 Google LLC. All rights reserved.
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

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Favourite: Codable, Identifiable {
  @DocumentID var id: String?
  var isPublic: Bool

  var number: Int
  var color: Color
  var movie: String
  var food: String
  var city: String

  var userId: String
}

extension Favourite {
  static var empty: Favourite {
    Favourite(isPublic: false, number: 7, color: .pink, movie: "", food: "", city: "", userId: "")
  }
}
