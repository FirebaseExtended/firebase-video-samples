//
//  FavouritesListView.swift
//  Favourites (iOS)
//
//  Created by Peter Friese on 24.11.22.
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

import SwiftUI

struct FavouritesListView: View {
  @StateObject var viewModel = FavouritesListViewModel()

  var body: some View {
    NavigationStack {
      List(viewModel.favourites) { item in
        VStack(alignment: .leading) {
          Text("Number: \(item.number)")
          Text("Food: \(item.food)")
          Text("Movie: \(item.movie)")
          Text("City: \(item.city)")
        }
      }
      .navigationTitle("All Favourites")
      .onAppear {
        viewModel.subscribe()
      }
      .onDisappear {
        viewModel.unsubscribe()
      }
    }
  }
}

struct FavouritesListView_Previews: PreviewProvider {
  static var previews: some View {
    FavouritesListView()
  }
}
