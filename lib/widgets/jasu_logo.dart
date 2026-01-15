import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class JasuLogo extends StatelessWidget {
  const JasuLogo({super.key});

  static Future<bool> _checkAssetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAssetExists('assets/images/jasu_logo.png'),
      builder: (context, snapshot) {
        final hasLogo = snapshot.data ?? false;

        if (!hasLogo) {
          // Si no hay logo, mostrar solo el texto JASU con ícono de hoja
          return Column(
            children: [
              // Ícono de hoja pequeño arriba
              const Icon(
                Icons.eco,
                color: JasuTheme.lightGreen,
                size: 20,
              ),
              const SizedBox(height: 4),
              // Texto JASU
              const Text(
                'JASU',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: JasuTheme.darkGreen,
                  letterSpacing: 2,
                ),
              ),
            ],
          );
        }

        // Si hay logo, mostrarlo dentro de un marco circular sin borde
        return Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/jasu_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback si hay error al cargar la imagen
                return const Center(
                  child: Icon(
                    Icons.eco,
                    color: JasuTheme.darkGreen,
                    size: 60,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
