enum SortValue {
  filesize,
  streamseeds,
  videoquality,
  best,
  shuffle,
  timeadded,
  timeupdated,
  popularity,
  none,
}

enum SortOrder {
  ascending,
  descending,
}

class OrionoidSettings {
  final int? movieLimit;
  final int? tvShowLimit;
  final SortValue movieSortValue;
  final SortValue tvShowSortValue;
  final SortOrder movieSortOrder;
  final SortOrder tvShowSortOrder;
  final int? movieMinBytes;
  final int? movieMaxBytes;
  final int? tvShowMinBytes;
  final int? tvShowMaxBytes;
  final String? movieSubtitleLanguage;
  final String? tvShowSubtitleLanguage;
  final String? movieAudioLanguage;
  final String? tvShowAudioLanguage;
  final int? movieSeederLimit;
  final int? tvShowSeederLimit;

  const OrionoidSettings({
    this.movieLimit = 100,
    this.tvShowLimit = 100,
    this.movieSortValue = SortValue.filesize,
    this.tvShowSortValue = SortValue.filesize,
    this.movieSortOrder = SortOrder.descending,
    this.tvShowSortOrder = SortOrder.descending,
    this.movieMinBytes = 100,
    this.movieMaxBytes = 10000,
    this.tvShowMinBytes = 100,
    this.tvShowMaxBytes = 10000,
    this.movieSubtitleLanguage,
    this.tvShowSubtitleLanguage,
    this.movieAudioLanguage,
    this.tvShowAudioLanguage,
    this.movieSeederLimit,
    this.tvShowSeederLimit,
  });

  factory OrionoidSettings.fromJson(Map<String, dynamic> json) {
    return OrionoidSettings(
      movieLimit: json['movieLimit'] as int?,
      tvShowLimit: json['tvShowLimit'] as int?,
      movieSortValue: SortValue.values.firstWhere(
        (e) => e.toString() == json['movieSortValue'],
        orElse: () => SortValue.none,
      ),
      tvShowSortValue: SortValue.values.firstWhere(
        (e) => e.toString() == json['tvShowSortValue'],
        orElse: () => SortValue.none,
      ),
      movieSortOrder: SortOrder.values.firstWhere(
        (e) => e.toString() == json['movieSortOrder'],
        orElse: () => SortOrder.descending,
      ),
      tvShowSortOrder: SortOrder.values.firstWhere(
        (e) => e.toString() == json['tvShowSortOrder'],
        orElse: () => SortOrder.descending,
      ),
      movieMinBytes: json['movieMinBytes'] as int?,
      movieMaxBytes: json['movieMaxBytes'] as int?,
      tvShowMinBytes: json['tvShowMinBytes'] as int?,
      tvShowMaxBytes: json['tvShowMaxBytes'] as int?,
      movieSubtitleLanguage: json['movieSubtitleLanguage'] as String?,
      tvShowSubtitleLanguage: json['tvShowSubtitleLanguage'] as String?,
      movieAudioLanguage: json['movieAudioLanguage'] as String?,
      tvShowAudioLanguage: json['tvShowAudioLanguage'] as String?,
      movieSeederLimit: json['movieSeederLimit'] as int?,
      tvShowSeederLimit: json['tvShowSeederLimit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieLimit': movieLimit,
      'tvShowLimit': tvShowLimit,
      'movieSortValue': movieSortValue.toString(),
      'tvShowSortValue': tvShowSortValue.toString(),
      'movieSortOrder': movieSortOrder.toString(),
      'tvShowSortOrder': tvShowSortOrder.toString(),
      'movieMinBytes': movieMinBytes,
      'movieMaxBytes': movieMaxBytes,
      'tvShowMinBytes': tvShowMinBytes,
      'tvShowMaxBytes': tvShowMaxBytes,
      'movieSubtitleLanguage': movieSubtitleLanguage,
      'tvShowSubtitleLanguage': tvShowSubtitleLanguage,
      'movieAudioLanguage': movieAudioLanguage,
      'tvShowAudioLanguage': tvShowAudioLanguage,
      'movieSeederLimit': movieSeederLimit,
      'tvShowSeederLimit': tvShowSeederLimit,
    };
  }

  OrionoidSettings copyWith({
    int? movieLimit,
    int? tvShowLimit,
    SortValue? movieSortValue,
    SortValue? tvShowSortValue,
    SortOrder? movieSortOrder,
    SortOrder? tvShowSortOrder,
    int? movieMinBytes,
    int? movieMaxBytes,
    int? tvShowMinBytes,
    int? tvShowMaxBytes,
    String? movieSubtitleLanguage,
    String? tvShowSubtitleLanguage,
    String? movieAudioLanguage,
    String? tvShowAudioLanguage,
    int? movieSeederLimit,
    int? tvShowSeederLimit,
  }) {
    return OrionoidSettings(
      movieLimit: movieLimit ?? this.movieLimit,
      tvShowLimit: tvShowLimit ?? this.tvShowLimit,
      movieSortValue: movieSortValue ?? this.movieSortValue,
      tvShowSortValue: tvShowSortValue ?? this.tvShowSortValue,
      movieSortOrder: movieSortOrder ?? this.movieSortOrder,
      tvShowSortOrder: tvShowSortOrder ?? this.tvShowSortOrder,
      movieMinBytes: movieMinBytes ?? this.movieMinBytes,
      movieMaxBytes: movieMaxBytes ?? this.movieMaxBytes,
      tvShowMinBytes: tvShowMinBytes ?? this.tvShowMinBytes,
      tvShowMaxBytes: tvShowMaxBytes ?? this.tvShowMaxBytes,
      movieSubtitleLanguage: movieSubtitleLanguage ?? this.movieSubtitleLanguage,
      tvShowSubtitleLanguage: tvShowSubtitleLanguage ?? this.tvShowSubtitleLanguage,
      movieAudioLanguage: movieAudioLanguage ?? this.movieAudioLanguage,
      tvShowAudioLanguage: tvShowAudioLanguage ?? this.tvShowAudioLanguage,
      movieSeederLimit: movieSeederLimit ?? this.movieSeederLimit,
      tvShowSeederLimit: tvShowSeederLimit ?? this.tvShowSeederLimit,
    );
  }
} 