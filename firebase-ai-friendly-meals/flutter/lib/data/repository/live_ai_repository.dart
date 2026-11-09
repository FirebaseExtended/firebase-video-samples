import 'package:firebase_ai/firebase_ai.dart';

import '../datasource/live_ai_remote_datasource.dart';
import '../model/recipe.dart';

class LiveAIRepository {
  LiveAIRepository(this._liveAiRemoteDataSource);

  final LiveAIRemoteDataSource _liveAiRemoteDataSource;

  Future<LiveSession?> setupLiveSession(Recipe recipe) {
    return _liveAiRemoteDataSource.setupLiveSession(recipe);
  }
}
