// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Asistencia';

  @override
  String get attendanceJasu => 'Attendance Jasu';

  @override
  String get google => 'Google';

  @override
  String get sendAssistant => 'Enviar Asistencia';

  @override
  String get commentsOptional => 'Comentarios (opcional)';

  @override
  String get writeComment => 'Escribe un comentario...';

  @override
  String get attendanceRegisteredSuccessfully =>
      'Asistencia registrada exitosamente';

  @override
  String get errorSendingAttendance => 'Error al enviar la asistencia';

  @override
  String get noAuthenticatedUser => 'No hay usuario autenticado';

  @override
  String get signInCanceled => 'Inicio de sesión cancelado';

  @override
  String get onlyJasuDomainAllowed =>
      'Solo se permiten correos con dominio @jasu.us. Por favor inicia sesión con una cuenta corporativa.';

  @override
  String signInError(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String signOutError(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get privacyNoticeTitle => 'Aviso de Privacidad';

  @override
  String get privacyNoticeText =>
      'Esta aplicación registra la ubicación únicamente al momento de enviar una checada de asistencia (entrada, salida a comida, regreso de comida, salida del trabajo).\nNo realiza seguimiento continuo ni fuera del horario laboral.\nLa información se utiliza exclusivamente para control de asistencia.';

  @override
  String get accept => 'Aceptar';

  @override
  String get checkIn => 'Entrada';

  @override
  String get lunchOut => 'Salida a Comida';

  @override
  String get lunchReturn => 'Regreso de Comida';

  @override
  String get checkOut => 'Salida del Trabajo';

  @override
  String get selectCheckType => 'Seleccionar tipo de checada';

  @override
  String get duplicateCheckTypeError =>
      'No puedes enviar el mismo tipo de checada consecutivamente. Por favor selecciona un tipo diferente.';

  @override
  String get history => 'Historial';

  @override
  String get noHistoryRecords => 'No se encontraron registros de asistencia';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get date => 'Fecha';

  @override
  String get time => 'Hora';

  @override
  String get type => 'Tipo';

  @override
  String get location => 'Ubicación';

  @override
  String get admin => 'Administración';

  @override
  String get locations => 'Ubicaciones';

  @override
  String get manageLocations => 'Gestionar Ubicaciones';

  @override
  String get addLocation => 'Agregar Ubicación';

  @override
  String get editLocation => 'Editar Ubicación';

  @override
  String get locationName => 'Nombre de Ubicación';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get radiusMeters => 'Radio (metros)';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get nameRequired => 'El nombre es requerido';

  @override
  String get invalidLatitude => 'La latitud debe estar entre -90 y 90';

  @override
  String get invalidLongitude => 'La longitud debe estar entre -180 y 180';

  @override
  String get invalidRadius => 'El radio debe ser mayor a 0';

  @override
  String get deleteLocationConfirm =>
      '¿Estás seguro de que deseas eliminar esta ubicación?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get suggestedTypeInfo => 'Tipo sugerido según tu última checada';

  @override
  String get attendanceVerification => 'Verificación de Asistencia';

  @override
  String get validAttendance => 'Válida';

  @override
  String get outsideZone => 'Fuera de zona';

  @override
  String get ok => 'Aceptar';

  @override
  String get attendanceStatus => 'Estado';
}
