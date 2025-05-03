import 'dart:ffi';
import 'dart:io';
import 'package:win32_registry/win32_registry.dart';
import 'package:logger/logger.dart';

class RegistryService {
  final _logger = Logger();
  final String _appName = 'Nimbus';
  late String _appPath;

  RegistryService() {
    _appPath = Platform.resolvedExecutable;
  }

  Future<bool> isUserAdmin() async {
    final testFile = File('C:\\Windows\\Temp\\admin_nimbus_test.tmp');

    try {
      await testFile.writeAsString('');
      final exists = await testFile.exists();
      if (exists) await testFile.delete();
      
      return exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setupRegistryHandlers() async {
    try {
      if (!await isUserAdmin()) {
        return false;
      }

      await _registerMagnetHandler();
      await _registerTorrentHandler();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _registerMagnetHandler() async {
    try {
      final magnetKey = Registry.openPath(
        RegistryHive.classesRoot,
        path: 'magnet',
        desiredAccessRights: AccessRights.allAccess,
      );
      
      magnetKey.createValue(
        RegistryValue(
          '',
          RegistryValueType.string,
          _appName,
        ),
      );

      final commandKey = Registry.openPath(
        RegistryHive.classesRoot,
        path: 'magnet\\shell\\open\\command',
        desiredAccessRights: AccessRights.allAccess,
      );
      
      commandKey.createValue(
        RegistryValue(
          '',
          RegistryValueType.string,
          '"$_appPath" "%1"',
        ),
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<void> _registerTorrentHandler() async {
    try {
      final torrentKey = Registry.openPath(
        RegistryHive.classesRoot,
        path: '.torrent',
        desiredAccessRights: AccessRights.allAccess,
      );
      
      torrentKey.createValue(
        RegistryValue(
          '',
          RegistryValueType.string,
          _appName,
        ),
      );

      final commandKey = Registry.openPath(
        RegistryHive.classesRoot,
        path: '.torrent\\shell\\open\\command',
        desiredAccessRights: AccessRights.allAccess,
      );
      
      commandKey.createValue(
        RegistryValue(
          '',
          RegistryValueType.string,
          '"$_appPath" "%1"',
        ),
      );

    } catch (e) {
      rethrow;
    }
  }
} 