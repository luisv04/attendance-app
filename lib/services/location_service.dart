import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime? gpsTimestamp;
  final String? errorMessage;

  LocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.gpsTimestamp,
    this.errorMessage,
  });
}

class LocationService {
  /// Obtiene la ubicación actual con validaciones estrictas
  /// Retorna LocationResult con success=true si la ubicación es válida
  /// o success=false con un mensaje de error descriptivo
  /// Fuerza siempre el uso de ubicación precisa (no aproximada)
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Verificar que el servicio de ubicación esté activo
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          errorMessage: 'GPS desactivado. Por favor activa la ubicación',
        );
      }

      // 2. Solicitar permiso de ubicación precisa usando permission_handler
      // En Android 12+, el sistema puede mostrar un diálogo para elegir entre precisa/aproximada
      // Verificaremos después si se seleccionó aproximada y rechazaremos
      PermissionStatus status = await Permission.location.status;
      
      if (status.isDenied) {
        status = await Permission.location.request();
        if (status.isDenied) {
          return LocationResult(
            success: false,
            errorMessage: 'Permisos de ubicación denegados',
          );
        }
      }

      if (status.isPermanentlyDenied) {
        return LocationResult(
          success: false,
          errorMessage:
              'Permisos de ubicación denegados permanentemente. Por favor habilítalos en la configuración',
        );
      }

      // Verificar que el permiso sea granted
      if (!status.isGranted) {
        return LocationResult(
          success: false,
          errorMessage: 'Permisos de ubicación no otorgados',
        );
      }

      // 3. Verificar también con Geolocator para compatibilidad
      LocationPermission geolocatorPermission = await Geolocator.checkPermission();
      if (geolocatorPermission == LocationPermission.denied) {
        geolocatorPermission = await Geolocator.requestPermission();
        if (geolocatorPermission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            errorMessage: 'Permisos de ubicación denegados',
          );
        }
      }

      if (geolocatorPermission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          errorMessage:
              'Permisos de ubicación denegados permanentemente. Por favor habilítalos en la configuración',
        );
      }

      // Verificar que el permiso sea granted
      if (geolocatorPermission != LocationPermission.whileInUse &&
          geolocatorPermission != LocationPermission.always) {
        return LocationResult(
          success: false,
          errorMessage: 'Permisos de ubicación no otorgados',
        );
      }

      // 4. Obtener ubicación con máxima precisión (GPS real obligatorio)
      // LocationAccuracy.bestForNavigation fuerza uso de GPS hardware, no red
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      // 5. Validaciones obligatorias de GPS real
      
      // 5.1. Validar que NO sea ubicación mockeada/falsa
      if (position.isMocked) {
        return LocationResult(
          success: false,
          errorMessage: 'Ubicación no válida. Desactiva aplicaciones de ubicación falsa',
        );
      }

      // 5.2. Validar que NO sea ubicación aproximada (Android 12+)
      // La ubicación aproximada típicamente tiene precisión > 100 metros
      // Si la precisión es muy baja, es probable que el usuario seleccionó "Aproximada"
      if (position.accuracy > 100) {
        return LocationResult(
          success: false,
          errorMessage: 'Se requiere ubicación PRECISA. Por favor ve a Configuración → Apps → Attendance App → Permisos → Ubicación y selecciona "Precisa"',
        );
      }

      // 5.3. Validar precisión máxima (25 metros) para GPS de calidad
      if (position.accuracy > 25) {
        return LocationResult(
          success: false,
          errorMessage: 'GPS no preciso. Por favor espera unos segundos y vuelve a intentar',
        );
      }

      // 4.3. Validar timestamp fresco (máximo 15 segundos)
      final now = DateTime.now();
      final locationTime = position.timestamp;
      final timeDifference = now.difference(locationTime).inSeconds;

      if (timeDifference > 15) {
        return LocationResult(
          success: false,
          errorMessage: 'Ubicación no fresca. Intenta nuevamente',
        );
      }

      // 5. Retornar ubicación válida con todos los datos
      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        gpsTimestamp: position.timestamp,
      );
    } catch (e) {
      return LocationResult(
        success: false,
        errorMessage: 'Error al obtener ubicación: ${e.toString()}',
      );
    }
  }
}
