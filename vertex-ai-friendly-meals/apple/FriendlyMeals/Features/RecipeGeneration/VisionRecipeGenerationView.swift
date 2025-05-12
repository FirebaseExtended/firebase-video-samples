import SwiftUI
import PhotosUI

struct VisionRecipeGenerationView {
  @State private var selectedCuisine: Cuisine = .italian
  @State private var selectedMealType: MealType = .dinner
  @State private var numberOfServings = 4
  @State private var isGenerating = false
  @State private var generatedRecipe: Recipe?
  @State private var isShowingRecipe = false
  @State private var showingSaveConfirmation = false
  @State private var navigationPath = NavigationPath()
  @State private var showingImagePicker = false
  @State private var showingImageSource = false
  @State private var selectedImage: UIImage?
  @State private var imageSource: UIImagePickerController.SourceType = .camera
  @State private var generatedImage: UIImage?
  @State private var isGeneratingImage = false
  
  let recipeService = RecipeGenerationService()
  
  private func generateRecipeFromImage(_ image: UIImage) {
    isGenerating = true
    
    Task {
      do {
        let recipe = try await recipeService.generateRecipeFromImage(
          image,
          cuisine: selectedCuisine,
          mealType: selectedMealType,
          servings: numberOfServings
        )
        
        // Generate image after recipe
        isGeneratingImage = true
        if let generatedImage = try await recipeService.generateImage(for: recipe),
           let imageData = generatedImage.jpegData(compressionQuality: 0.8) {
          // Create a new recipe with the generated image
          var updatedRecipe = recipe
          updatedRecipe.generatedImage = imageData
          
          await MainActor.run {
            self.generatedImage = generatedImage
            generatedRecipe = updatedRecipe
            isShowingRecipe = true
            isGenerating = false
            isGeneratingImage = false
          }
        } else {
          await MainActor.run {
            generatedRecipe = recipe
            isShowingRecipe = true
            isGenerating = false
            isGeneratingImage = false
          }
        }
      } catch {
        print("Error generating recipe or image: \(error)")
        isGenerating = false
        isGeneratingImage = false
      }
    }
  }
  
  private func saveRecipe() {
    print("Saving recipe: \(generatedRecipe?.title ?? "")")
    showingSaveConfirmation = true
  }
}

extension VisionRecipeGenerationView: View {
  var body: some View {
    NavigationStack(path: $navigationPath) {
      Form {
        Section {
          if let selectedImage = selectedImage {
            Image(uiImage: selectedImage)
              .resizable()
              .scaledToFit()
              .frame(maxHeight: 200)
          }
          
          Button {
            showingImageSource = true
          } label: {
            HStack {
              Image(systemName: "camera")
              Text("Take or Select Photo")
            }
          }
        }
        
        Section {
          Picker("Cuisine type", selection: $selectedCuisine) {
            ForEach(Cuisine.allCases, id: \.self) { cuisine in
              Text(cuisine.rawValue.capitalized)
                .tag(cuisine)
            }
          }
          
          Picker("Meal type", selection: $selectedMealType) {
            ForEach(MealType.allCases, id: \.self) { mealType in
              Text(mealType.rawValue)
                .tag(mealType)
            }
          }
          
          Stepper("Servings: \(numberOfServings)", value: $numberOfServings, in: 1...12)
        }
        
        Section {
          Button(action: {
            if let image = selectedImage {
              generateRecipeFromImage(image)
            }
          }) {
            HStack {
              Text("Generate Recipe")
                .frame(maxWidth: .infinity)
              
              if isGenerating {
                ProgressView()
                  .progressViewStyle(.circular)
              }
            }
          }
          .disabled(selectedImage == nil || isGenerating)
          
          if isGeneratingImage {
            HStack {
              Text("Generating image...")
              ProgressView()
                .progressViewStyle(.circular)
            }
          }
        }
      }
      .navigationTitle("Vision Chef")
      .sheet(isPresented: $showingImagePicker) {
        ImagePicker(selectedImage: $selectedImage, sourceType: imageSource) { image in
          showingImagePicker = false
          selectedImage = image
        }
      }
      .confirmationDialog("Choose Image Source", isPresented: $showingImageSource) {
        Button("Camera") {
          imageSource = .camera
          showingImagePicker = true
        }
        Button("Photo Library") {
          imageSource = .photoLibrary
          showingImagePicker = true
        }
        Button("Cancel", role: .cancel) {}
      }
      .sheet(isPresented: $isShowingRecipe) {
        if let recipe = generatedRecipe {
          NavigationStack {
            RecipeDetailsView(recipe: recipe)
              .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                  Button("Close") {
                    isShowingRecipe = false
                  }
                }
                ToolbarItem(placement: .primaryAction) {
                  Button(action: saveRecipe) {
                    Image(systemName: "heart")
                  }
                }
              }
          }
          .alert("Recipe Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
          } message: {
            Text("The recipe has been added to your collection.")
          }
        }
      }
    }
  }
}

#Preview {
  VisionRecipeGenerationView()
}
