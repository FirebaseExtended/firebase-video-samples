import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../model/recipe.dart';
import 'remote_config_service.dart';

class LiveAIRemoteDataSource {
  LiveAIRemoteDataSource({
    FirebaseAI? aiModel,
    required RemoteConfigService remoteConfig,
  })  : _aiModel = aiModel ?? FirebaseAI.googleAI(),
        _remoteConfig = remoteConfig;

  final FirebaseAI _aiModel;
  final RemoteConfigService _remoteConfig;

  // Live Model Config
  static const String liveModelVoice = 'CHARON';

  // Tools config
  static const String addIngredientsToolName = 'addIngredientToGroceryList';
  static const String addIngredientsToolDescription =
      "Adds a specified ingredient to the user's grocery list in the database.";
  static const String ingredientFieldName = 'ingredient';
  static const String ingredientFieldDescription =
      'The name of the ingredient to add.';

  // Remote Config Keys
  static const String liveModelNameKey = 'live_model_name';
  static const String liveModelPromptKey = 'live_model_prompt';

  static final Tool _groceryListTool = Tool.functionDeclarations([
    FunctionDeclaration(
      addIngredientsToolName,
      addIngredientsToolDescription,
      parameters: {
        ingredientFieldName: Schema.string(
          description: ingredientFieldDescription,
        ),
      },
    ),
  ]);

  Future<LiveSession?> setupLiveSession(Recipe recipe) async {
    final liveGenerationConfig = LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: liveModelVoice),
      responseModalities: [ResponseModalities.audio],
    );

    final promptTemplate = _remoteConfig.getString(liveModelPromptKey);
    final instructionText = _formatInstructionPrompt(promptTemplate, recipe);

    final liveModel = _aiModel.liveGenerativeModel(
      model: _remoteConfig.getString(liveModelNameKey),
      liveGenerationConfig: liveGenerationConfig,
      systemInstruction: Content.text(instructionText),
      tools: [_groceryListTool],
    );

    try {
      return await liveModel.connect();
    } catch (e) {
      debugPrint('Failed to connect LiveSession: $e');
      return null;
    }
  }

  String _formatInstructionPrompt(String template, Recipe recipe) {
    return template
        .replaceAll('{{title}}', recipe.title)
        .replaceAll('{{prepTime}}', recipe.prepTime)
        .replaceAll('{{cookTime}}', recipe.cookTime)
        .replaceAll('{{servings}}', recipe.servings)
        .replaceAll('{{ingredients}}', recipe.ingredients.join('\n'))
        .replaceAll('{{instructions}}', recipe.instructions);
  }
}
