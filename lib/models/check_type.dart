/// Enum que representa los tipos de checada disponibles
enum CheckType {
  checkIn('check_in', 'Check-in', 'Entrada'),
  lunchOut('lunch_out', 'Lunch Out', 'Salida a Comida'),
  lunchReturn('lunch_return', 'Lunch Return', 'Regreso de Comida'),
  checkOut('check_out', 'Check-out', 'Salida del Trabajo');

  final String value;
  final String labelEn;
  final String labelEs;

  const CheckType(this.value, this.labelEn, this.labelEs);

  /// Obtiene el label localizado según el idioma
  String getLabel(String locale) {
    switch (locale) {
      case 'es':
        return labelEs;
      default:
        return labelEn;
    }
  }

  /// Crea CheckType desde un string
  static CheckType? fromString(String? value) {
    if (value == null) return null;
    try {
      return CheckType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (e) {
      return null;
    }
  }
}
