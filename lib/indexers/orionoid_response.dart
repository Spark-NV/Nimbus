import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

part 'orionoid_response.g.dart';

final logger = Logger();

@JsonSerializable()
class OrionoidResponse {
  @JsonKey(defaultValue: [])
  final List<OrionoidStream> streams;
  @JsonKey(name: 'count', defaultValue: 0)
  final int count;
  @JsonKey(name: 'status', defaultValue: '')
  final String status;
  @JsonKey(name: 'message')
  final String? message;

  const OrionoidResponse({
    required this.streams,
    required this.count,
    required this.status,
    this.message,
  });

  factory OrionoidResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final streamsList = data?['streams'] as List<dynamic>? ?? [];
    
    return OrionoidResponse(
      streams: streamsList.map((stream) => OrionoidStream.fromJson(stream)).toList(),
      count: streamsList.length,
      status: json['result']?['status'] ?? '',
      message: json['result']?['message'],
    );
  }

  Map<String, dynamic> toJson() => _$OrionoidResponseToJson(this);
}

@JsonSerializable()
class OrionoidStream {
  @JsonKey(name: 'id', defaultValue: '')
  final String id;
  @JsonKey(name: 'links', defaultValue: [])
  final List<String> links;
  @JsonKey(name: 'file')
  final OrionoidFile file;
  @JsonKey(name: 'stream')
  final OrionoidStreamInfo stream;
  @JsonKey(name: 'access')
  final OrionoidAccess access;
  @JsonKey(name: 'video')
  final OrionoidVideo video;
  @JsonKey(name: 'audio')
  final OrionoidAudio audio;
  @JsonKey(name: 'subtitle')
  final OrionoidSubtitle subtitle;
  @JsonKey(name: 'meta')
  final OrionoidMeta meta;
  @JsonKey(name: 'popularity')
  final OrionoidPopularity popularity;

  OrionoidStream({
    required this.id,
    required this.links,
    required this.file,
    required this.stream,
    required this.access,
    required this.video,
    required this.audio,
    required this.subtitle,
    required this.meta,
    required this.popularity,
  });

  String get name {
    final isCached = access.premiumize == true;
    final name = isCached ? '[PM+] ${file.name}' : file.name;
    logger.i('OrionoidStream name: isCached=$isCached, name=$name');
    return name;
  }
  String get title {
    final size = file.size > 0 
        ? '${(file.size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB' 
        : '';
    final seeds = stream.seeds ?? 0;
    final seedsStr = seeds > 0 ? '$seeds seeds' : '';
    final source = stream.hoster ?? '';
    final audioSystem = audio.system;
    final audioStr = audioSystem != null ? audioSystem : '';
    final quality = video.quality;
    final codec = video.codec;
    final is3d = video.is3d;
    final qualityStr = [
      if (quality.isNotEmpty) quality,
      if (codec != null) codec,
      if (is3d) '3D',
    ].join(' ');
    
    return [
      if (size.isNotEmpty) size,
      if (seedsStr.isNotEmpty) seedsStr,
      if (source.isNotEmpty) source,
      if (audioStr.isNotEmpty) audioStr,
      if (qualityStr.isNotEmpty) qualityStr,
    ].join(' • ');
  }
  String get url => links.isNotEmpty ? links[0] : '';
  String get type => stream.type;
  String get quality => video.quality;
  int get size => file.size;
  int get seeds => stream.seeds ?? 0;
  int get peers => 0;
  bool get cached => access.premiumize == true;

  factory OrionoidStream.fromJson(Map<String, dynamic> json) =>
      _$OrionoidStreamFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidStreamToJson(this);
}

@JsonSerializable()
class OrionoidFile {
  @JsonKey(name: 'hash', defaultValue: '')
  final String hash;
  @JsonKey(name: 'name', defaultValue: '')
  final String name;
  @JsonKey(name: 'size', defaultValue: 0)
  final int size;
  @JsonKey(name: 'pack', defaultValue: false)
  final bool pack;

  const OrionoidFile({
    required this.hash,
    required this.name,
    required this.size,
    required this.pack,
  });

  factory OrionoidFile.fromJson(Map<String, dynamic> json) =>
      _$OrionoidFileFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidFileToJson(this);
}

