import SwiftUI
import NukeUI

@MainActor
struct RecipeDetailsView {
  let recipe: Recipe
}

extension RecipeDetailsView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        if let generatedImage = recipe.generatedImage,
           let uiImage = UIImage(data: generatedImage) {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipped()
        } else {
          LazyImage(url: recipe.imageURL) { state in
            if let image = state.image {
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
            } else {
              ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            }
          }
        }

        VStack(alignment: .leading, spacing: 8) {
          Text(recipe.title)
            .font(.title)

          Text("\(recipe.cookingTimeInMinutes) minutes • \(recipe.cuisine.rawValue)")
            .foregroundColor(.secondary)

          Text(recipe.description)
            .padding(.top)

          Text("Ingredients")
            .font(.headline)
            .padding(.top)

          ForEach(recipe.ingredients, id: \.self) { ingredient in
            Text("• \(ingredient)")
          }

          Text("Instructions")
            .font(.headline)
            .padding(.top)

          ForEach(Array(recipe.instructions.enumerated()), id: \.element) { index, instruction in
            Text("\(index + 1). \(instruction)")
              .padding(.bottom, 4)
          }
        }
        .padding()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RecipeDetailsView(recipe: Recipe.mock)
  }
}
