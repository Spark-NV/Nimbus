import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../premiumize/premiumize_api_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

final torrentHandlerServiceProvider = Provider<TorrentHandlerService>((ref) {
  return TorrentHandlerService(ref);
});

class TorrentHandlerService {
  final Ref _ref;
  final _winNotifyPlugin = WindowsNotification(
    applicationId: r"Nimbus"
  );
  final _logger = Logger();

  TorrentHandlerService(this._ref) {
    _initNotifications();
  }

  void _initNotifications() {
    _winNotifyPlugin.initNotificationCallBack((s) {
      _logger.d('Notification callback: ${s.argrument} ${s.userInput} ${s.eventType}');
    });
  }

  Future<String> _getIconPath() async {
    final supportDir = await getApplicationSupportDirectory();
    final iconPath = "${supportDir.path}/icon.png";
    
    if (!File(iconPath).existsSync()) {
      final iconFile = File(iconPath);
      await iconFile.create();
      
      final ByteData data = await rootBundle.load('assets/icon.png');
      final List<int> bytes = data.buffer.asUint8List();
      await iconFile.writeAsBytes(bytes);
    }
    
    return iconPath;
  }

  Future<void> handleIncomingTorrent(String? argument) async {
    if (argument == null) return;

    
    final hexBytes = argument.codeUnits.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

    final cleanedArgument = argument
        .replaceAll('"', '')
        .trim()
        .replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '')
        .trim();
    
    final cleanedHexBytes = cleanedArgument.codeUnits.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    
    final lowerPath = cleanedArgument.toLowerCase();

    if (cleanedArgument.toLowerCase().contains('magnet:?')) {
      await _handleMagnetLink(cleanedArgument);
    }
    else if (lowerPath.endsWith('.torrent')) {
      await _handleTorrentFile(cleanedArgument);
    } else {
      _logger.d('TorrentHandlerService: Unknown file type');
    }
  }

  Future<void> _handleMagnetLink(String magnetLink) async {
    try {
      
      final cleanMagnetLink = magnetLink.replaceAll('"', '').trim();
      
      try {
        final iconPath = await _getIconPath();
        
        final message = NotificationMessage.fromPluginTemplate(
          "magnet_${DateTime.now().millisecondsSinceEpoch}",
          "Nimbus",
          "Magnet link sent to Premiumize",
          image: iconPath,
          payload: {"action": "magnet_sent"}
        );
        await _winNotifyPlugin.showNotificationPluginTemplate(message);
      } catch (e) {
        _logger.e('TorrentHandlerService: Error showing notification', error: e);
      }
      
      final apiService = _ref.read(premiumizeApiServiceProvider);
      await apiService.createTransfer(cleanMagnetLink);
    } catch (e) {
      _logger.e('TorrentHandlerService: Error in _handleMagnetLink', error: e);
      rethrow;
    }
  }

  Future<void> _handleTorrentFile(String filePath) async {
    try {
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Torrent file not found: $filePath');
      }

      try {
        final iconPath = await _getIconPath();
        
        final message = NotificationMessage.fromPluginTemplate(
          "torrent_${DateTime.now().millisecondsSinceEpoch}",
          "Nimbus",
          "Torrent file sent to Premiumize",
          image: iconPath,
          payload: {"action": "torrent_sent"}
        );
        await _winNotifyPlugin.showNotificationPluginTemplate(message);
      } catch (e) {
        _logger.e('TorrentHandlerService: Error showing notification', error: e);
      }

      final apiService = _ref.read(premiumizeApiServiceProvider);
      
      final torrentContent = await file.readAsBytes();
      
      final base64Content = base64Encode(torrentContent);
      
      await apiService.createTorrentTransfer(base64Content);
    } catch (e) {
      _logger.e('TorrentHandlerService: Error in _handleTorrentFile', error: e);
      rethrow;
    }
  }
} 