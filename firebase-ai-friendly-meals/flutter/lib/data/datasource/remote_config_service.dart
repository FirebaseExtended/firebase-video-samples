import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;
  StreamSubscription<RemoteConfigUpdate>? _configUpdateSub;

  static const Map<String, Object> defaultParameters = {
    'find_stores': 'find-stores-template-v1-0-0',
    'recipe_pairing': 'recipe-pairing-v1-0-0',
    'recipe_pairing_voice_profile':
        "[Audio Profile: A French chef with a charming French accent][Scene: An elegant Parisian restaurant during a masterclass on food and wine pairing][Director's Notes: Speak as if you're a French chef who is an expert in pairing dishes with wines. Speak with warm enthusiasm and culinary sophistication]",
    'tts_model': 'gemini-3.1-flash-tts-preview',
    'hybrid_cloud_model': 'gemini-3.1-flash-lite',
    'hybrid_ingredients_prompt':
        'Please analyze this image and list all visible food ingredients. Output ONLY a comma-separated list of ingredients. Do not include any introductory text, headers, or concluding remarks. Provide the raw list only. Be specific with measurements where possible.',
    'scan_meal': 'scan-meal-template-v1-0-0',
    'generate_recipe_photo_gemini':
        'generate-recipe-photo-gemini-template-v1-0-0',
    'generate_recipe': 'generate-recipe-template-v1-0-0',
    'live_model_name': 'gemini-2.5-flash-native-audio-preview-12-2025',
    'live_model_prompt': '''You are a helpful live cooking assistant. The user is currently preparing the following recipe:
Title: {{title}}
Prep time: {{prepTime}}, Cook time: {{cookTime}}, Servings: {{servings}}

Ingredients:
{{ingredients}}

Instructions:
{{instructions}}

The user will stream real-time video of their cooking and ask questions like "Is this the expected texture of the recipe?".
Confirm or deny accurately based on the recipe context and the video content. Be concise and helpful.
If the user asks you to add an ingredient or item to their grocery list or shopping list, call the addIngredientToGroceryList function.''',
  };

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(seconds: 1800),
        ),
      );
      await _remoteConfig.setDefaults(defaultParameters);
      await _remoteConfig.fetchAndActivate();

      if (!kIsWeb) {
        _configUpdateSub = _remoteConfig.onConfigUpdated.listen(
          (_) async {
            try {
              await _remoteConfig.activate();
            } catch (e) {
              debugPrint('Error activating updated Remote Config: $e');
            }
          },
          onError: (Object error) {
            debugPrint('Remote Config real-time listener error: $error');
          },
        );
      }
    } catch (e) {
      debugPrint('Remote Config initialization error: $e');
    }
  }

  String getString(String key) {
    final value = _remoteConfig.getString(key);
    if (value.isNotEmpty) {
      return value;
    }
    return defaultParameters[key]?.toString() ?? '';
  }

  void dispose() {
    _configUpdateSub?.cancel();
  }
}
