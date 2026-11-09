import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import '../schema/meal_schema.dart';
import '../schema/recipe_schema.dart';
import '../schema/store_schema.dart';
import 'remote_config_service.dart';

class AIRemoteDataSource {
  AIRemoteDataSource({
    FirebaseAI? aiModel,
    required RemoteConfigService remoteConfig,
  })  : _aiModel = aiModel ?? FirebaseAI.googleAI(),
        _remoteConfig = remoteConfig;

  final FirebaseAI _aiModel;
  final RemoteConfigService _remoteConfig;

  // Remote Config Keys
  static const String generateRecipeKey = 'generate_recipe';
  static const String generateRecipePhotoGeminiKey =
      'generate_recipe_photo_gemini';
  static const String scanMealKey = 'scan_meal';
  static const String findStoresKey = 'find_stores';
  static const String hybridCloudModelKey = 'hybrid_cloud_model';
  static const String hybridIngredientsPromptKey = 'hybrid_ingredients_prompt';
  static const String recipePairingKey = 'recipe_pairing';
  static const String voiceProfileKey = 'recipe_pairing_voice_profile';
  static const String ttsModelKey = 'tts_model';

  // Template input fields
  static const String imageDataField = 'imageData';
  static const String mimeTypeField = 'mimeType';
  static const String ingredientsField = 'ingredients';
  static const String notesField = 'notes';
  static const String recipeTitleField = 'recipeTitle';
  static const String dayField = 'dayOfWeek';
  static const String timeField = 'currentTime';

  // Template input values
  static const String mimeTypeValue = 'image/jpeg';

  // Grounding with Maps config
  static const String language = 'en_US';

  // TTS config
  static const String ttsVoice = 'Charon';
  static const String ttsLanguage = 'en-US';

  GenerativeModel get _hybridGenerativeModel => _aiModel.generativeModel(
        model: _remoteConfig.getString(hybridCloudModelKey),
      );

  // ignore: experimental_member_use
  TemplateGenerativeModel get _templateGenerativeModel =>
      // ignore: experimental_member_use
      _aiModel.templateGenerativeModel();

  Future<List<StoreSchema>> findStores({
    required List<String> ingredients,
    required double latitude,
    required double longitude,
    required String currentTime,
    required String dayOfWeek,
  }) async {
    try {
      // ignore: experimental_member_use
      final response = await _templateGenerativeModel.generateContent(
        _remoteConfig.getString(findStoresKey),
        inputs: {
          ingredientsField: ingredients.join(', '),
          dayField: dayOfWeek,
          timeField: currentTime,
        },
        toolConfig: TemplateToolConfig(
          retrievalConfig: RetrievalConfig(
            latLng: LatLng(latitude: latitude, longitude: longitude),
            languageCode: language,
          ),
        ),
      );

      final decoded = _extractJsonObject(response.text);
      if (decoded == null) {
        return const [];
      }
      return StoreFinderResult.fromJson(decoded).stores;
    } catch (e) {
      debugPrint('Error finding stores with these ingredients: $e');
      return const [];
    }
  }

  Future<String> generateIngredients(Uint8List imageBytes) async {
    final trace = FirebasePerformance.instance.newTrace('hybrid-inference');
    await trace.start();
    try {
      final prompt = Content.multi([
        InlineDataPart(mimeTypeValue, imageBytes),
        TextPart(_remoteConfig.getString(hybridIngredientsPromptKey)),
      ]);

      final response = await _hybridGenerativeModel.generateContent([prompt]);
      trace.putAttribute('inferenceSource', 'In cloud');
      return response.text ?? '';
    } finally {
      await trace.stop();
    }
  }

  Future<RecipeSchema?> generateRecipe(
    String ingredients,
    String notes,
  ) async {
    final inputs = <String, Object?>{
      ingredientsField: ingredients,
      if (notes.trim().isNotEmpty) notesField: notes,
    };

    // ignore: experimental_member_use
    final response = await _templateGenerativeModel.generateContent(
      _remoteConfig.getString(generateRecipeKey),
      inputs: inputs,
    );

    final decoded = _extractJsonObject(response.text);
    if (decoded == null) {
      return null;
    }
    return RecipeSchema.fromJson(decoded);
  }

  Future<Uint8List?> generateRecipePhoto(String recipeTitle) async {
    // ignore: experimental_member_use
    final response = await _templateGenerativeModel.generateContent(
      _remoteConfig.getString(generateRecipePhotoGeminiKey),
      inputs: {recipeTitleField: recipeTitle},
    );

    final parts = response.candidates.firstOrNull?.content.parts ?? const [];
    for (final part in parts) {
      if (part is InlineDataPart) {
        return part.bytes;
      }
    }
    return null;
  }

  Future<MealSchema?> scanMeal(String imageData) async {
    // ignore: experimental_member_use
    final response = await _templateGenerativeModel.generateContent(
      _remoteConfig.getString(scanMealKey),
      inputs: {
        mimeTypeField: mimeTypeValue,
        imageDataField: imageData,
      },
    );

    final decoded = _extractJsonObject(response.text);
    if (decoded == null) {
      return null;
    }
    return MealSchema.fromJson(decoded);
  }

  Map<String, dynamic>? _extractJsonObject(String? rawText) {
    if (rawText == null || rawText.trim().isEmpty) {
      return null;
    }
    final start = rawText.indexOf('{');
    final end = rawText.lastIndexOf('}');
    if (start == -1 || end == -1 || end < start) {
      return null;
    }
    final cleanJson = rawText.substring(start, end + 1);
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }

  Future<String> craftRecipePairing(
    String dishTitle,
    List<String> ingredients,
  ) async {
    // ignore: experimental_member_use
    final response = await _templateGenerativeModel.generateContent(
      _remoteConfig.getString(recipePairingKey),
      inputs: {
        recipeTitleField: dishTitle,
        ingredientsField: ingredients.join(', '),
      },
    );

    return (response.text ?? '').trim();
  }

  Future<Uint8List?> generateSpeech(String? text) async {
    if (text == null || text.trim().isEmpty) return null;

    final model = _aiModel.generativeModel(
      model: _remoteConfig.getString(ttsModelKey),
      generationConfig: GenerationConfig(
        responseModalities: [ResponseModalities.audio],
        speechConfig: SpeechConfig(
          voiceName: ttsVoice,
          languageCode: ttsLanguage,
        ),
      ),
    );

    final voiceProfile = _remoteConfig.getString(voiceProfileKey);
    final response = await model.generateContent([
      Content.text('$voiceProfile $text'),
    ]);

    final part =
        response.candidates.firstOrNull?.content.parts.firstOrNull;
    if (part is InlineDataPart) {
      return part.bytes;
    }
    return null;
  }

  Future<void> loadOnDeviceModel() async {
    // On-device model preloading via Gemini Nano is handled by cloud fallback in Flutter.
    debugPrint('AIRemoteDataSource: Cloud inference configured for hybrid model');
  }
}
