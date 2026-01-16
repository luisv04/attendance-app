/// Modelo para datos de aceptación de privacidad
/// Se envía al webhook cuando el usuario acepta el aviso de privacidad
class PrivacyAcceptanceData {
  final bool accepted;
  final String version;
  final DateTime acceptedAt;
  final String userEmail;
  final String appVersion;

  PrivacyAcceptanceData({
    required this.accepted,
    required this.version,
    required this.acceptedAt,
    required this.userEmail,
    required this.appVersion,
  });

  /// Convierte a JSON para envío al webhook
  /// Estructura: { "privacy": { ... } }
  Map<String, dynamic> toJson() {
    return {
      'privacy': {
        'accepted': accepted,
        'version': version,
        'acceptedAt': acceptedAt.toUtc().toIso8601String(),
        'userEmail': userEmail,
        'appVersion': appVersion,
      },
    };
  }
}
