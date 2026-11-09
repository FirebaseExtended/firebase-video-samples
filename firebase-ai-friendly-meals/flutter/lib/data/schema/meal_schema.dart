class MealSchema {
  final String protein;
  final String fat;
  final String carbs;
  final String sugar;
  final List<String> ingredients;

  const MealSchema({
    this.protein = '0g',
    this.fat = '0g',
    this.carbs = '0g',
    this.sugar = '0g',
    this.ingredients = const [],
  });

  factory MealSchema.fromJson(Map<String, dynamic> json) {
    return MealSchema(
      protein: json['protein'] as String? ?? '0g',
      fat: json['fat'] as String? ?? '0g',
      carbs: json['carbs'] as String? ?? '0g',
      sugar: json['sugar'] as String? ?? '0g',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
