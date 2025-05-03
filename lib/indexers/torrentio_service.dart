import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'torrentio_response.dart';

final logger = Logger();

final torrentioServiceProvider = Provider<TorrentioService>((ref) {
  return TorrentioService(ref);
});

class TorrentioService {
  final Ref _ref;
  final Dio _dio;

  TorrentioService(this._ref) : _dio = Dio() {
    _dio.options.baseUrl = 'https://torrentio.strem.fun';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('premiumize_api_key');
  }

  Future<TorrentioResponse> getMovieStreams(String imdbId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Premiumize API key not found. Please set it in settings.');
      }
      
      logger.i('Fetching movie streams for IMDB ID: $imdbId');
      final response = await _dio.get(
        '/premiumize=$apiKey/stream/movie/$imdbId.json',
      );
      
      logger.i('Torrentio movie response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from Torrentio API');
        }
        return TorrentioResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch movie streams: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching movie streams', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<TorrentioResponse> getEpisodeStreams(
    String imdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Premiumize API key not found. Please set it in settings.');
      }
      
      logger.i('Fetching episode streams for IMDB ID: $imdbId, Season: $seasonNumber, Episode: $episodeNumber');
      final response = await _dio.get(
        '/premiumize=$apiKey/stream/series/$imdbId:$seasonNumber:$episodeNumber.json',
      );
      
      logger.i('Torrentio episode response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Invalid response format from Torrentio API');
        }
        return TorrentioResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch episode streams: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching episode streams', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 