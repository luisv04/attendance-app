import '../models/check_type.dart';
import '../services/storage_service.dart';

/// Helper para sugerir el siguiente tipo de checada basado en el historial del usuario
class CheckTypeSuggester {
  /// Sugiere el siguiente tipo de checada basado en la última checada del historial
  /// 
  /// Secuencia esperada:
  /// - Sin checadas previas → CheckIn (Entrada)
  /// - Última: checkIn → LunchOut (Salida a comida)
  /// - Última: lunchOut → LunchReturn (Regreso de comida)
  /// - Última: lunchReturn → CheckOut (Salida del trabajo)
  /// - Última: checkOut → CheckIn (Entrada - nuevo día)
  /// 
  /// Retorna el tipo sugerido o null si hay algún problema
  static CheckType? suggestNextType() {
    try {
      // Obtener última checada del historial
      final lastRecord = StorageService.getLastAttendanceRecord();
      
      // Si no hay historial, sugerir Entrada
      if (lastRecord == null) {
        return CheckType.checkIn;
      }
      
      // Obtener el tipo de la última checada
      final lastCheckType = CheckType.fromString(lastRecord.checkType);
      
      // Si no se puede determinar el tipo, sugerir Entrada por defecto
      if (lastCheckType == null) {
        return CheckType.checkIn;
      }
      
      // Aplicar lógica de secuencia
      switch (lastCheckType) {
        case CheckType.checkIn:
          return CheckType.lunchOut;
        case CheckType.lunchOut:
          return CheckType.lunchReturn;
        case CheckType.lunchReturn:
          return CheckType.checkOut;
        case CheckType.checkOut:
          // Después de salida del trabajo, siguiente día es entrada
          return CheckType.checkIn;
      }
    } catch (e) {
      // En caso de error, retornar null (el usuario deberá seleccionar manualmente)
      return null;
    }
  }
}
