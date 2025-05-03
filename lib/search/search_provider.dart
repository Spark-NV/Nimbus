import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../omdb/omdb_repository.dart';
import '../omdb/omdb_search_result.dart';

part 'search_provider.g.dart';

enum MediaType {
  movie,
  series,
}

@riverpod
class SearchState extends _$SearchState {
  @override
  FutureOr<List<OmdbSearchItem>> build() {
    return [];
  }

  Future<void> search({
    required String query,
    String? year,
    MediaType? type,
    int? season,
    int? episode,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final results = await ref.read(omdbRepositoryProvider).searchMedia(
        query: query,
        year: year,
        type: type == MediaType.movie ? 'movie' : type == MediaType.series ? 'series' : null,
      );

      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 