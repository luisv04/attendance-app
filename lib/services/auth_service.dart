import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Dominio permitido
  static const String allowedDomain = '@jasu.us';

  User? get currentUser => _auth.currentUser;

  String? get userEmail => _auth.currentUser?.email;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Valida si el email pertenece al dominio permitido (@jasu.us)
  /// Case-insensitive: acepta mayúsculas y minúsculas
  bool isValidDomain(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    // Convertir a minúsculas para comparación case-insensitive
    final emailLower = email.toLowerCase();
    final domainLower = allowedDomain.toLowerCase();
    return emailLower.endsWith(domainLower);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Validar dominio del email después de autenticación
      final userEmail = userCredential.user?.email;
      if (!isValidDomain(userEmail)) {
        // Dominio inválido: cerrar sesión automáticamente
        await signOut();
        throw Exception(
            'Solo se permiten correos con dominio @jasu.us. Por favor inicia sesión con una cuenta corporativa.');
      }

      return userCredential;
    } catch (e) {
      // Si es nuestra excepción de dominio, relanzarla
      if (e.toString().contains('@jasu.us')) {
        rethrow;
      }
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}
