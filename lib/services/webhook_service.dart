import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_data.dart';
import '../core/constants.dart';

class WebhookService {
  /// Envía los datos de asistencia al webhook de n8n
  /// Retorna true si el envío fue exitoso, false en caso contrario
  /// Lanza una excepción con el mensaje de error si falla
  Future<bool> sendAttendance(AttendanceData data) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        throw Exception(
            'Error al enviar asistencia: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error al enviar asistencia: ${e.toString()}');
    }
  }
}
