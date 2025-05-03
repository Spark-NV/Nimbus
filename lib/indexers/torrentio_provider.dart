import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'torrentio_response.dart';
import 'torrentio_repository.dart';

final logger = Logger();

final movieStreamsProvider = FutureProvider.family<TorrentioResponse, String>(
  (ref, imdbId) async {
    try {
      final repository = ref.read(torrentioRepositoryProvider);
      return await repository.getMovieStreams(imdbId);
    } catch (e, stackTrace) {
      logger.e('Error in movieStreamsProvider', error: e, stackTrace: stackTrace);
      rethrow;
    }
  },
);

final episodeStreamsProvider = FutureProvider.family<TorrentioResponse, ({
  String imdbId,
  int seasonNumber,
  int episodeNumber,
})>((ref, params) async {
  try {
    final repository = ref.read(torrentioRepositoryProvider);
    return await repository.getEpisodeStreams(
      params.imdbId,
      params.seasonNumber,
      params.episodeNumber,
    );
  } catch (e, stackTrace) {
    logger.e('Error in episodeStreamsProvider', error: e, stackTrace: stackTrace);
    rethrow;
  }
}); 