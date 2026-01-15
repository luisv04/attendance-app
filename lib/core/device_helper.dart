import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceHelper {
  static String? _cachedDeviceIdHash;
  static String? _cachedAppVersion;
  static String? _cachedPlatform;

  /// Obtiene un hash estable del ID del dispositivo (no IMEI)
  static Future<String> getDeviceIdHash() async {
    if (_cachedDeviceIdHash != null) {
      return _cachedDeviceIdHash!;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Usar Android ID (estable, no requiere permisos)
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Usar identifierForVendor (estable por app)
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else {
        deviceId = 'unknown';
      }

      // Generar hash SHA-256 del device ID
      final bytes = utf8.encode(deviceId);
      final digest = sha256.convert(bytes);
      _cachedDeviceIdHash = digest.toString();

      return _cachedDeviceIdHash!;
    } catch (e) {
      // Fallback seguro en caso de error
      return 'error_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Obtiene la versión de la app
  static Future<String> getAppVersion() async {
    if (_cachedAppVersion != null) {
      return _cachedAppVersion!;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _cachedAppVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      return _cachedAppVersion!;
    } catch (e) {
      return '1.0.0+1';
    }
  }

  /// Obtiene la plataforma (android/ios)
  static String getPlatform() {
    if (_cachedPlatform != null) {
      return _cachedPlatform!;
    }

    _cachedPlatform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
    return _cachedPlatform!;
  }
}
