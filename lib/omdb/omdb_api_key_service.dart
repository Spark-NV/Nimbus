import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

part 'omdb_api_key_service.g.dart';

final logger = Logger();

@riverpod
class OmdbApiKeyService extends _$OmdbApiKeyService {
  static const String _apiKeyKey = 'omdb_api_key';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_apiKeyKey);
    return key;
  }

  Future<void> setApiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, key);
      state = AsyncData(key);
      logger.i('OMDB API key saved successfully');
    } catch (e) {
      logger.e('Error saving OMDB API key', error: e);
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> clearApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
      state = const AsyncData(null);
      logger.i('OMDB API key cleared successfully');
    } catch (e) {
      logger.e('Error clearing OMDB API key', error: e);
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
} 