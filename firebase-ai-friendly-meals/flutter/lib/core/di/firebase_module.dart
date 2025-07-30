import 'package:firebase_ai/firebase_ai.dart';
import 'package:injectable/injectable.dart';

@module
/// You can find the models here: https://ai.google.dev/gemini-api/docs/models
abstract class FirebaseModule {
  @preResolve
  @singleton
  // TODO: Creating the Google AI instance
  FirebaseAI get _googleAI => throw UnimplementedError();

  @singleton
  GenerativeModel provideGenerativeModel() {
    // TODO: Creating the generative model instance
    throw UnimplementedError();
  }

  @singleton
  ImagenModel provideImagenModel() {
    // TODO: Creating the imagen model instance
    throw UnimplementedError();
  }
}
