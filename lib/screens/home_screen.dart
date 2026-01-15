import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/webhook_service.dart';
import '../models/attendance_data.dart';
import '../widgets/attendance_button.dart';
import '../widgets/jasu_logo.dart';
import '../core/device_helper.dart';
import '../core/theme.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final WebhookService _webhookService = WebhookService();
  final TextEditingController _commentController = TextEditingController();

  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _registerAttendance() async {
    // Validar que hay un usuario autenticado
    final email = _authService.userEmail;
    if (email == null) {
      _showError('No hay usuario autenticado');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _isSuccess = false;
    });

    try {
      // 1. Obtener ubicación con validaciones estrictas
      final locationResult = await _locationService.getCurrentLocation();

      if (!locationResult.success) {
        _showError(locationResult.errorMessage ?? 'No se pudo obtener la ubicación');
        return;
      }

      // 2. Obtener información del dispositivo
      final deviceIdHash = await DeviceHelper.getDeviceIdHash();
      final appVersion = await DeviceHelper.getAppVersion();
      final platform = DeviceHelper.getPlatform();

      // 3. Crear datos de asistencia con todas las señales
      final attendanceData = AttendanceData(
        email: email,
        latitude: locationResult.latitude!,
        longitude: locationResult.longitude!,
        timestamp: DateTime.now(),
        accuracy: locationResult.accuracy ?? 0.0,
        speed: locationResult.speed ?? 0.0,
        heading: locationResult.heading ?? 0.0,
        gpsTimestamp: locationResult.gpsTimestamp ?? DateTime.now(),
        sentAt: DateTime.now(),
        platform: platform,
        appVersion: appVersion,
        deviceIdHash: deviceIdHash,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      // 4. Enviar al webhook
      final success = await _webhookService.sendAttendance(attendanceData);

      if (success) {
        setState(() {
          _isSuccess = true;
          _statusMessage = 'Asistencia registrada exitosamente';
          _commentController.clear();
        });

        // Limpiar mensaje después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _statusMessage = null;
            });
          }
        });
      } else {
        _showError('Error al enviar la asistencia');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _statusMessage = message;
      _isSuccess = false;
    });

    // Mostrar también un SnackBar para mejor visibilidad
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.userEmail ?? 'Usuario';

    return Scaffold(
      backgroundColor: JasuTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60), // Espacio para el botón de logout

                    // Logo JASU circular
                    const JasuLogo(),
                    const SizedBox(height: 24),

                    // Título "Assistant Jasu"
                    const Text(
                      'Assistant Jasu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: JasuTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email del usuario con ícono de persona
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          color: JasuTheme.darkGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: JasuTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Campo de comentarios
                    TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comments (optional)',
                        hintText: '',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      enabled: !_isProcessing,
                    ),
                    const SizedBox(height: 32),

                    // Botón "Send Assistant"
                    AttendanceButton(
                      onPressed: _registerAttendance,
                      isLoading: _isProcessing,
                      isDisabled: _isProcessing,
                    ),

                    const SizedBox(height: 24),

                    // Mensaje de estado
                    if (_statusMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isSuccess
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccess ? Icons.check_circle : Icons.error,
                              color: _isSuccess ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _statusMessage!,
                                style: TextStyle(
                                  color: _isSuccess
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Botón de logout en esquina superior derecha
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: JasuTheme.darkGreen,
                  size: 24,
                ),
                onPressed: _signOut,
                tooltip: 'Cerrar sesión',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
