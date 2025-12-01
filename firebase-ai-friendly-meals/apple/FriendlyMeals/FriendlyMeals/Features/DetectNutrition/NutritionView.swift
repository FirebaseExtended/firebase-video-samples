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

import SwiftUI

struct NutritionView: View {
  @State private var isShowingCamera = false
  @State private var viewModel = NutritionViewModel()
  @State private var isThinkingExpanded = true

  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottomTrailing) {
        Form {
          Section {
            if let image = viewModel.selectedImage {
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .cornerRadius(10)
                .clipped()
            } else {
              Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .cornerRadius(10)
                .overlay(
                  Image(systemName: "camera")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                )
            }
          }
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
          
          if viewModel.hasAnalysisStarted {
            Section(header: Text("Analysis Progress")) {
              DisclosureGroup(isExpanded: $isThinkingExpanded) {
                Text(viewModel.currentThoughtStep?.description ?? "The model is preparing to analyze the image.")
              } label: {
                HStack {
                  if viewModel.isLoading {
                    Image(systemName: "arrow.clockwise")
                      .symbolEffect(.rotate, options: .repeating)
                  } else if viewModel.nutritionInfo != nil {
                    Image(systemName: "checkmark.circle.fill")
                      .foregroundColor(.green)
                  } else if viewModel.errorMessage != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                      .foregroundColor(.red)
                  }
                  Text(viewModel.currentThoughtStep?.headline ?? "Thinking...")
                    .font(.headline)
                }
              }
            }
          }
          
          if let errorMessage = viewModel.errorMessage {
            Section {
              Text("Error: \(errorMessage)")
                .foregroundColor(.red)
            }
          }
          
          if let nutritionInfo = viewModel.nutritionInfo {
            Section("Detected Dish") {
              Text(nutritionInfo.detectedDish)
            }
            
            Section("Nutrition Facts") {
              ForEach(nutritionInfo.facts, id: \.label) { fact in
                LabeledContent {
                  Text(fact.value)
                } label: {
                  Label(fact.label, systemImage: fact.systemImage)
                }
              }
            }
          }
        }
        .safeAreaInset(edge: .bottom) {
          Spacer().frame(height: 80)
        }
        
        Button(action: {
          isShowingCamera = true
        }) {
          Image(systemName: "viewfinder")
            .padding(8)
            .background(Circle().fill(Color.accentColor.opacity(0.8)))
            .foregroundColor(.white)
        }
        .buttonStyle(.glassProminent)
        .clipShape(Circle())
        .padding()
      }
      .navigationTitle("Detect Nutrition")
      .sheet(isPresented: $isShowingCamera) {
        CameraView(isPresented: $isShowingCamera) { image in
          viewModel.processImage(image)
        }
        .ignoresSafeArea()
      }
      .onChange(of: viewModel.isLoading) {
        if viewModel.isLoading {
          isThinkingExpanded = true
        }
      }
      .onChange(of: viewModel.nutritionInfo) { _, newValue in
        if newValue != nil {
          withAnimation {
            isThinkingExpanded = false
          }
        }
      }
    }
  }
}

#Preview {
  NutritionView()
}
