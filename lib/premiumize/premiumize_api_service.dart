import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premiumize_transfer.dart';
import 'dart:convert';

part 'premiumize_api_service.g.dart';

@riverpod
PremiumizeApiService premiumizeApiService(PremiumizeApiServiceRef ref) {
  return PremiumizeApiService();
}

class PremiumizeApiService {
  final Dio _dio;
  final Logger _logger;
  SharedPreferences? _prefs;
  static const String _baseUrl = 'https://www.premiumize.me/api';
  static const String _apiKeyPref = 'premiumize_api_key';

  PremiumizeApiService({
    Dio? dio,
    Logger? logger,
  })  : _dio = dio ?? Dio(),
        _logger = logger ?? Logger() {
    _dio.options.baseUrl = _baseUrl;
  }

  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  String? get _apiKey => _prefs?.getString(_apiKeyPref);

  String? get apiKey => _apiKey;

  bool get hasApiKey => _apiKey != null && _apiKey!.length >= 4;

  Future<void> setApiKey(String apiKey) async {
    await initialize();
    await _prefs?.setString(_apiKeyPref, apiKey);
  }

  Future<void> clearApiKey() async {
    await initialize();
    await _prefs?.remove(_apiKeyPref);
    _logger.i('Premiumize API key cleared');
  }

  Future<Map<String, dynamic>> getAccountInfo() async {
    await initialize();
    try {
      final response = await _dio.get(
        '/account/info',
        queryParameters: {'apikey': _apiKey},
      );
      _logger.d('Account info response: ${response.data}');
      return response.data;
    } catch (e) {
      _logger.e('Error fetching account info', error: e);
      rethrow;
    }
  }

  Future<List<PremiumizeTransfer>> getTransfers() async {
    await initialize();
    try {
      _logger.i('Fetching Premiumize transfers');
      final response = await _dio.get(
        '/transfer/list',
        queryParameters: {'apikey': _apiKey},
      );
      _logger.d('Premiumize API Response: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> transfers = response.data['transfers'] ?? [];
        return transfers.map((json) => PremiumizeTransfer.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch transfers');
    } catch (e) {
      _logger.e('Error fetching transfers', error: e);
      rethrow;
    }
  }

  Future<bool> deleteTransfer(String id) async {
    await initialize();
    try {
      _logger.i('Deleting Premiumize transfer: $id');
      final queryParams = {
        'apikey': _apiKey,
        'id': id,
      };
      _logger.d('Delete transfer request params: $queryParams');
      
      final response = await _dio.post(
        '/transfer/delete',
        queryParameters: queryParams,
      );
      _logger.d('Premiumize Delete Response: ${response.data}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete transfer');
      }
      return true;
    } catch (e) {
      _logger.e('Error deleting transfer', error: e);
      rethrow;
    }
  }

  Future<bool> clearFinishedTransfers() async {
    await initialize();
    try {
      _logger.i('Clearing finished Premiumize transfers');
      final response = await _dio.post(
        '/transfer/clearfinished',
      );
      _logger.d('Premiumize Clear Finished Response: ${response.data}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to clear finished transfers');
      }
      return true;
    } catch (e) {
      _logger.e('Error clearing finished transfers', error: e);
      rethrow;
    }
  }

  Future<bool> createTransfer(String magnetLink) async {
    await initialize();
    try {
      if (!hasApiKey) {
        throw Exception('Premiumize API key not found. Please set it in settings.');
      }

      _logger.i('Creating Premiumize transfer from source: $magnetLink');
      final queryParams = {
        'apikey': _apiKey,
        'src': magnetLink,
      };
      _logger.d('Create transfer request params: $queryParams');
      
      final response = await _dio.post(
        '/transfer/create',
        queryParameters: queryParams,
      );
      _logger.d('Premiumize Create Transfer Response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'Failed to create transfer');
        }
        return data['status'] == 'success';
      }
      throw Exception('Failed to create transfer');
    } catch (e) {
      _logger.e('Error creating transfer', error: e);
      rethrow;
    }
  }

  Future<bool> createTorrentTransfer(String base64Content) async {
    await initialize();
    try {
      if (!hasApiKey) {
        throw Exception('Premiumize API key not found. Please set it in settings.');
      }

      _logger.i('Creating Premiumize transfer from torrent file');
      final formData = FormData.fromMap({
        'apikey': _apiKey,
        'file': MultipartFile.fromBytes(
          base64Decode(base64Content),
          filename: 'torrent.torrent',
        ),
      });
      _logger.d('Create torrent transfer request params: ${formData.fields}');
      
      final response = await _dio.post(
        '/transfer/create',
        data: formData,
      );
      _logger.d('Premiumize Create Torrent Transfer Response: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'Failed to create transfer');
        }
        return data['status'] == 'success';
      }
      throw Exception('Failed to create transfer');
    } catch (e) {
      _logger.e('Error creating torrent transfer', error: e);
      rethrow;
    }
  }
} 