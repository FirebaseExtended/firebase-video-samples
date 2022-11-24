//
// Introduction.swift
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

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MyFavourite: Codable {
  var isPublic: Bool

  var number: Int
  var color: String
  var movie: String
  var food: String
  var city: String
}


class Introduction: ObservableObject {
  var db = Firestore.firestore()

  func demo() {
    createDocument()
    updateDocument()
    updateDocument2()
    addDocument()
    addDocumentAsync()
    fetchDocument()
    createDocumentCodable()
    fetchDocumentCodable()
  }

}

extension Introduction {
  func createDocumentCodable() {
    let favourite = MyFavourite(isPublic: true, number: 42, color: "#ffca28", movie: "Titanic", food: "Currywurst", city: "Berlin")

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
}

extension Introduction {
  func createDocument() {
    db.document("favourites/peterfriese").setData([
      "number": 42,
      "color": "#ffffff",
      "movie": "Back to the Future",
      "food": "Sushi",
      "city": "London"
    ])
  }

  func updateDocument() {
    db.collection("favourites").document("peterfriese").setData([
      "city": "Hamburg"
    ], merge: true)
  }

  func updateDocument2() {
    db.collection("favourites").document("peterfriese").updateData([
      "food": "Pizza"
    ])
  }

  func addDocument() {
    db.collection("favourites").addDocument(data: [
      "number": 17,
      "color": "#efefefe",
      "movie": "The Matrix",
      "food": "Pizza",
      "city": "New York City"
    ])
  }

  func addDocumentAsync() {
    Task {
      do {
        let ref = try await db.collection("favourites").addDocument(data: [
          "number": 23,
          "color": "#aaaaaa",
          "movie": "The man from UNCLE",
          "food": "Pasta",
          "city": "Sydney"
        ])
        print("Document added with ID \(ref.documentID)")
      }
      catch {
        print(error.localizedDescription)
      }
    }
  }

  func fetchDocument() {
    db.document("favourites/peterfriese").getDocument { documentSnapshot, error in
      if let documentSnapshot, documentSnapshot.exists {
        if let data = documentSnapshot.data() {
          print(data)
          let favourite = MyFavourite(isPublic: data["isPublic"] as? Bool ?? false,
                                    number: data["number"] as? Int ?? 0,
                                    color: data["color"] as? String ?? "",
                                    movie: data["movie"] as? String ?? "",
                                    food: data["food"] as? String ?? "",
                                    city: data["city"] as? String ?? "")
          print("Decoded manually: \(favourite)")

        }
      }
    }
  }
}
