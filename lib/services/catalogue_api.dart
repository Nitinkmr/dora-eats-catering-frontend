import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catalogue_item.dart';

class CatalogueApi {
  CatalogueApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  // Pass the full endpoint at build time:
  // flutter run -d chrome --dart-define=CATALOGUE_API_URL=https://api.example.com/catalogue
  static const String endpoint = String.fromEnvironment('CATALOGUE_API_URL');

  Future<List<CatalogueItem>> fetchCatalogue() async {
    if (endpoint.trim().isEmpty) {
      throw const CatalogueApiException(
        'Catalogue API URL is not configured. Run with --dart-define=CATALOGUE_API_URL=https://your-api/catalogue.',
      );
    }

    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const CatalogueApiException('CATALOGUE_API_URL must be a full http:// or https:// URL.');
    }

    final response = await _client.get(uri, headers: const {'Accept': 'application/json'}).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CatalogueApiException('Catalogue request failed (${response.statusCode}).');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const CatalogueApiException('The catalogue API did not return valid JSON.');
    }

    final dynamic rawItems = decoded is List ? decoded : (decoded is Map<String, dynamic> ? decoded['items'] : null);
    if (rawItems is! List) {
      throw const CatalogueApiException('Expected a JSON array or an object containing an "items" array.');
    }

    return rawItems
        .whereType<Map>()
        .map((item) => CatalogueItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}

class CatalogueApiException implements Exception {
  const CatalogueApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
