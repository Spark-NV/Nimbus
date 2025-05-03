import 'package:json_annotation/json_annotation.dart';

part 'torrentio_response.g.dart';

@JsonSerializable()
class TorrentioResponse {
  @JsonKey(defaultValue: [])
  final List<TorrentioStream> streams;
  @JsonKey(name: 'cacheMaxAge', defaultValue: 3600)
  final int cacheMaxAge;
  @JsonKey(name: 'staleRevalidate', defaultValue: 14400)
  final int staleRevalidate;
  @JsonKey(name: 'staleError', defaultValue: 604800)
  final int staleError;

  TorrentioResponse({
    required this.streams,
    required this.cacheMaxAge,
    required this.staleRevalidate,
    required this.staleError,
  });

  factory TorrentioResponse.fromJson(Map<String, dynamic> json) =>
      _$TorrentioResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TorrentioResponseToJson(this);
}

@JsonSerializable()
class TorrentioStream {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String url;
  @JsonKey(name: 'behaviorHints')
  final TorrentioBehaviorHints? behaviorHints;

  TorrentioStream({
    required this.name,
    required this.title,
    required this.url,
    this.behaviorHints,
  });

  factory TorrentioStream.fromJson(Map<String, dynamic> json) {
    if (json['behaviorHints'] == null) {
      return TorrentioStream(
        name: json['name'] as String? ?? '',
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
    }
    return _$TorrentioStreamFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TorrentioStreamToJson(this);
}

@JsonSerializable()
class TorrentioBehaviorHints {
  @JsonKey(name: 'bingeGroup')
  final String? bingeGroup;
  @JsonKey(name: 'filename')
  final String? filename;

  TorrentioBehaviorHints({
    this.bingeGroup,
    this.filename,
  });

  factory TorrentioBehaviorHints.fromJson(Map<String, dynamic> json) =>
      _$TorrentioBehaviorHintsFromJson(json);

  Map<String, dynamic> toJson() => _$TorrentioBehaviorHintsToJson(this);
}

@JsonSerializable()
class TorrentioStreamInfo {
  @JsonKey(name: 'type', defaultValue: '')
  final String type;
  @JsonKey(name: 'fileIdx')
  final int? fileIdx;
  @JsonKey(name: 'name')
  final String? name;

  TorrentioStreamInfo({
    required this.type,
    this.fileIdx,
    this.name,
  });

  factory TorrentioStreamInfo.fromJson(Map<String, dynamic> json) =>
      _$TorrentioStreamInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TorrentioStreamInfoToJson(this);
} 