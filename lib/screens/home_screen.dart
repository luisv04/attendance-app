import 'package:flutter/material.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/webhook_service.dart';
import '../services/storage_service.dart';
import '../models/attendance_data.dart';
import '../models/check_type.dart';
import '../models/attendance_record.dart';
import '../widgets/attendance_button.dart';
import '../widgets/jasu_logo.dart';
import '../core/device_helper.dart';
import '../core/geofence_config.dart';
import '../core/user_role_helper.dart';
import '../core/check_type_suggester.dart';
import '../widgets/attendance_verification_modal.dart';
import '../core/theme.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'admin/locations_screen.dart';

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
  CheckType? _selectedCheckType;
  bool _hasSuggestion = false; // Indica si hay un tipo sugerido

  @override
  void initState() {
    super.initState();
    // Preseleccionar tipo sugerido basado en historial
    _loadSuggestedType();
  }

  void _loadSuggestedType() {
    final suggestedType = CheckTypeSuggester.suggestNextType();
    if (suggestedType != null) {
      setState(() {
        _selectedCheckType = suggestedType;
        _hasSuggestion = true;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _registerAttendance() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Validar que hay un usuario autenticado
    final email = _authService.userEmail;
    if (email == null) {
      _showError(l10n.noAuthenticatedUser);
      return;
    }

    // Validar que se haya seleccionado un tipo de checada
    if (_selectedCheckType == null) {
      _showError(l10n.selectCheckType);
      return;
    }

    // Validar que no sea el mismo tipo consecutivo
    final lastCheckType = StorageService.getLastCheckType();
    if (lastCheckType == _selectedCheckType!.value) {
      _showError(l10n.duplicateCheckTypeError);
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
        _showError(locationResult.errorMessage ?? l10n.errorSendingAttendance);
        return;
      }

      // 2. Validar si la ubicación está dentro de algún radio (geofence)
      final isWithinGeofence = GeofenceConfig.isWithinAnyGeofence(
        locationResult.latitude!,
        locationResult.longitude!,
      );

      // 3. Obtener información del dispositivo
      final deviceIdHash = await DeviceHelper.getDeviceIdHash();
      final appVersion = await DeviceHelper.getAppVersion();
      final platform = DeviceHelper.getPlatform();

      // 4. Obtener hora local y zona horaria
      final now = DateTime.now();
      final timezoneOffset = now.timeZoneOffset;
      final hours = timezoneOffset.inHours;
      final minutes = timezoneOffset.inMinutes.remainder(60).abs();
      final timezoneString = 'GMT${hours >= 0 ? '+' : '-'}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

      // 5. Crear datos de asistencia con todas las señales
      final attendanceData = AttendanceData(
        email: email,
        latitude: locationResult.latitude!,
        longitude: locationResult.longitude!,
        timestamp: now, // Hora local del dispositivo
        accuracy: locationResult.accuracy ?? 0.0,
        speed: locationResult.speed ?? 0.0,
        heading: locationResult.heading ?? 0.0,
        gpsTimestamp: locationResult.gpsTimestamp ?? now,
        sentAt: DateTime.now(),
        platform: platform,
        appVersion: appVersion,
        deviceIdHash: deviceIdHash,
        attendance: isWithinGeofence ? 'yes' : 'no',
        checkType: _selectedCheckType!.value,
        timezone: timezoneString, // Zona horaria en formato GMT
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      // 5. Enviar al webhook
      final success = await _webhookService.sendAttendance(attendanceData);

      if (success) {
        // Guardar último tipo de checada
        await StorageService.setLastCheckType(_selectedCheckType!.value);
        
        // Obtener geocerca más cercana para el historial
        final nearestGeofence = GeofenceConfig.getNearestGeofence(
          locationResult.latitude!,
          locationResult.longitude!,
        );
        
        // Guardar en historial con attendance y geocerca
        final record = AttendanceRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: now,
          checkType: _selectedCheckType!.value,
          latitude: locationResult.latitude!,
          longitude: locationResult.longitude!,
          attendance: attendanceData.attendance, // 'yes' o 'no'
          nearestGeofenceId: nearestGeofence?.id, // ID de la geocerca más cercana
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );
        await StorageService.saveAttendanceRecord(record);

        setState(() {
          _isSuccess = true;
          _statusMessage = l10n.attendanceRegisteredSuccessfully;
          _commentController.clear();
        });

        // Mostrar modal de verificación
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AttendanceVerificationModal(
              latitude: locationResult.latitude!,
              longitude: locationResult.longitude!,
              attendance: attendanceData.attendance,
              nearestGeofenceId: nearestGeofence?.id,
            ),
          );
        }

        // Limpiar mensaje después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _statusMessage = null;
            });
          }
        });
      } else {
        _showError(l10n.errorSendingAttendance);
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
    final l10n = AppLocalizations.of(context)!;
    final email = _authService.userEmail ?? 'Usuario';
    final isAdmin = UserRoleHelper.isAdmin(email);
    final locale = Localizations.localeOf(context).languageCode;

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

                    // Título "Attendance Jasu"
                    Text(
                      l10n.attendanceJasu,
                      style: const TextStyle(
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

                    // Selector de tipo de checada
                    DropdownButtonFormField<CheckType>(
                      value: _selectedCheckType,
                      decoration: InputDecoration(
                        labelText: l10n.selectCheckType,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(Icons.access_time, color: JasuTheme.darkGreen),
                      ),
                      items: CheckType.values.map((type) {
                        return DropdownMenuItem<CheckType>(
                          value: type,
                          child: Text(type.getLabel(locale)),
                        );
                      }).toList(),
                      onChanged: _isProcessing
                          ? null
                          : (CheckType? newValue) {
                              setState(() {
                                _selectedCheckType = newValue;
                              });
                            },
                      isExpanded: true,
                    ),
                    // Texto informativo sobre sugerencia
                    if (_hasSuggestion && _selectedCheckType != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.suggestedTypeInfo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Campo de comentarios
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: l10n.commentsOptional,
                        hintText: l10n.writeComment,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
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
                      isDisabled: _isProcessing || _selectedCheckType == null,
                    ),

                    const SizedBox(height: 24),

                    // Botones de historial y admin
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Botón de historial (todos los usuarios)
                        ElevatedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const HistoryScreen(),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.history),
                          label: Text(l10n.history),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JasuTheme.lightGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        
                        // Botón de configuración (solo admin)
                        if (isAdmin) ...[
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const LocationsScreen(),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.settings),
                            label: Text(l10n.locations),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: JasuTheme.darkGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                tooltip: l10n.logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
