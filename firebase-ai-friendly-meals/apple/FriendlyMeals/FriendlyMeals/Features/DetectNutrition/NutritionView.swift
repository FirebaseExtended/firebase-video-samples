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
          
          if viewModel.isLoading || viewModel.nutritionInfo != nil || viewModel.errorMessage != nil {
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
              let facts = [
                ("Carbohydrates", nutritionInfo.carbohydrates),
                ("Fat", nutritionInfo.fat),
                ("Protein", nutritionInfo.protein),
                ("Kilocalories", nutritionInfo.kilocalories),
              ]
              ForEach(facts, id: \.0) { label, value in
                HStack {
                  Text(label)
                  Spacer()
                  Text(value)
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
