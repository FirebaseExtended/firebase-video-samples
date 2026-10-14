import 'package:myapp/data/model/recipe.dart';

class RecipeSchema {
  final String title;
  final String instructions;
  final List<String> ingredients;
  final String prepTime;
  final String cookTime;
  final String servings;
  final List<String> tags;

  const RecipeSchema({
    required this.title,
    required this.instructions,
    required this.ingredients,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.tags,
  });

  factory RecipeSchema.fromJson(Map<String, dynamic> json) {
    return RecipeSchema(
      title: json['title'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      prepTime: json['prepTime'] as String? ?? '',
      cookTime: json['cookTime'] as String? ?? '',
      servings: json['servings'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Recipe toRecipe({required String authorId, String? imageUri}) {
    return Recipe(
      title: title,
      instructions: instructions,
      ingredients: ingredients,
      authorId: authorId,
      tags: tags,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      imageUri: imageUri,
    );
  }
}
