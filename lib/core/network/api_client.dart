import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_environment.dart';
import '../errors/app_failure.dart';
import '../services/logging/app_logger.dart';

/// Contract for shell-owned HTTP calls only (e.g. account bootstrap).
/// Modules ship their own clients behind their interfaces — do not centralize module APIs here.
abstract class ApiClient {
  Future<Map<String, dynamic>> getJson(String path);
}

/// Minimal HTTP implementation — extend or swap via DI for interceptors / tokens.
class HttpApiClient implements ApiClient {
  HttpApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _resolve(String path) {
    final base = AppEnvironment.apiBaseUrl;
    if (base.isEmpty) {
      throw const NetworkFailure(
        'API_BASE_URL not set — define via --dart-define=API_BASE_URL=',
      );
    }
    return Uri.parse('$base').resolve(path);
  }

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    try {
      final response = await _client.get(_resolve(path));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw const NetworkFailure('Invalid JSON shape');
      }
      throw NetworkFailure('HTTP ${response.statusCode}');
    } catch (e, st) {
      AppLogger.instance.warning('GET failed', e, st);
      if (e is AppFailure) rethrow;
      throw NetworkFailure('$e');
    }
  }
}
