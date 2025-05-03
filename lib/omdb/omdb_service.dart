import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'omdb_search_result.dart';
import 'omdb_api_key_service.dart';

part 'omdb_service.g.dart';

final logger = Logger();

@riverpod
class OmdbService extends _$OmdbService {
  static const String _baseUrl = 'http://www.omdbapi.com/';
  late final Dio _dio;

  @override
  OmdbService build() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));
    return this;
  }

  Future<OmdbSearchResult> searchMedia({
    required String query,
    String? year,
    String? type,
  }) async {
    final apiKey = await ref.read(omdbApiKeyServiceProvider.future);
    if (apiKey == null) {
      logger.e('OMDB API key not found');
      throw Exception('OMDB API key not found');
    }

    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'apikey': apiKey,
          's': query,
          if (year != null) 'y': year,
          if (type != null) 'type': type,
        },
      );

      logger.d('OMDB Search Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final result = OmdbSearchResult.fromJson(response.data);
      if (result.Response == 'False') {
        throw Exception(result.Error ?? 'Unknown error');
      }

      return result;
    } catch (e) {
      logger.e('Error searching OMDB', error: e);
      rethrow;
    }
  }

  Future<OmdbSearchResult> getMediaByImdbId(String imdbId) async {
    final apiKey = await ref.read(omdbApiKeyServiceProvider.future);
    if (apiKey == null) {
      logger.e('OMDB API key not found');
      throw Exception('OMDB API key not found');
    }

    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'apikey': apiKey,
          'i': imdbId,
        },
      );

      logger.d('OMDB Get Media Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final result = OmdbSearchResult.fromJson(response.data);
      if (result.Response == 'False') {
        throw Exception(result.Error ?? 'Unknown error');
      }

      return result;
    } catch (e) {
      logger.e('Error getting media from OMDB', error: e);
      rethrow;
    }
  }
} 