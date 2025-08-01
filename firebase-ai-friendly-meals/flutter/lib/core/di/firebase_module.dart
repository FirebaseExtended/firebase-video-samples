import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:injectable/injectable.dart';

@module
/// You can find the models here: https://ai.google.dev/gemini-api/docs/models
abstract class FirebaseModule {
  @preResolve
  @singleton
  FirebaseAI get _googleAI => FirebaseAI.googleAI(
    appCheck: FirebaseAppCheck.instance,
  );

  @singleton
  GenerativeModel provideGenerativeModel() {
    const model = 'gemini-2.0-flash';

    return _googleAI.generativeModel(
      model: model,
    );
  }

  @singleton
  ImagenModel provideImagenModel() {
    const model = 'imagen-3.0-generate-002';

    final generationConfig = ImagenGenerationConfig(
      numberOfImages: 1,
      aspectRatio: ImagenAspectRatio.square1x1,
      imageFormat: ImagenFormat.png(),
    );

    final safetySettings = ImagenSafetySettings(
      ImagenSafetyFilterLevel.blockLowAndAbove,
      ImagenPersonFilterLevel.blockAll,
    );

    return _googleAI.imagenModel(
      model: model,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
    );
  }
}
