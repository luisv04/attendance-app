import 'package:flutter/material.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
import '../core/device_helper.dart';
import '../models/privacy_acceptance_data.dart';
import '../core/theme.dart';

/// Pantalla bloqueante que muestra el aviso de privacidad
/// Requiere aceptación explícita para continuar
class PrivacyNoticeScreen extends StatelessWidget {
  final String userEmail;

  const PrivacyNoticeScreen({
    super.key,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: JasuTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Ícono de privacidad
                  Icon(
                    Icons.privacy_tip,
                    size: 80,
                    color: JasuTheme.darkGreen,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título
                  Text(
                    l10n.privacyNoticeTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: JasuTheme.darkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Texto del aviso
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: JasuTheme.lightGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      l10n.privacyNoticeText,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón de aceptar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Guardar aceptación por usuario
                        await StorageService.setPrivacyAccepted(userEmail, true);
                        
                        // Enviar aceptación al webhook (solo una vez por usuario)
                        if (!StorageService.hasPrivacyBeenSent(userEmail)) {
                          try {
                            final appVersion = await DeviceHelper.getAppVersion();
                            final privacyData = PrivacyAcceptanceData(
                              accepted: true,
                              version: '1.0',
                              acceptedAt: DateTime.now(),
                              userEmail: userEmail,
                              appVersion: appVersion,
                            );
                            
                            final webhookService = WebhookService();
                            final sent = await webhookService.sendPrivacyAcceptance(privacyData);
                            
                            if (sent) {
                              // Marcar como enviado para evitar duplicados
                              await StorageService.setPrivacySent(userEmail, true);
                            }
                            // Si falla, no bloquear flujo - se puede reintentar después
                          } catch (e) {
                            // Error silencioso - no bloquear flujo del usuario
                          }
                        }
                        
                        // Navegar a HomeScreen
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JasuTheme.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.accept,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
