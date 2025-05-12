import SwiftUI
import NukeUI

@MainActor
struct RecipeRowView {
  let recipe: Recipe
}

extension RecipeRowView: View {
  var body: some View {
    HStack(alignment: .top) {
      LazyImage(url: recipe.imageURL) { state in
        if let image = state.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
          Color.gray
            .frame(width: 60, height: 60)
        }
      }

      VStack(alignment: .leading) {
        Text(recipe.title)
          .font(.headline)
        Text("\(recipe.cookingTimeInMinutes) minutes • \(recipe.cuisine.rawValue)")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  RecipeRowView(recipe: Recipe.mock)
}
