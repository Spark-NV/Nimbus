import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

part 'orionoid_api_key_service.g.dart';

final logger = Logger();

@riverpod
class OrionoidApiKeyService extends _$OrionoidApiKeyService {
  static const _key = 'orionoid_api_key';
  SharedPreferences? _prefs;

  @override
  Future<String?> build() async {
    _prefs = await SharedPreferences.getInstance();
    final apiKey = _prefs?.getString(_key);
    return apiKey;
  }

  Future<void> setApiKey(String apiKey) async {
    try {
      logger.i('Setting Orionoid API key: ${apiKey.substring(0, 4)}...');
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs?.setString(_key, apiKey);
      state = AsyncValue.data(apiKey);
      logger.i('Orionoid API key saved successfully');
    } catch (e, stackTrace) {
      logger.e('Error saving Orionoid API key', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearApiKey() async {
    try {
      logger.i('Clearing Orionoid API key');
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs?.remove(_key);
      state = AsyncValue.data(null);
      logger.i('Orionoid API key cleared successfully');
    } catch (e, stackTrace) {
      logger.e('Error clearing Orionoid API key', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
} 