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
//    http://www.apache.org/licenses/LICENSE-2.0
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

struct MyFavouritesView: View {
  @StateObject var viewModel = FavouriteViewModel()
  @ObservedObject private var authenticationViewModel = AuthenticationViewModel()
  @State private var presentingProfileScreen = false

  enum Field {
    case color
    case movie
    case food
    case city
  }

  @FocusState private var focusedField: Field?

  var body: some View {
    NavigationStack {
      Form {
        Section("What's your favourite number?") {
          Stepper(value: $viewModel.favourite.number, in: 0...100) {
            Text("\(viewModel.favourite.number)")
          }
        }

        Section("What's your favourite color?") {
          ColorPicker(selection: $viewModel.favourite.color) {
            Text("\(viewModel.favourite.color.toHex ?? "")")
          }
        }

        Section("What's your favourite movie?") {
          TextField("", text: $viewModel.favourite.movie)
            .focused($focusedField, equals: .movie)
        }

        Section("What's your favourite food?") {
          TextField("", text: $viewModel.favourite.food)
            .focused($focusedField, equals: .food)
        }

        Section("What's your favourite city?") {
          TextField("", text: $viewModel.favourite.city)
            .focused($focusedField, equals: .city)
        }

        Section("Make your favourites public?") {
          Toggle(isOn: $viewModel.favourite.isPublic) {
            Text("\(viewModel.favourite.isPublic ? "Yes" : "No")")
          }
        }

        Button {
          viewModel.saveFavourite()
          focusedField = nil
        } label: {
          Text("Save")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.blue)
        .listRowInsets(EdgeInsets())
      }
      .onAppear {
        viewModel.fetchFavourite()
      }
      .onDisappear {
        viewModel.saveFavourite()
      }
      .onSubmit {
        switch focusedField {
        case .movie:
          focusedField = .food
        case .food:
          focusedField = .city
        case .city:
          focusedField = .none
        default:
          print("Default")
        }
      }
      .listStyle(.plain)
      .toolbar {
        Button(action: { presentingProfileScreen.toggle() }) {
          Image(systemName: "person.circle")
        }
      }
      .sheet(isPresented: $presentingProfileScreen) {
        NavigationView {
          UserProfileView()
            .environmentObject(authenticationViewModel)
        }
      }
      .navigationTitle("My Favourites")
      .analyticsScreen(name: "\(MyFavouritesView.self)")
    }
  }
}

struct BlueButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
        .font(.headline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .foregroundColor(configuration.isPressed ? Color.white.opacity(0.5) : Color.white)
        .background(configuration.isPressed ? Color.blue.opacity(0.5) : Color.blue)
  }
}
extension ButtonStyle where Self == BlueButtonStyle {
  static var blue: BlueButtonStyle { BlueButtonStyle() }
}

  struct FavouriteNumberView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        MyFavouritesView()
      }
    }
  }
