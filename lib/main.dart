import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: JasuTheme.theme,
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

          // Dominio válido: mostrar HomeScreen
          return const HomeScreen();
        }

        // Si no hay usuario, mostrar LoginScreen
        return const LoginScreen();
      },
    );
  }
}
