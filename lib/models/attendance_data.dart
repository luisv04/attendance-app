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
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'gpsTimestamp': gpsTimestamp.toUtc().toIso8601String(),
      'sentAt': sentAt.toUtc().toIso8601String(),
      'platform': platform,
      'appVersion': appVersion,
      'deviceIdHash': deviceIdHash,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}
