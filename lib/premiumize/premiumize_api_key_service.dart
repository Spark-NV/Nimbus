import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences.dart';
import 'package:logger/logger.dart';

part 'premiumize_api_key_service.g.dart';

final logger = Logger();

@riverpod
class PremiumizeApiKeyService extends _$PremiumizeApiKeyService {
  static const _key = 'premiumize_api_key';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> setApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, apiKey);
      state = const AsyncData(apiKey);
      logger.i('Premiumize API key saved successfully');
    } catch (e, stackTrace) {
      logger.e('Error saving Premiumize API key', error: e, stackTrace: stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> clearApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      state = const AsyncData(null);
      logger.i('Premiumize API key cleared successfully');
    } catch (e, stackTrace) {
      logger.e('Error clearing Premiumize API key', error: e, stackTrace: stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }
} 