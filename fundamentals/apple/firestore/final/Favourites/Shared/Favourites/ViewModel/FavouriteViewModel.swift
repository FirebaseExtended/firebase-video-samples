//
// FavouritesViewModel.swift
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
import Combine
import FirebaseAnalytics
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FavouriteViewModel: ObservableObject {
  @Published var favourite = Favourite.empty

  @Published private var user: User?
  private var db = Firestore.firestore()
  private var cancellables = Set<AnyCancellable>()

  init() {
    registerAuthStateHandler()

    $user
      .compactMap { $0 }
      .sink { user in
        self.favourite.userId = user.uid
      }
      .store(in: &cancellables)
  }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.fetchFavourite()
      }
    }
  }

  func fetchFavourite() {
    guard let uid = user?.uid else { return }
    Task {
      do {
        self.favourite  = try await db.collection("favourites").document(uid).getDocument(as: Favourite.self)
      }
      catch {
        print(error.localizedDescription)
      }
    }
  }

  func saveFavourite() {
    guard let documentId = user?.uid else { return }

    do {
      try db.collection("favourites").document(documentId).setData(from: favourite)
    }
    catch {
      print(error.localizedDescription)
    }
  }
}
