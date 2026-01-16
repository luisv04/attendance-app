/// Modelo para registro de historial de asistencia
/// Almacenado localmente para mostrar últimos 7 días
class AttendanceRecord {
  final String id;
  final DateTime timestamp;
  final String checkType;
  final double latitude;
  final double longitude;
  final String? comment;
  final String attendance; // 'yes' si está dentro de un radio, 'no' si está fuera
  final String? nearestGeofenceId; // ID de la geocerca más cercana usada

  AttendanceRecord({
    required this.id,
    required this.timestamp,
    required this.checkType,
    required this.latitude,
    required this.longitude,
    required this.attendance,
    this.comment,
    this.nearestGeofenceId,
  });

  /// Factory constructor desde JSON
  /// Mantiene compatibilidad con registros antiguos sin attendance
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      checkType: json['checkType'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      attendance: json['attendance'] as String? ?? 'no', // Default 'no' para compatibilidad
      comment: json['comment'] as String?,
      nearestGeofenceId: json['nearestGeofenceId'] as String?,
    );
  }

  /// Convierte a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'checkType': checkType,
      'latitude': latitude,
      'longitude': longitude,
      'attendance': attendance,
      if (nearestGeofenceId != null) 'nearestGeofenceId': nearestGeofenceId,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}
