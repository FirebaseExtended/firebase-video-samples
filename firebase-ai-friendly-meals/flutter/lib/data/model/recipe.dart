class Recipe {
  final String title;
  final String instructions;
  final List<String> ingredients;
  final String authorId;
  final List<String> tags;
  final double averageRating;
  final String prepTime;
  final String cookTime;
  final String servings;
  final String? imageUri;

  const Recipe({
    this.title = '',
    this.instructions = '',
    this.ingredients = const [],
    this.authorId = '',
    this.tags = const [],
    this.averageRating = 0.0,
    this.prepTime = '',
    this.cookTime = '',
    this.servings = '',
    this.imageUri,
  });

  /// Matches @get:Exclude on averageRating in FriendlyMeals-Android Recipe.kt
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'instructions': instructions,
      'ingredients': ingredients,
      'authorId': authorId,
      'tags': tags,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'imageUri': imageUri,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> data, {double averageRating = 0.0}) {
    return Recipe(
      title: data['title'] as String? ?? '',
      instructions: data['instructions'] as String? ?? '',
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      authorId: data['authorId'] as String? ?? '',
      tags: (data['tags'] as List<dynamic>?)?.whereType<String>().toList() ??
          const [],
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? averageRating,
      prepTime: data['prepTime'] as String? ?? '',
      cookTime: data['cookTime'] as String? ?? '',
      servings: data['servings'] as String? ?? '',
      imageUri: data['imageUri'] as String?,
    );
  }

  Recipe copyWith({
    String? title,
    String? instructions,
    List<String>? ingredients,
    String? authorId,
    List<String>? tags,
    double? averageRating,
    String? prepTime,
    String? cookTime,
    String? servings,
    String? imageUri,
  }) {
    return Recipe(
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      ingredients: ingredients ?? this.ingredients,
      authorId: authorId ?? this.authorId,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      imageUri: imageUri ?? this.imageUri,
    );
  }
}

class RecipeListItem {
  final String id;
  final String title;
  final double averageRating;
  final String? imageUri;

  const RecipeListItem({
    this.id = '',
    this.title = '',
    this.averageRating = 0.0,
    this.imageUri,
  });
}
