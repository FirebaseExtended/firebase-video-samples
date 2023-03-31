//
// FavouriteNumberView.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2022 Google LLC.
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

import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift

struct FavouriteNumberView: View {
  @StateObject var viewModel = FavouriteNumberViewModel()
  var body: some View {
    VStack {
      Text("What's your favourite number?")
        .font(.title)
        .multilineTextAlignment(.center)
      Spacer()
      Stepper(value: $viewModel.favourite.number, in: 0...100) {
        Text("\(viewModel.favourite.number)")
      } onEditingChanged: { changed in
        viewModel.saveFavourite()
      }
    }
    .frame(maxHeight: 150)
    .foregroundColor(.white)
    .padding()
    #if os(iOS)
    .background(Color(UIColor.systemPink))
    #endif
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .shadow(radius: 8)
    .navigationTitle("Favourite Number")
    .onAppear {
      viewModel.fetchFavourite()
    }
    .onDisappear {
      viewModel.saveFavourite()
    }
    .analyticsScreen(name: "\(FavouriteNumberView.self)")
  }
}

struct FavouriteNumberView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      FavouriteNumberView()
    }
  }
}
