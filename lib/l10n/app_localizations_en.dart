// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Attendance App';

  @override
  String get attendanceJasu => 'Attendance Jasu';

  @override
  String get google => 'Google';

  @override
  String get sendAssistant => 'Send Assistant';

  @override
  String get commentsOptional => 'Comments (optional)';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get attendanceRegisteredSuccessfully =>
      'Attendance registered successfully';

  @override
  String get errorSendingAttendance => 'Error sending attendance';

  @override
  String get noAuthenticatedUser => 'No authenticated user';

  @override
  String get signInCanceled => 'Sign in canceled';

  @override
  String get onlyJasuDomainAllowed =>
      'Only emails with domain @jasu.us are allowed. Please sign in with a corporate account.';

  @override
  String signInError(String error) {
    return 'Sign in error: $error';
  }

  @override
  String signOutError(String error) {
    return 'Error signing out: $error';
  }

  @override
  String get privacyNoticeTitle => 'Privacy Notice';

  @override
  String get privacyNoticeText =>
      'This application records location only when sending an attendance check (check-in, lunch out, lunch return, check-out).\nIt does not perform continuous tracking or outside working hours.\nThe information is used exclusively for attendance control.';

  @override
  String get accept => 'Accept';

  @override
  String get checkIn => 'Check-in';

  @override
  String get lunchOut => 'Lunch Out';

  @override
  String get lunchReturn => 'Lunch Return';

  @override
  String get checkOut => 'Check-out';

  @override
  String get selectCheckType => 'Select check type';

  @override
  String get duplicateCheckTypeError =>
      'You cannot send the same check type consecutively. Please select a different type.';

  @override
  String get history => 'History';

  @override
  String get noHistoryRecords => 'No attendance records found';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get type => 'Type';

  @override
  String get location => 'Location';

  @override
  String get admin => 'Admin';

  @override
  String get locations => 'Locations';

  @override
  String get manageLocations => 'Manage Locations';

  @override
  String get addLocation => 'Add Location';

  @override
  String get editLocation => 'Edit Location';

  @override
  String get locationName => 'Location Name';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get radiusMeters => 'Radius (meters)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get invalidLatitude => 'Latitude must be between -90 and 90';

  @override
  String get invalidLongitude => 'Longitude must be between -180 and 180';

  @override
  String get invalidRadius => 'Radius must be greater than 0';

  @override
  String get deleteLocationConfirm =>
      'Are you sure you want to delete this location?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get logout => 'Logout';

  @override
  String get suggestedTypeInfo => 'Suggested type based on your last check-in';

  @override
  String get attendanceVerification => 'Attendance Verification';

  @override
  String get validAttendance => 'Valid';

  @override
  String get outsideZone => 'Outside Zone';

  @override
  String get ok => 'OK';

  @override
  String get attendanceStatus => 'Status';
}
