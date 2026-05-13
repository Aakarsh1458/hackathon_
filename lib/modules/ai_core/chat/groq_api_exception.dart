class GroqApiException implements Exception {
  const GroqApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'GroqApiException(statusCode: $statusCode, message: $message)';
}

class MissingGroqApiKeyException extends GroqApiException {
  const MissingGroqApiKeyException()
      : super(
          'Groq API key is missing. Add GROQ_API_KEY to your local environment.',
        );
}

class GroqTimeoutException extends GroqApiException {
  const GroqTimeoutException()
      : super(
          'The Groq request timed out. Please try again in a moment.',
        );
}

class GroqRateLimitException extends GroqApiException {
  const GroqRateLimitException({int? statusCode})
      : super(
          'Rate limit reached. Please wait a bit and retry.',
          statusCode: statusCode,
        );
}

class GroqRequestFailedException extends GroqApiException {
  const GroqRequestFailedException(
    super.message, {
    super.statusCode,
  });
}
