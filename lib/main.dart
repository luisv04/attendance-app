import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'core/geofence_config.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_notice_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await StorageService.init();
  await GeofenceConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: JasuTheme.theme,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English (default)
        Locale('es'), // Spanish
      ],
      routes: {
        '/home': (context) => const HomeScreen(),
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  Future<void> _validateAndSignOutIfNeeded() async {
    final user = _authService.currentUser;
    if (user != null && !_authService.isValidDomain(user.email)) {
      // Dominio inválido: cerrar sesión
      await _authService.signOut();
    }
  }

  @override
  void initState() {
    super.initState();
    // Validar dominio al iniciar si hay un usuario autenticado
    _validateAndSignOutIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay un usuario autenticado, validar dominio antes de mostrar HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final email = user.email;

          // Validar dominio
          if (!_authService.isValidDomain(email)) {
            // Dominio inválido: cerrar sesión y mostrar login
            _validateAndSignOutIfNeeded();
            return const LoginScreen();
          }

          // Dominio válido: verificar aceptación de privacidad por usuario
          if (email != null) {
            final privacyAccepted = StorageService.isPrivacyAccepted(email);
            if (!privacyAccepted) {
              // No ha aceptado privacidad: mostrar pantalla bloqueante
              return PrivacyNoticeScreen(userEmail: email);
            }
          }

          // Privacidad aceptada: mostrar HomeScreen
          return const HomeScreen();
        }

        // Si no hay usuario, mostrar LoginScreen
        return const LoginScreen();
      },
    );
  }
}
