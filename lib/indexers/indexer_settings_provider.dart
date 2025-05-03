import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'orionoid_settings.dart';

const _hideCachedResultsKey = 'torrentio_hide_cached_results';
const _torrentioEnabledKey = 'torrentio_enabled';
const _orionoidEnabledKey = 'orionoid_enabled';
const _prowlarrEnabledKey = 'prowlarr_enabled';

final logger = Logger();

final torrentioSettingsProvider = StateNotifierProvider<TorrentioSettingsNotifier, TorrentioSettings>((ref) {
  return TorrentioSettingsNotifier();
});

final indexerSettingsProvider =
    StateNotifierProvider<OrionoidSettingsNotifier, OrionoidSettings>((ref) {
  return OrionoidSettingsNotifier();
});

class TorrentioSettings {
  final bool hideCachedResults;
  final bool torrentioEnabled;
  final bool orionoidEnabled;
  final bool prowlarrEnabled;

  const TorrentioSettings({
    this.hideCachedResults = true,
    this.torrentioEnabled = true,
    this.orionoidEnabled = false,
    this.prowlarrEnabled = false,
  });

  TorrentioSettings copyWith({
    bool? hideCachedResults,
    bool? torrentioEnabled,
    bool? orionoidEnabled,
    bool? prowlarrEnabled,
  }) {
    return TorrentioSettings(
      hideCachedResults: hideCachedResults ?? this.hideCachedResults,
      torrentioEnabled: torrentioEnabled ?? this.torrentioEnabled,
      orionoidEnabled: orionoidEnabled ?? this.orionoidEnabled,
      prowlarrEnabled: prowlarrEnabled ?? this.prowlarrEnabled,
    );
  }
}

class TorrentioSettingsNotifier extends StateNotifier<TorrentioSettings> {
  TorrentioSettingsNotifier() : super(const TorrentioSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hideCachedResults = prefs.getBool(_hideCachedResultsKey) ?? true;
    final torrentioEnabled = prefs.getBool(_torrentioEnabledKey) ?? true;
    final orionoidEnabled = prefs.getBool(_orionoidEnabledKey) ?? false;
    final prowlarrEnabled = prefs.getBool(_prowlarrEnabledKey) ?? false;
    
    state = state.copyWith(
      hideCachedResults: hideCachedResults,
      torrentioEnabled: torrentioEnabled,
      orionoidEnabled: orionoidEnabled,
      prowlarrEnabled: prowlarrEnabled,
    );
  }

  Future<void> loadSettings() async {
    await _loadSettings();
  }

  Future<void> setHideCachedResults(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideCachedResultsKey, value);
    state = state.copyWith(hideCachedResults: value);
  }

  Future<void> setTorrentioEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_torrentioEnabledKey, value);
    state = state.copyWith(torrentioEnabled: value);
  }

  Future<void> setOrionoidEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orionoidEnabledKey, value);
    state = state.copyWith(orionoidEnabled: value);
  }

  Future<void> setProwlarrEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prowlarrEnabledKey, value);
    state = state.copyWith(prowlarrEnabled: value);
  }
} 

class OrionoidSettingsNotifier extends StateNotifier<OrionoidSettings> {
  static const _prefsKey = 'orionoid_settings';
  
  OrionoidSettingsNotifier() : super(OrionoidSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = OrionoidSettings.fromJson(json);
      }
    } catch (e) {
      state = OrionoidSettings();
    }
  }

  Future<void> loadSettings() async {
    await _loadSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.toJson());
      await prefs.setString(_prefsKey, jsonStr);
    } catch (e) {
    }
  }

  void setMovieLimit(int? limit) {
    state = state.copyWith(movieLimit: limit);
    _saveSettings();
  }

  void setTvShowLimit(int? limit) {
    state = state.copyWith(tvShowLimit: limit);
    _saveSettings();
  }

  void setMovieSortValue(SortValue value) {
    state = state.copyWith(movieSortValue: value);
    _saveSettings();
  }

  void setTvShowSortValue(SortValue value) {
    state = state.copyWith(tvShowSortValue: value);
    _saveSettings();
  }

  void setMovieSortOrder(SortOrder order) {
    state = state.copyWith(movieSortOrder: order);
    _saveSettings();
  }

  void setTvShowSortOrder(SortOrder order) {
    state = state.copyWith(tvShowSortOrder: order);
    _saveSettings();
  }

  void setMovieSizeLimits(int? minBytes, int? maxBytes) {
    state = state.copyWith(
      movieMinBytes: minBytes,
      movieMaxBytes: maxBytes,
    );
    _saveSettings();
  }

  void setTvShowSizeLimits(int? minBytes, int? maxBytes) {
    state = state.copyWith(
      tvShowMinBytes: minBytes,
      tvShowMaxBytes: maxBytes,
    );
    _saveSettings();
  }

  void setMovieSubtitleLanguage(String? language) {
    state = state.copyWith(movieSubtitleLanguage: language);
    _saveSettings();
  }

  void setTvShowSubtitleLanguage(String? language) {
    state = state.copyWith(tvShowSubtitleLanguage: language);
    _saveSettings();
  }

  void setMovieAudioLanguage(String? language) {
    state = state.copyWith(movieAudioLanguage: language);
    _saveSettings();
  }

  void setTvShowAudioLanguage(String? language) {
    state = state.copyWith(tvShowAudioLanguage: language);
    _saveSettings();
  }

  void setMovieSeederLimit(int? limit) {
    state = state.copyWith(movieSeederLimit: limit);
    _saveSettings();
  }

  void setTvShowSeederLimit(int? limit) {
    state = state.copyWith(tvShowSeederLimit: limit);
    _saveSettings();
  }
} 