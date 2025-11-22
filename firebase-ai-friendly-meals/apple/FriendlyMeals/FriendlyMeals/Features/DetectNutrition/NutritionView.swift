import SwiftUI

struct NutritionView: View {
  @State private var isShowingCamera = false
  @State private var viewModel = NutritionViewModel()

  var body: some View {
    NavigationView {
      VStack {
        if let image = viewModel.selectedImage {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 300)
            .cornerRadius(10)
            .padding()
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(maxHeight: 300)
            .cornerRadius(10)
            .padding()
            .overlay(
              Text("Take a photo of your meal")
                .foregroundColor(.gray)
            )
        }

        Button("Take Photo") {
          isShowingCamera = true
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom)

        if viewModel.isLoading {
          ProgressView("Analyzing nutrition...")
            .padding()
        } else if let errorMessage = viewModel.errorMessage {
          Text("Error: \(errorMessage)")
            .foregroundColor(.red)
            .padding()
        } else if let nutritionInfo = viewModel.nutritionInfo {
          Form {
            Section("Nutrition Facts") {
              HStack {
                Text("Carbohydrates")
                Spacer()
                Text("\(nutritionInfo.carbohydrates)")
              }
              HStack {
                Text("Fat")
                Spacer()
                Text("\(nutritionInfo.fat)")
              }
              HStack {
                Text("Protein")
                Spacer()
                Text("\(nutritionInfo.protein)")
              }
              HStack {
                Text("Kilocalories")
                Spacer()
                Text("\(nutritionInfo.kilocalories)")
              }
            }
          }
        }
        Spacer()
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

struct NutritionView_Previews: PreviewProvider {
  static var previews: some View {
    NutritionView()
  }
}
