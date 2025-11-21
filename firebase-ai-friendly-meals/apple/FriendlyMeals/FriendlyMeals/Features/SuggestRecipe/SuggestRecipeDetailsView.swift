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

import MarkdownUI
import SwiftUI

struct SuggestRecipeDetailsView {
  @Environment(\.dismiss) private var dismiss

  let recipe: String
}

extension SuggestRecipeDetailsView: View {
  var body: some View {
    ScrollView {
      Markdown(recipe)
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .topLeading
        )
        .padding(.horizontal)
    }
  }
}

#Preview("Direct View") {
  SuggestRecipeDetailsView(
    recipe: """
      # Chicken Alfredo Pasta

      ## Ingredients
      - 8 oz fettuccine pasta
      - 2 boneless chicken breasts
      - 2 tbsp butter
      - 1 cup heavy cream
      - 1 cup grated parmesan cheese
      - Salt and pepper to taste

      ## Instructions
      1. Cook pasta according to package instructions
      2. Season and cook chicken until golden
      3. Slice chicken and set aside
      4. In the same pan, melt butter and add cream
      5. Stir in parmesan until smooth
      6. Add chicken and pasta to sauce
      7. Toss to coat and serve hot
      """)
}
