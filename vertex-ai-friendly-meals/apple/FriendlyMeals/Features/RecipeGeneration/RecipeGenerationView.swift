import SwiftUI
import PhotosUI

enum MealType: String, CaseIterable {
  case breakfast = "Breakfast"
  case lunch = "Lunch"
  case dinner = "Dinner"
  case dessert = "Dessert"
  case snack = "Snack"
}

@MainActor
struct RecipeGenerationView {
  @State private var ingredients = ""
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
  @State private var isAnalyzingImage = false
  
  let recipeService = RecipeGenerationService()
  
  private func generateRecipe() {
    guard !ingredients.isEmpty else { return }
    
    isGenerating = true
    Task {
      do {
        let recipe = try await recipeService.generateRecipe(
          from: ingredients,
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
            self.generatedImage = generatedImage // Keep the UIImage for the preview
            generatedRecipe = updatedRecipe // Store the recipe with the image data
            isShowingRecipe = true
            isGenerating = false
            isGeneratingImage = false
          }
        } else {
          await MainActor.run {
            generatedRecipe = recipe // Store the recipe without an image if generation failed
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
  
  private func analyzeSelectedImage(_ image: UIImage) {
    isAnalyzingImage = true
    
    Task {
      do {
        let detectedIngredients = try await recipeService.analyzeImage(image)
        await MainActor.run {
          ingredients = detectedIngredients
          isAnalyzingImage = false
        }
      } catch {
        print("Error analyzing image: \(error)")
        isAnalyzingImage = false
      }
    }
  }
  
  private func saveRecipe() {
    print("Saving recipe: \(generatedRecipe?.title ?? "")")
    showingSaveConfirmation = true
  }
}

extension RecipeGenerationView: View {
  var body: some View {
    NavigationStack(path: $navigationPath) {
      Form {
        Section("Ingredients") {
          ZStack(alignment: .topTrailing) {
            TextEditor(text: $ingredients)
              .frame(height: 100)
            
            Button {
              showingImageSource = true
            } label: {
              Image(systemName: "camera")
                .foregroundColor(.blue)
                .padding(8)
            }
            .buttonStyle(.borderless)
            .overlay {
              if isAnalyzingImage {
                ProgressView()
                  .progressViewStyle(.circular)
              }
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
          Button(action: generateRecipe) {
            HStack {
              Text("Generate Recipe")
                .frame(maxWidth: .infinity)
              
              if isGenerating {
                ProgressView()
                  .progressViewStyle(.circular)
              }
            }
          }
          .disabled(ingredients.isEmpty || isGenerating)
          
          if isGeneratingImage {
            HStack {
              Text("Generating image...")
              ProgressView()
                .progressViewStyle(.circular)
            }
          }
        }
      }
      .navigationTitle("Inspire Me")
      .sheet(isPresented: $showingImagePicker) {
        ImagePicker(selectedImage: $selectedImage, sourceType: imageSource) { image in
          showingImagePicker = false
          analyzeSelectedImage(image)
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

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: UIImage?
  let sourceType: UIImagePickerController.SourceType
  let onImageSelected: (UIImage) -> Void
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let image = info[.originalImage] as? UIImage {
        parent.selectedImage = image
        parent.onImageSelected(image)
      }
      picker.dismiss(animated: true)
    }
  }
}

#Preview {
  RecipeGenerationView()
}
