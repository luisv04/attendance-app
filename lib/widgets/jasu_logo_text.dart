import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Widget del logo JASU con texto, ícono de hoja y símbolo ®
/// Para usar en pantalla de login
class JasuLogoText extends StatelessWidget {
  const JasuLogoText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenedor con el logo JASU y elementos posicionados
        Stack(
          alignment: Alignment.center,
          children: [
            // Texto JASU principal
            const Text(
              'JASU',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: JasuTheme.darkGreen,
                letterSpacing: 4,
                height: 1.2,
              ),
            ),
            // Ícono de hoja arriba a la izquierda de la J
            Positioned(
              top: -8,
              left: -12,
              child: const Icon(
                Icons.eco,
                color: JasuTheme.darkGreen,
                size: 24,
              ),
            ),
            // Símbolo ® arriba a la derecha de la U
            Positioned(
              top: -4,
              right: -16,
              child: const Text(
                '®',
                style: TextStyle(
                  fontSize: 16,
                  color: JasuTheme.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
