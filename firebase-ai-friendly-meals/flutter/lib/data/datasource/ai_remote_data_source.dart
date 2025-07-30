import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:injectable/injectable.dart';

@injectable
class AIRemoteDataSource {
  final GenerativeModel _generativeModel;
  final ImagenModel _imagenModel;

  AIRemoteDataSource({
    required GenerativeModel generativeModel,
    required ImagenModel imagenModel,
  }) : _generativeModel = generativeModel,
       _imagenModel = imagenModel;

  Future<String> generateIngredients(Uint8List image) async {
    // TODO: Call generative model with multimodal prompt to extract ingredients from image
    return '';
  }

  Future<String> generateRecipe(String ingredients, String notes) async {
    // TODO: call generative model to generate recipe
    return '';
  }

  Future<Uint8List> generateRecipeImage(String recipe) async {
    // TODO: Call Imagen model to generate recipe photo
    return Uint8List(0);
  }
}
