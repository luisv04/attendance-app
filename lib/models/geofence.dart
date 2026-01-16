/// Modelo que representa un radio geográfico (geofence)
/// Define un área circular con un centro (latitud/longitud) y un radio en metros
class Geofence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusInMeters;

  Geofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
  });

  /// Factory constructor para crear Geofence desde JSON
  /// Útil para futura migración a archivos JSON o APIs
  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      radiusInMeters: json['radiusInMeters'] as double,
    );
  }

  /// Convierte Geofence a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusInMeters': radiusInMeters,
    };
  }
}
