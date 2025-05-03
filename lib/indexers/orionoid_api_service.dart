import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'orionoid_response.dart';
import 'orionoid_auth_response.dart';
import 'orionoid_settings.dart';
import 'orionoid_api_key_service.dart';
import 'indexer_settings_provider.dart';

final logger = Logger();

final orionoidApiServiceProvider = Provider<OrionoidApiService>((ref) {
  return OrionoidApiService(ref);
});

class OrionoidApiService {
  final Ref _ref;
  final Dio _dio;
  SharedPreferences? _prefs;
  static const _baseUrl = 'https://api.orionoid.com';
  static const String _authTokenPref = 'orionoid_auth_token';

  OrionoidApiService(this._ref) : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.i('Orionoid API Request: ${options.method} ${options.uri}');
        logger.i('Headers: ${options.headers}');
        logger.i('Data: ${options.data}');
        logger.i('Query Parameters: ${options.queryParameters}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.i('Orionoid API Response: ${response.statusCode}');
        logger.i('Headers: ${response.headers}');
        logger.i('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        logger.e('Orionoid API Error', error: error);
        logger.e('Error Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<String?> get apiKey async {
    try {
      final apiKeyState = await _ref.read(orionoidApiKeyServiceProvider.future);
      return apiKeyState;
    } catch (e, stackTrace) {
      logger.e('Error getting API key from OrionoidApiKeyService', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> get hasApiKey async {
    final key = await apiKey;
    return key != null && key.length >= 4;
  }

  String? get authToken => _prefs?.getString(_authTokenPref);

  bool get hasAuthToken => authToken != null && authToken!.isNotEmpty;

  Future<void> setApiKey(String apiKey) async {
    try {
      logger.i('Setting Orionoid API key via OrionoidApiKeyService');
      await _ref.read(orionoidApiKeyServiceProvider.notifier).setApiKey(apiKey);
      logger.i('Orionoid API key saved via OrionoidApiKeyService');
    } catch (e, stackTrace) {
      logger.e('Error setting API key via OrionoidApiKeyService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearApiKey() async {
    try {
      logger.i('Clearing Orionoid API key via OrionoidApiKeyService');
      await _ref.read(orionoidApiKeyServiceProvider.notifier).clearApiKey();
      logger.i('Orionoid API key cleared via OrionoidApiKeyService');
    } catch (e, stackTrace) {
      logger.e('Error clearing API key via OrionoidApiKeyService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setAuthToken(String token) async {
    await initialize();
    await _prefs?.setString(_authTokenPref, token);
    logger.i('Orionoid auth token saved');
  }

  Future<void> clearAuthToken() async {
    await initialize();
    await _prefs?.remove(_authTokenPref);
    logger.i('Orionoid auth token cleared');
  }

  Future<OrionoidAuthResponse> startAuth() async {
    try {
      final hasKey = await hasApiKey;
      
      if (!hasKey) {
        logger.e('Orionoid API key not found');
        throw Exception('Orionoid API key not found. Please set it in settings.');
      }

      final key = await apiKey;
      logger.i('Starting Orionoid authentication process');
      
      final response = await _dio.post(
        '/',
        data: {
          'keyapp': key,
          'mode': 'user',
          'action': 'authenticate',
        },
      );
      
      logger.i('Orionoid auth start response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          logger.e('Invalid response format from Orionoid API: ${response.data}');
          throw Exception('Invalid response format from Orionoid API');
        }
        return OrionoidAuthResponse.fromJson(response.data);
      } else {
        logger.e('Failed to start authentication: ${response.statusCode}');
        throw Exception('Failed to start authentication: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('Error starting authentication', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<OrionoidAuthResponse> checkAuthStatus(String code) async {
    try {
      final hasKey = await hasApiKey;
      if (!hasKey) {
        logger.e('Orionoid API key not found');
        throw Exception('Orionoid API key not found. Please set it in settings.');
      }

      final key = await apiKey;
      logger.i('Checking Orionoid authentication status with code: $code');
      
      final response = await _dio.post(
        '/',
        data: {
          'keyapp': key,
          'mode': 'user',
          'action': 'authenticate',
          'code': code,
        },
      );
      
      logger.i('Orionoid auth check response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          logger.e('Invalid response format from Orionoid API: ${response.data}');
          throw Exception('Invalid response format from Orionoid API');
        }
        return OrionoidAuthResponse.fromJson(response.data);
      } else {
        logger.e('Failed to check authentication status: ${response.statusCode}');
        throw Exception('Failed to check authentication status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('Error checking authentication status', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<OrionoidResponse> getMovieStreams(String imdbId) async {
    try {
      final hasKey = await hasApiKey;
      if (!hasKey) {
        logger.e('Orionoid API key not found');
        throw Exception('Orionoid API key not found. Please set it in settings.');
      }

      final key = await apiKey;
      final token = authToken;
      if (token == null) {
        logger.e('Orionoid auth token not found');
        throw Exception('Orionoid auth token not found. Please authenticate first.');
      }

      final cleanImdbId = imdbId.startsWith('tt') ? imdbId.substring(2) : imdbId;
      logger.i('Fetching movie streams for IMDB ID: $cleanImdbId (original: $imdbId)');
      
      final settings = _ref.read(indexerSettingsProvider);
      final data = {
        'keyapp': key,
        'token': token,
        'mode': 'stream',
        'action': 'retrieve',
        'type': 'movie',
        'streamtype': 'torrent',
        'idimdb': cleanImdbId,
      };

      data['limitcount'] = settings.movieLimit.toString();
      logger.i('Using movie limit: ${settings.movieLimit}');

      if (settings.movieSortValue != SortValue.none) {
        data['sortvalue'] = _getSortValue(settings.movieSortValue);
        data['sortorder'] = _getSortOrder(settings.movieSortOrder);
        logger.i('Using movie sort: ${settings.movieSortValue}, order: ${settings.movieSortOrder}');
      }

      if (settings.movieMinBytes != null && settings.movieMaxBytes != null) {
        data['filesize'] = '${settings.movieMinBytes}_${settings.movieMaxBytes}';
        logger.i('Using movie size limits: ${settings.movieMinBytes} - ${settings.movieMaxBytes} bytes');
      }

      if (settings.movieSubtitleLanguage != null) {
        data['subtitlelanguages'] = settings.movieSubtitleLanguage;
        logger.i('Using movie subtitle language: ${settings.movieSubtitleLanguage}');
      }

      if (settings.movieAudioLanguage != null) {
        data['audiolanguages'] = settings.movieAudioLanguage;
        logger.i('Using movie audio language: ${settings.movieAudioLanguage}');
      }

      if (settings.movieSeederLimit != null) {
        data['streamseeds'] = settings.movieSeederLimit.toString();
        logger.i('Using movie seeder limit: ${settings.movieSeederLimit}');
      }
      
      final response = await _dio.post('/', data: data);
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          logger.e('Invalid response format from Orionoid API: ${response.data}');
          throw Exception('Invalid response format from Orionoid API');
        }

        if (response.data['result']?['status'] == 'error' && 
            response.data['result']?['type'] == 'streammissing') {
          logger.i('No streams found for IMDB ID: $cleanImdbId');
          return OrionoidResponse(
            streams: [],
            count: 0,
            status: 'success',
            message: 'No streams found',
          );
        }

        return OrionoidResponse.fromJson(response.data);
      } else {
        logger.e('Failed to fetch movie streams: ${response.statusCode}');
        throw Exception('Failed to fetch movie streams: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching movie streams', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<OrionoidResponse> getEpisodeStreams(
    String imdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    try {
      final hasKey = await hasApiKey;
      if (!hasKey) {
        logger.e('Orionoid API key not found');
        throw Exception('Orionoid API key not found. Please set it in settings.');
      }

      final key = await apiKey;
      final token = authToken;
      if (token == null) {
        logger.e('Orionoid auth token not found');
        throw Exception('Orionoid auth token not found. Please authenticate first.');
      }

      final cleanImdbId = imdbId.startsWith('tt') ? imdbId.substring(2) : imdbId;
      logger.i('Fetching episode streams for IMDB ID: $cleanImdbId (original: $imdbId), Season: $seasonNumber, Episode: $episodeNumber');
      
      final settings = _ref.read(indexerSettingsProvider);
      final data = {
        'keyapp': key,
        'token': token,
        'mode': 'stream',
        'action': 'retrieve',
        'type': 'show',
        'streamtype': 'torrent',
        'idimdb': cleanImdbId,
        'numberseason': seasonNumber.toString(),
        'numberepisode': episodeNumber.toString(),
      };

      data['limitcount'] = settings.tvShowLimit.toString();
      logger.i('Using TV show limit: ${settings.tvShowLimit}');

      if (settings.tvShowSortValue != SortValue.none) {
        data['sortvalue'] = _getSortValue(settings.tvShowSortValue);
        data['sortorder'] = _getSortOrder(settings.tvShowSortOrder);
        logger.i('Using TV show sort: ${settings.tvShowSortValue}, order: ${settings.tvShowSortOrder}');
      }

      if (settings.tvShowMinBytes != null && settings.tvShowMaxBytes != null) {
        data['filesize'] = '${settings.tvShowMinBytes}_${settings.tvShowMaxBytes}';
        logger.i('Using TV show size limits: ${settings.tvShowMinBytes} - ${settings.tvShowMaxBytes} bytes');
      }

      if (settings.tvShowSubtitleLanguage != null) {
        data['subtitlelanguages'] = settings.tvShowSubtitleLanguage;
        logger.i('Using TV show subtitle language: ${settings.tvShowSubtitleLanguage}');
      }

      if (settings.tvShowAudioLanguage != null) {
        data['audiolanguages'] = settings.tvShowAudioLanguage;
        logger.i('Using TV show audio language: ${settings.tvShowAudioLanguage}');
      }

      if (settings.tvShowSeederLimit != null) {
        data['streamseeds'] = settings.tvShowSeederLimit.toString();
        logger.i('Using TV show seeder limit: ${settings.tvShowSeederLimit}');
      }
      
      final response = await _dio.post('/', data: data);
      
      logger.i('Orionoid episode response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          logger.e('Invalid response format from Orionoid API: ${response.data}');
          throw Exception('Invalid response format from Orionoid API');
        }

        if (response.data['result']?['status'] == 'error' && 
            response.data['result']?['type'] == 'streammissing') {
          logger.i('No streams found for IMDB ID: $cleanImdbId, Season: $seasonNumber, Episode: $episodeNumber');
          return OrionoidResponse(
            streams: [],
            count: 0,
            status: 'success',
            message: 'No streams found',
          );
        }

        return OrionoidResponse.fromJson(response.data);
      } else {
        logger.e('Failed to fetch episode streams: ${response.statusCode}');
        throw Exception('Failed to fetch episode streams: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching episode streams', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchContent({
    required String query,
    required bool isMovie,
    int? season,
    int? episode,
  }) async {
    final key = await apiKey;
    final token = authToken;

    if (key == null || token == null) {
      throw Exception('API key or auth token not set');
    }

    final settings = _ref.read(indexerSettingsProvider);
    final Map<String, String> body = {
      'keyapp': key,
      'token': token,
      'mode': 'stream',
      'action': 'retrieve',
      'type': isMovie ? 'movie' : 'show',
      'streamtype': 'torrent',
      'query': query,
    };

    final limit = isMovie ? settings.movieLimit : settings.tvShowLimit;
    if (limit != null) {
      body['limitcount'] = limit.toString();
    }

    final sortValue = isMovie ? settings.movieSortValue : settings.tvShowSortValue;
    final sortOrder = isMovie ? settings.movieSortOrder : settings.tvShowSortOrder;
    
    if (sortValue != SortValue.none) {
      body['sortvalue'] = _getSortValue(sortValue);
      body['sortorder'] = _getSortOrder(sortOrder);
    }

    if (isMovie) {
      if (settings.movieMinBytes != null && settings.movieMaxBytes != null) {
        body['filesize'] = '${settings.movieMinBytes}_${settings.movieMaxBytes}';
      }
    } else {
      if (settings.tvShowMinBytes != null && settings.tvShowMaxBytes != null) {
        body['filesize'] = '${settings.tvShowMinBytes}_${settings.tvShowMaxBytes}';
      }
    }

    final subtitleLang = isMovie ? settings.movieSubtitleLanguage : settings.tvShowSubtitleLanguage;
    if (subtitleLang != null) {
      body['subtitlelanguages'] = subtitleLang;
    }

    final audioLang = isMovie ? settings.movieAudioLanguage : settings.tvShowAudioLanguage;
    if (audioLang != null) {
      body['audiolanguages'] = audioLang;
    }

    if (!isMovie && season != null) {
      body['numberseason'] = season.toString();
      if (episode != null) {
        body['numberepisode'] = episode.toString();
      }
    }

    final seederLimit = isMovie ? settings.movieSeederLimit : settings.tvShowSeederLimit;
    if (seederLimit != null) {
      body['streamseeds'] = seederLimit.toString();
    }

    try {
      final response = await _dio.post(
        _baseUrl,
        data: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search content: ${response.statusCode}');
      }

      final data = response.data;
      
      if (data['result']?['status'] == 'error' && 
          data['result']?['type'] == 'streammissing') {
        throw NoStreamsFoundException(
          query: query,
          isMovie: isMovie,
          season: season,
          episode: episode,
        );
      }

      return data;
    } catch (e) {
      logger.e('Error searching content', error: e);
      rethrow;
    }
  }

  String _getSortValue(SortValue value) {
    switch (value) {
      case SortValue.filesize:
        return 'filesize';
      case SortValue.streamseeds:
        return 'streamseeds';
      case SortValue.videoquality:
        return 'videoquality';
      case SortValue.best:
        return 'best';
      case SortValue.shuffle:
        return 'shuffle';
      case SortValue.timeadded:
        return 'timeadded';
      case SortValue.timeupdated:
        return 'timeupdated';
      case SortValue.popularity:
        return 'popularity';
      case SortValue.none:
        return 'none';
      default:
        return 'none';
    }
  }

  String _getSortOrder(SortOrder order) {
    return order == SortOrder.ascending ? 'ascending' : 'descending';
  }
}

class NoStreamsFoundException implements Exception {
  final String query;
  final bool isMovie;
  final int? season;
  final int? episode;

  NoStreamsFoundException({
    required this.query,
    required this.isMovie,
    this.season,
    this.episode,
  });

  @override
  String toString() {
    final buffer = StringBuffer("No results found for ");
    
    buffer.write("'$query'");
    
    if (!isMovie && season != null) {
      buffer.write(" 'Season $season");
      if (episode != null) {
        buffer.write(" Episode $episode");
      }
      buffer.write("'");
    }
    
    buffer.write(".\n\nPlease check that:");
    
    buffer.write("\n• Your spelling is correct");
    
    if (isMovie) {
      buffer.write("\n• The release year is correct");
    }
    
    if (!isMovie && (season != null || episode != null)) {
      buffer.write("\n• The season");
      if (episode != null) {
        buffer.write(" and episode");
      }
      buffer.write(" numbers are correct");
    }
    
    buffer.write("\n\nIf you verified these are correct then '$query");
    if (!isMovie && season != null) {
      buffer.write(" 'Season $season");
      if (episode != null) {
        buffer.write(" Episode $episode");
      }
      buffer.write("'");
    }
    buffer.write("' might not be cached on Orionoid, sorry!");
    
    return buffer.toString();
  }
} 