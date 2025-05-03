import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'torrentio_response.dart';
import 'torrentio_service.dart';

final logger = Logger();

final torrentioRepositoryProvider = Provider<TorrentioRepository>((ref) {
  return TorrentioRepository(ref);
});

class TorrentioRepository {
  final Ref _ref;

  TorrentioRepository(this._ref);

  Future<TorrentioResponse> getMovieStreams(String imdbId) async {
    try {
      final service = _ref.read(torrentioServiceProvider);
      return await service.getMovieStreams(imdbId);
    } catch (e, stackTrace) {
      logger.e('Error in getMovieStreams', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<TorrentioResponse> getEpisodeStreams(
    String imdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    try {
      final service = _ref.read(torrentioServiceProvider);
      return await service.getEpisodeStreams(
        imdbId,
        seasonNumber,
        episodeNumber,
      );
    } catch (e, stackTrace) {
      logger.e('Error in getEpisodeStreams', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 