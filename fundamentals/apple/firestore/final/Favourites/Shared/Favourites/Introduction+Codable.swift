//
//  Introduction+Codable.swift
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

struct MyFavourite: Codable {
  var isPublic: Bool

  var number: Int
  var color: String
  var movie: String
  var food: String
  var city: String
  var userId: String
}

extension Introduction {
  func createDocumentCodable() {
    let favourite = MyFavourite(isPublic: true, number: 42, color: "#ffca28", movie: "Titanic", food: "Currywurst", city: "Berlin", userId: "peterfriese")

    do {
      try db.document("favourites/peterfriese").setData(from: favourite)
    }
    catch {
      print(error.localizedDescription)
    }
  }

  func fetchDocumentCodable() {
    Task {
      do {
        let favourite = try await db.document("favourites/peterfriese").getDocument(as: Favourite.self)
        print("Fetched and decoded favourite \(favourite)")
      }
      catch {
        print(error)
      }
    }
  }

  func fetchDocumentCodableAsync() {
    Task {
      do {
        let favourite = try await db.document("favourites/peterfriese").getDocument(as: MyFavourite.self)
        print("Decoded manually: \(favourite)")
      }
      catch {
        print(error.localizedDescription)
      }
    }
  }
}

