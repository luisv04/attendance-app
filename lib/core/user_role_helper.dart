/// Helper para verificar roles de usuario
class UserRoleHelper {
  /// Email del administrador
  static const String adminEmail = 'sistemas@jasu.us';

  /// Verifica si un email corresponde a un administrador
  /// 
  /// [email] Email del usuario a verificar
  /// 
  /// Retorna `true` si el email es de administrador, `false` en caso contrario
  static bool isAdmin(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    return email.toLowerCase() == adminEmail.toLowerCase();
  }
}
