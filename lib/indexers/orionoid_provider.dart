import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'orionoid_response.dart';
import 'orionoid_api_service.dart';
import '../indexers/indexer_settings_provider.dart';

final logger = Logger();

final orionoidMovieStreamsProvider = FutureProvider.family<OrionoidResponse, String>(
  (ref, imdbId) async {
    try {
      final settings = ref.read(torrentioSettingsProvider);
      if (!settings.orionoidEnabled) {
        throw Exception('Orionoid is disabled in settings');
      }

      final service = ref.read(orionoidApiServiceProvider);
      return await service.getMovieStreams(imdbId);
    } catch (e, stackTrace) {
      logger.e('Error in orionoidMovieStreamsProvider', error: e, stackTrace: stackTrace);
      rethrow;
    }
  },
);

final orionoidEpisodeStreamsProvider = FutureProvider.family<OrionoidResponse, ({
  String imdbId,
  int seasonNumber,
  int episodeNumber,
})>((ref, params) async {
  try {
    final settings = ref.read(torrentioSettingsProvider);
    if (!settings.orionoidEnabled) {
      throw Exception('Orionoid is disabled in settings');
    }

    final service = ref.read(orionoidApiServiceProvider);
    return await service.getEpisodeStreams(
      params.imdbId,
      params.seasonNumber,
      params.episodeNumber,
    );
  } catch (e, stackTrace) {
    logger.e('Error in orionoidEpisodeStreamsProvider', error: e, stackTrace: stackTrace);
    rethrow;
  }
}); 