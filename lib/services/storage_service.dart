import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/geofence.dart';
import '../models/attendance_record.dart';

/// Servicio para manejar almacenamiento local usando SharedPreferences
/// Maneja: aceptación de privacidad, historial, geofences, último tipo de checada
class StorageService {
  static const String _keyLastCheckType = 'last_check_type';
  static const String _keyHistory = 'attendance_history';
  static const String _keyGeofences = 'geofences';

  static SharedPreferences? _prefs;

  /// Inicializa SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Genera la key de privacidad para un usuario específico
  static String _getPrivacyKey(String userEmail) {
    return 'privacyAccepted_${userEmail.toLowerCase()}';
  }

  /// Genera la key para verificar si se envió el webhook de privacidad
  static String _getPrivacySentKey(String userEmail) {
    return 'privacySent_${userEmail.toLowerCase()}';
  }

  /// Verifica si el usuario ha aceptado el aviso de privacidad
  /// [userEmail] Email del usuario autenticado
  static bool isPrivacyAccepted(String userEmail) {
    if (userEmail.isEmpty) return false;
    final key = _getPrivacyKey(userEmail);
    return _prefs?.getBool(key) ?? false;
  }

  /// Guarda la aceptación del aviso de privacidad para un usuario específico
  /// [userEmail] Email del usuario autenticado
  /// [accepted] true si aceptó, false si no
  static Future<bool> setPrivacyAccepted(String userEmail, bool accepted) async {
    if (userEmail.isEmpty) return false;
    await init();
    final key = _getPrivacyKey(userEmail);
    return await _prefs!.setBool(key, accepted);
  }

  /// Verifica si ya se envió el webhook de aceptación de privacidad para este usuario
  /// [userEmail] Email del usuario autenticado
  static bool hasPrivacyBeenSent(String userEmail) {
    if (userEmail.isEmpty) return false;
    final key = _getPrivacySentKey(userEmail);
    return _prefs?.getBool(key) ?? false;
  }

  /// Marca que se envió el webhook de aceptación de privacidad para este usuario
  /// [userEmail] Email del usuario autenticado
  static Future<bool> setPrivacySent(String userEmail, bool sent) async {
    if (userEmail.isEmpty) return false;
    await init();
    final key = _getPrivacySentKey(userEmail);
    return await _prefs!.setBool(key, sent);
  }

  /// Obtiene el último tipo de checada enviado
  static String? getLastCheckType() {
    return _prefs?.getString(_keyLastCheckType);
  }

  /// Guarda el último tipo de checada enviado
  static Future<bool> setLastCheckType(String checkType) async {
    await init();
    return await _prefs!.setString(_keyLastCheckType, checkType);
  }

  /// Guarda un registro de asistencia en el historial
  static Future<bool> saveAttendanceRecord(AttendanceRecord record) async {
    await init();
    final history = getAttendanceHistory();
    
    // Agregar nuevo registro al inicio
    history.insert(0, record);
    
    // Limpiar registros mayores a 7 días
    final now = DateTime.now();
    history.removeWhere((record) {
      final daysDiff = now.difference(record.timestamp).inDays;
      return daysDiff > 7;
    });
    
    // Guardar historial actualizado
    final jsonList = history.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);
    return await _prefs!.setString(_keyHistory, jsonString);
  }

  /// Obtiene el historial de asistencia (últimos 7 días)
  static List<AttendanceRecord> getAttendanceHistory() {
    final jsonString = _prefs?.getString(_keyHistory);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => AttendanceRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene la última checada del historial del usuario
  /// Retorna null si no hay historial
  static AttendanceRecord? getLastAttendanceRecord() {
    final history = getAttendanceHistory();
    if (history.isEmpty) {
      return null;
    }
    // El historial ya está ordenado con el más reciente primero
    return history.first;
  }

  /// Limpia el historial de asistencia
  static Future<bool> clearHistory() async {
    await init();
    return await _prefs!.remove(_keyHistory);
  }

  /// Guarda la lista de geofences
  static Future<bool> saveGeofences(List<Geofence> geofences) async {
    await init();
    final jsonList = geofences.map((g) => g.toJson()).toList();
    final jsonString = json.encode(jsonList);
    return await _prefs!.setString(_keyGeofences, jsonString);
  }

  /// Obtiene la lista de geofences guardados
  static List<Geofence> getGeofences() {
    final jsonString = _prefs?.getString(_keyGeofences);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => Geofence.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Limpia todos los datos guardados (útil para testing)
  static Future<bool> clearAll() async {
    await init();
    return await _prefs!.clear();
  }
}
