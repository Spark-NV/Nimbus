import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'omdb_service.dart';
import 'omdb_search_result.dart';

final omdbRepositoryProvider = Provider<OmdbRepository>((ref) {
  final service = ref.watch(omdbServiceProvider);
  return OmdbRepository(service);
});

class OmdbRepository {
  final OmdbService _service;

  OmdbRepository(this._service);

  Future<List<OmdbSearchItem>> searchMedia({
    required String query,
    String? year,
    String? type,
  }) async {
    final result = await _service.searchMedia(
      query: query,
      year: year,
      type: type,
    );
    
    if (result.Response != 'True' || result.search == null) {
      return [];
    }
    return result.search!;
  }

  Future<OmdbSearchResult?> getMediaByImdbId(String imdbId) async {
    final result = await _service.getMediaByImdbId(imdbId);
    if (result.Response != 'True') {
      return null;
    }
    return result;
  }
} 