@JsonSerializable()
class OrionoidStreamInfo {
  @JsonKey(name: 'type', defaultValue: '')
  final String type;
  @JsonKey(name: 'origin', defaultValue: '')
  final String? origin;
  @JsonKey(name: 'source', defaultValue: '')
  final String? source;
  @JsonKey(name: 'hoster')
  final String? hoster;
  @JsonKey(name: 'seeds')
  final int? seeds;
  @JsonKey(name: 'time')
  final int? time;

  const OrionoidStreamInfo({
    required this.type,
    this.origin,
    this.source,
    this.hoster,
    this.seeds,
    this.time,
  });

  factory OrionoidStreamInfo.fromJson(Map<String, dynamic> json) =>
      _$OrionoidStreamInfoFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidStreamInfoToJson(this);
}

@JsonSerializable()
class OrionoidAccess {
  @JsonKey(name: 'direct', defaultValue: false)
  final bool direct;
  @JsonKey(name: 'premiumize')
  final bool? premiumize;
  @JsonKey(name: 'offcloud')
  final bool? offcloud;
  @JsonKey(name: 'torbox')
  final bool? torbox;
  @JsonKey(name: 'easydebrid')
  final bool? easydebrid;
  @JsonKey(name: 'realdebrid')
  final bool? realdebrid;
  @JsonKey(name: 'alldebrid')
  final bool? alldebrid;
  @JsonKey(name: 'debridlink')
  final bool? debridlink;

  const OrionoidAccess({
    required this.direct,
    this.premiumize,
    this.offcloud,
    this.torbox,
    this.easydebrid,
    this.realdebrid,
    this.alldebrid,
    this.debridlink,
  });

  factory OrionoidAccess.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAccessFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidAccessToJson(this);
}

@JsonSerializable()
class OrionoidVideo {
  @JsonKey(name: 'quality', defaultValue: '')
  final String quality;
  @JsonKey(name: 'codec')
  final String? codec;
  @JsonKey(name: '3d', defaultValue: false)
  final bool is3d;

  const OrionoidVideo({
    required this.quality,
    this.codec,
    required this.is3d,
  });

  factory OrionoidVideo.fromJson(Map<String, dynamic> json) =>
      _$OrionoidVideoFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidVideoToJson(this);
}

@JsonSerializable()
class OrionoidAudio {
  @JsonKey(name: 'type', defaultValue: '')
  final String type;
  @JsonKey(name: 'channels')
  final int? channels;
  @JsonKey(name: 'system')
  final String? system;
  @JsonKey(name: 'codec')
  final String? codec;
  @JsonKey(name: 'languages', defaultValue: [])
  final List<String> languages;

  const OrionoidAudio({
    required this.type,
    this.channels,
    this.system,
    this.codec,
    required this.languages,
  });

  factory OrionoidAudio.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAudioFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidAudioToJson(this);
}

@JsonSerializable()
class OrionoidSubtitle {
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'languages', defaultValue: [])
  final List<String> languages;

  const OrionoidSubtitle({
    this.type,
    required this.languages,
  });

  factory OrionoidSubtitle.fromJson(Map<String, dynamic> json) =>
      _$OrionoidSubtitleFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidSubtitleToJson(this);
}

@JsonSerializable()
class OrionoidMeta {
  @JsonKey(name: 'release')
  final String? release;
  @JsonKey(name: 'uploader')
  final String? uploader;
  @JsonKey(name: 'edition')
  final String? edition;

  const OrionoidMeta({
    this.release,
    this.uploader,
    this.edition,
  });

  factory OrionoidMeta.fromJson(Map<String, dynamic> json) =>
      _$OrionoidMetaFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidMetaToJson(this);
}

@JsonSerializable()
class OrionoidPopularity {
  @JsonKey(name: 'count', defaultValue: 0)
  final int count;
  @JsonKey(name: 'percent', defaultValue: 0.0)
  final double percent;

  const OrionoidPopularity({
    required this.count,
    required this.percent,
  });

  factory OrionoidPopularity.fromJson(Map<String, dynamic> json) =>
      _$OrionoidPopularityFromJson(json);

  Map<String, dynamic> toJson() => _$OrionoidPopularityToJson(this);
} 