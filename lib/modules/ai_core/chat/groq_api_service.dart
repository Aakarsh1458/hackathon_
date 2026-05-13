import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'groq_api_exception.dart';

class GroqApiService {
  GroqApiService({
    http.Client? httpClient,
    Duration? timeout,
  })  : _client = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 25);

  final http.Client _client;
  final Duration _timeout;

  Future<Map<String, dynamic>> createCompletion({
    required Uri uri,
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const GroqTimeoutException();
    } catch (_) {
      throw const GroqRequestFailedException('Unable to reach Groq service.');
    }

    _throwIfHttpError(statusCode: response.statusCode, body: response.body);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const GroqRequestFailedException('Invalid Groq response payload.');
    }
    return decoded;
  }

  Stream<String> createStreamingCompletion({
    required Uri uri,
    required String apiKey,
    required Map<String, dynamic> payload,
  }) async* {
    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode(payload);

    http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request).timeout(_timeout);
    } on TimeoutException {
      throw const GroqTimeoutException();
    } catch (_) {
      throw const GroqRequestFailedException('Unable to reach Groq service.');
    }

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final errBody = await streamed.stream.bytesToString();
      _throwIfHttpError(statusCode: streamed.statusCode, body: errBody);
    }

    final lineStream = streamed.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
        continue;
      }
      final payloadStr = trimmed.substring(5).trim();
      if (payloadStr == '[DONE]') {
        break;
      }
      try {
        final decoded = jsonDecode(payloadStr) as Map<String, dynamic>;
        final delta = decoded['choices']?.first?['delta'];
        final content = delta?['content'];
        if (content is String && content.isNotEmpty) {
          yield content;
        }
      } catch (_) {
        // Keep streaming even if one chunk is malformed.
      }
    }
  }

  Never _throwIfHttpError({
    required int statusCode,
    required String body,
  }) {
    if (statusCode >= 200 && statusCode < 300) {
      throw StateError('No error to throw for success status.');
    }

    String detail = body.trim();
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        final err = parsed['error'];
        if (err is Map<String, dynamic> && err['message'] is String) {
          detail = err['message'] as String;
        }
      }
    } catch (_) {
      // Keep original body text.
    }

    if (statusCode == 429) {
      throw GroqRateLimitException(statusCode: statusCode);
    }

    throw GroqRequestFailedException(
      detail.isEmpty ? 'Groq request failed.' : detail,
      statusCode: statusCode,
    );
  }
}
