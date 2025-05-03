import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../indexers/indexer_settings_provider.dart';
import '../indexers/orionoid_api_service.dart';
import '../premiumize/premiumize_api_service.dart';
import '../omdb/omdb_api_key_service.dart';
import '../indexers/orionoid_api_key_service.dart';

final logger = Logger();

final settingsInitializerProvider = FutureProvider<void>((ref) async {
  logger.i('Initializing all settings...');
  
  try {
    logger.i('Initializing Torrentio settings...');
    final torrentioSettings = ref.read(torrentioSettingsProvider.notifier);
    await torrentioSettings.loadSettings();
    
    logger.i('Initializing Orionoid settings...');
    final orionoidSettings = ref.read(indexerSettingsProvider.notifier);
    await orionoidSettings.loadSettings();
    
    logger.i('Initializing API services...');
    await ref.read(premiumizeApiServiceProvider).initialize();
    await ref.read(orionoidApiServiceProvider).initialize();
    
    logger.i('Pre-loading API keys...');
    await ref.read(omdbApiKeyServiceProvider.future);
    await ref.read(orionoidApiKeyServiceProvider.future);
    
    logger.i('All settings initialized successfully');
  } catch (e, stackTrace) {
    logger.e('Error initializing settings', error: e, stackTrace: stackTrace);
    rethrow;
  }
}); 