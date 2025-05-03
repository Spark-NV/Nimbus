import 'package:freezed_annotation/freezed_annotation.dart';

part 'omdb_search_result.freezed.dart';
part 'omdb_search_result.g.dart';

@freezed
class OmdbSearchResult with _$OmdbSearchResult {
  const factory OmdbSearchResult({
    @JsonKey(name: 'Search') List<OmdbSearchItem>? search,
    @JsonKey(name: 'totalResults') String? totalResults,
    required String Response,
    String? Error,
    String? Title,
    String? Year,
    String? Rated,
    String? Released,
    String? Runtime,
    String? Genre,
    String? Director,
    String? Writer,
    String? Actors,
    String? Plot,
    String? Language,
    String? Country,
    String? Awards,
    String? Poster,
    @JsonKey(name: 'imdbID') String? imdbId,
    String? Type,
  }) = _OmdbSearchResult;

  factory OmdbSearchResult.fromJson(Map<String, dynamic> json) =>
      _$OmdbSearchResultFromJson(json);
}

@freezed
class OmdbSearchItem with _$OmdbSearchItem {
  const factory OmdbSearchItem({
    required String Title,
    required String Year,
    @JsonKey(name: 'imdbID') required String imdbId,
    required String Type,
    required String Poster,
  }) = _OmdbSearchItem;

  factory OmdbSearchItem.fromJson(Map<String, dynamic> json) =>
      _$OmdbSearchItemFromJson(json);
} 