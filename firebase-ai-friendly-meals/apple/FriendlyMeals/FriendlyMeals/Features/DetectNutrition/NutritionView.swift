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
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(10)
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

          if viewModel.isLoading {
            Section(header: Text("Analyzing...")) {
              DisclosureGroup(isExpanded: $isThinkingExpanded) {
                Text(viewModel.currentThoughtStep?.description ?? "The model is preparing to analyze the image.")
              } label: {
                HStack {
                  Image(systemName: "arrow.clockwise")
                    .symbolEffect(.rotate)
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
            Section("Nutrition Facts") {
              HStack {
                Text("Carbohydrates")
                Spacer()
                Text(nutritionInfo.carbohydrates)
              }
              HStack {
                Text("Fat")
                Spacer()
                Text(nutritionInfo.fat)
              }
              HStack {
                Text("Protein")
                Spacer()
                Text(nutritionInfo.protein)
              }
              HStack {
                Text("Kilocalories")
                Spacer()
                Text(nutritionInfo.kilocalories)
              }
            }
          }
        }

        Button("Take Photo", systemImage: "camera") {
          isShowingCamera = true
        }
        .buttonStyle(.glassProminent)
        .padding()
      }
      .navigationTitle("Detect Nutrition")
      .sheet(isPresented: $isShowingCamera) {
        CameraView(isPresented: $isShowingCamera) { image in
          viewModel.processImage(image)
        }
      }
    }
  }
}

#Preview {
  NutritionView()
}


