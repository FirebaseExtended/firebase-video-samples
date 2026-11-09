import 'dart:typed_data';

import '../datasource/ai_remote_datasource.dart';
import '../schema/meal_schema.dart';
import '../schema/recipe_schema.dart';
import '../schema/store_schema.dart';

class AIRepository {
  AIRepository(this._aiRemoteDataSource);

  final AIRemoteDataSource _aiRemoteDataSource;

  Future<String> generateIngredients(Uint8List imageBytes) {
    return _aiRemoteDataSource.generateIngredients(imageBytes);
  }

  Future<List<StoreSchema>> findStores({
    required List<String> ingredients,
    required double latitude,
    required double longitude,
    required String currentTime,
    required String dayOfWeek,
  }) {
    return _aiRemoteDataSource.findStores(
      ingredients: ingredients,
      latitude: latitude,
      longitude: longitude,
      currentTime: currentTime,
      dayOfWeek: dayOfWeek,
    );
  }

  Future<RecipeSchema?> generateRecipe(String ingredients, String notes) {
    return _aiRemoteDataSource.generateRecipe(ingredients, notes);
  }

  Future<Uint8List?> generateRecipePhoto(String recipeTitle) {
    return _aiRemoteDataSource.generateRecipePhoto(recipeTitle);
  }

  Future<MealSchema?> scanMeal(String imageData) {
    return _aiRemoteDataSource.scanMeal(imageData);
  }

  Future<String> craftRecipePairing(
    String dishTitle,
    List<String> ingredients,
  ) {
    return _aiRemoteDataSource.craftRecipePairing(dishTitle, ingredients);
  }

  Future<Uint8List?> generateSpeech(String? text) {
    return _aiRemoteDataSource.generateSpeech(text);
  }

  Future<void> loadOnDeviceModel() {
    return _aiRemoteDataSource.loadOnDeviceModel();
  }
}
