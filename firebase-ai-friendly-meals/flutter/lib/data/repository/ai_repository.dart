import 'dart:typed_data';
import 'package:firebase_ai_friendly_meals/data/datasource/ai_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@injectable
class AIRepository {
  final AIRemoteDataSource _aiRemoteDataSource;

  AIRepository(this._aiRemoteDataSource);

  Future<String> generateIngredients(Uint8List image) async {
    return _aiRemoteDataSource.generateIngredients(image);
  }

  Future<String> generateRecipe(String ingredients, String notes) async {
    return _aiRemoteDataSource.generateRecipe(ingredients, notes);
  }

  Future<Uint8List> generateRecipeImage(String recipe) async {
    return _aiRemoteDataSource.generateRecipeImage(recipe);
  }
}
