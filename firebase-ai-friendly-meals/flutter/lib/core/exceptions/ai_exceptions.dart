sealed class AIException implements Exception {
  const AIException(this.message);
  final String message;

  @override
  String toString() => 'AIException: $message';
}

class AIGenerationException extends AIException {
  const AIGenerationException(super.message);

  @override
  String toString() => 'AI Generation Failed: $message';
}

class ImageAnalysisException extends AIException {
  const ImageAnalysisException(super.message);

  @override
  String toString() => 'Image Analysis Failed: $message';
}

class NetworkException extends AIException {
  const NetworkException(super.message);

  @override
  String toString() => 'Network Error: $message';
}

class ValidationException extends AIException {
  const ValidationException(super.message);

  @override
  String toString() => 'Validation Error: $message';
}
