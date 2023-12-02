//
// FavouritesApp.swift
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
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
//   Auth.auth().useEmulator(withHost:"localhost", port:9099)
    return true
  }
}

@main
struct FavouritesApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  @StateObject var introduction = Introduction()

  var body: some Scene {
    WindowGroup {
      NavigationView {
        AuthenticatedView {
          Image(systemName: "number.circle.fill")
            .resizable()
            .frame(width: 100 , height: 100)
            .foregroundColor(Color(.systemPink))
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .clipped()
            .padding(4)
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
          Text("Welcome to Favourites!")
            .font(.title)
          Text("You need to be logged in to use this app.")
        } content: {
          RootContentView()
        }
      }
      .onAppear {
//        introduction.demo()
      }
    }
  }
}
