import 'package:geolocator/geolocator.dart';
import '../models/geofence.dart';
import '../services/storage_service.dart';

/// Configuración de geofences (radios geográficos)
/// Contiene la lista de radios configurados y métodos para validar ubicaciones
/// Carga desde SharedPreferences, con fallback a lista estática si no hay datos guardados
class GeofenceConfig {
  /// Lista de radios geográficos por defecto (fallback)
  /// Se usa solo si no hay datos guardados en SharedPreferences
  static final List<Geofence> _defaultGeofences = [
    Geofence(
      id: 'office_1',
      name: 'Oficina Principal',
      latitude: 19.4326, // Ejemplo: Ciudad de México
      longitude: -99.1332,
      radiusInMeters: 100.0, // 100 metros de radio
    ),
    Geofence(
      id: 'office_2',
      name: 'Oficina Secundaria',
      latitude: 19.4426,
      longitude: -99.1432,
      radiusInMeters: 150.0, // 150 metros de radio
    ),
  ];

  /// Obtiene la lista de geofences
  /// Carga desde SharedPreferences, o usa la lista por defecto si no hay datos
  static List<Geofence> get geofences {
    final saved = StorageService.getGeofences();
    if (saved.isNotEmpty) {
      return saved;
    }
    // Si no hay datos guardados, usar lista por defecto
    // Y guardarla para futuras referencias
    StorageService.saveGeofences(_defaultGeofences);
    return _defaultGeofences;
  }

  /// Inicializa los geofences (carga desde storage o usa defaults)
  /// Debe llamarse al iniciar la app
  static Future<void> initialize() async {
    await StorageService.init();
    final saved = StorageService.getGeofences();
    if (saved.isEmpty) {
      // Si no hay datos guardados, guardar los defaults
      await StorageService.saveGeofences(_defaultGeofences);
    }
  }

  /// Verifica si una ubicación está dentro de algún radio configurado
  /// 
  /// [latitude] Latitud de la ubicación a validar
  /// [longitude] Longitud de la ubicación a validar
  /// 
  /// Retorna `true` si la ubicación está dentro de al menos un radio,
  /// `false` si está fuera de todos los radios
  static bool isWithinAnyGeofence(double latitude, double longitude) {
    for (final geofence in geofences) {
      // Calcular distancia entre el centro del radio y la ubicación del usuario
      final distance = Geolocator.distanceBetween(
        geofence.latitude,
        geofence.longitude,
        latitude,
        longitude,
      );

      // Si la distancia es menor o igual al radio, está dentro del geofence
      if (distance <= geofence.radiusInMeters) {
        return true; // Está dentro de este radio
      }
    }
    return false; // No está dentro de ningún radio
  }

  /// Obtiene la geocerca más cercana a la ubicación dada
  /// Retorna la geocerca completa o null si no hay geocercas configuradas
  static Geofence? getNearestGeofence(double latitude, double longitude) {
    if (geofences.isEmpty) {
      return null;
    }

    double? minDistance;
    Geofence? nearestGeofence;

    for (final geofence in geofences) {
      final distance = Geolocator.distanceBetween(
        geofence.latitude,
        geofence.longitude,
        latitude,
        longitude,
      );

      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearestGeofence = geofence;
      }
    }

    return nearestGeofence;
  }

  /// Obtiene el nombre del radio más cercano a la ubicación dada
  /// Útil para logging o mostrar información al usuario
  /// 
  /// Retorna el nombre del radio más cercano, o `null` si no hay radios configurados
  static String? getNearestGeofenceName(double latitude, double longitude) {
    final nearest = getNearestGeofence(latitude, longitude);
    return nearest?.name;
  }

  /// Obtiene la distancia al radio más cercano en metros
  /// Útil para debugging o mostrar información al usuario
  /// 
  /// Retorna la distancia en metros al radio más cercano, o `null` si no hay radios
  static double? getDistanceToNearestGeofence(
      double latitude, double longitude) {
    if (geofences.isEmpty) {
      return null;
    }

    double? minDistance;

    for (final geofence in geofences) {
      final distance = Geolocator.distanceBetween(
        geofence.latitude,
        geofence.longitude,
        latitude,
        longitude,
      );

      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }
}
