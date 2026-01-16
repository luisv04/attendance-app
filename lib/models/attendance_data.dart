class AttendanceData {
  final String email;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? comment;
  final double accuracy;
  final double speed;
  final double heading;
  final DateTime gpsTimestamp;
  final DateTime sentAt;
  final String platform;
  final String appVersion;
  final String deviceIdHash;
  final String attendance; // 'yes' si está dentro de un radio, 'no' si está fuera
  final String checkType; // Tipo de checada: check_in, lunch_out, lunch_return, check_out
  final String timezone; // Zona horaria del dispositivo (ejemplo: "GMT-06:00")

  AttendanceData({
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.gpsTimestamp,
    required this.sentAt,
    required this.platform,
    required this.appVersion,
    required this.deviceIdHash,
    required this.attendance,
    required this.checkType,
    required this.timezone,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    // Formatear timestamp local con offset de zona horaria
    final localTimestamp = timestamp.toLocal();
    final offset = timestamp.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    final offsetString = '${hours >= 0 ? '+' : '-'}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final timestampWithOffset = '${localTimestamp.toIso8601String().split('.')[0]}$offsetString';
    
    return {
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestampWithOffset, // Hora local con offset
      'timezone': timezone, // Zona horaria en formato GMT
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'gpsTimestamp': gpsTimestamp.toUtc().toIso8601String(), // Mantener UTC para consistencia técnica
      'sentAt': sentAt.toUtc().toIso8601String(), // Mantener UTC para consistencia técnica
      'platform': platform,
      'appVersion': appVersion,
      'deviceIdHash': deviceIdHash,
      'attendance': attendance, // 'yes' o 'no'
      'checkType': checkType, // Tipo de checada
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}
