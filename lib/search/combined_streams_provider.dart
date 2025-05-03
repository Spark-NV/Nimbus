import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../indexers/torrentio_provider.dart';
import '../indexers/orionoid_provider.dart';
import '../indexers/indexer_settings_provider.dart';
import '../indexers/torrentio_response.dart';
import '../indexers/orionoid_response.dart';

final logger = Logger();

final combinedMovieStreamsProvider = FutureProvider.family<TorrentioResponse, String>(
  (ref, imdbId) async {
    try {
      final settings = ref.watch(torrentioSettingsProvider);
      final results = <TorrentioStream>[];

      if (settings.torrentioEnabled) {
        try {
          final torrentioStreams = await ref.watch(movieStreamsProvider(imdbId).future);
          results.addAll(torrentioStreams.streams);
        } catch (e) {
          logger.w('Error fetching Torrentio streams', error: e);
        }
      }

      if (settings.orionoidEnabled) {
        try {
          final orionoidStreams = await ref.watch(orionoidMovieStreamsProvider(imdbId).future);
          for (final stream in orionoidStreams.streams) {
            results.add(TorrentioStream(
              name: stream.name,
              title: stream.title,
              url: stream.url,
              behaviorHints: TorrentioBehaviorHints(
                filename: stream.name,
              ),
            ));
          }
        } catch (e) {
          logger.w('Error fetching Orionoid streams', error: e);
        }
      }

      return TorrentioResponse(
        streams: results,
        cacheMaxAge: 3600,
        staleRevalidate: 14400,
        staleError: 604800,
      );
    } catch (e, stackTrace) {
      logger.e('Error in combinedMovieStreamsProvider', error: e, stackTrace: stackTrace);
      rethrow;
    }
  },
);

final combinedEpisodeStreamsProvider = FutureProvider.family<TorrentioResponse, ({
  String imdbId,
  int seasonNumber,
  int episodeNumber,
})>((ref, params) async {
  try {
    final settings = ref.watch(torrentioSettingsProvider);
    final results = <TorrentioStream>[];

    if (settings.torrentioEnabled) {
      try {
        final torrentioStreams = await ref.watch(episodeStreamsProvider(params).future);
        results.addAll(torrentioStreams.streams);
      } catch (e) {
        logger.w('Error fetching Torrentio streams', error: e);
      }
    }

    if (settings.orionoidEnabled) {
      try {
        final orionoidStreams = await ref.watch(orionoidEpisodeStreamsProvider(params).future);
        for (final stream in orionoidStreams.streams) {
          results.add(TorrentioStream(
            name: stream.name,
            title: stream.title,
            url: stream.url,
            behaviorHints: TorrentioBehaviorHints(
              filename: stream.name,
            ),
          ));
        }
      } catch (e) {
        logger.w('Error fetching Orionoid streams', error: e);
      }
    }

    return TorrentioResponse(
      streams: results,
      cacheMaxAge: 3600,
      staleRevalidate: 14400,
      staleError: 604800,
    );
  } catch (e, stackTrace) {
    logger.e('Error in combinedEpisodeStreamsProvider', error: e, stackTrace: stackTrace);
    rethrow;
  }
});

final enabledMovieStreamProvidersProvider = Provider<List<Future<TorrentioResponse> Function(String)>>((ref) {
  final settings = ref.watch(torrentioSettingsProvider);
  final providers = <Future<TorrentioResponse> Function(String)>[];

  if (settings.torrentioEnabled) {
    providers.add((imdbId) => ref.watch(movieStreamsProvider(imdbId).future));
  }

  if (settings.orionoidEnabled) {
    providers.add((imdbId) async {
      final orionoidStreams = await ref.watch(orionoidMovieStreamsProvider(imdbId).future);
      final results = <TorrentioStream>[];
      for (final stream in orionoidStreams.streams) {
        results.add(TorrentioStream(
          name: stream.name,
          title: stream.title,
          url: stream.url,
          behaviorHints: TorrentioBehaviorHints(
            filename: stream.name,
          ),
        ));
      }
      return TorrentioResponse(
        streams: results,
        cacheMaxAge: 3600,
        staleRevalidate: 14400,
        staleError: 604800,
      );
    });
  }

  return providers;
});

final enabledEpisodeStreamProvidersProvider = Provider<List<Future<TorrentioResponse> Function(({String imdbId, int seasonNumber, int episodeNumber}))>>((ref) {
  final settings = ref.watch(torrentioSettingsProvider);
  final providers = <Future<TorrentioResponse> Function(({String imdbId, int seasonNumber, int episodeNumber}))>[];

  if (settings.torrentioEnabled) {
    providers.add((params) => ref.watch(episodeStreamsProvider(params).future));
  }

  if (settings.orionoidEnabled) {
    providers.add((params) async {
      final orionoidStreams = await ref.watch(orionoidEpisodeStreamsProvider(params).future);
      final results = <TorrentioStream>[];
      for (final stream in orionoidStreams.streams) {
        results.add(TorrentioStream(
          name: stream.name,
          title: stream.title,
          url: stream.url,
          behaviorHints: TorrentioBehaviorHints(
            filename: stream.name,
          ),
        ));
      }
      return TorrentioResponse(
        streams: results,
        cacheMaxAge: 3600,
        staleRevalidate: 14400,
        staleError: 604800,
      );
    });
  }

  return providers;
}); 