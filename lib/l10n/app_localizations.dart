import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Attendance App'**
  String get appTitle;

  /// Main title
  ///
  /// In en, this message translates to:
  /// **'Attendance Jasu'**
  String get attendanceJasu;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// Button to send attendance
  ///
  /// In en, this message translates to:
  /// **'Send Assistant'**
  String get sendAssistant;

  /// Comments field label
  ///
  /// In en, this message translates to:
  /// **'Comments (optional)'**
  String get commentsOptional;

  /// Comments field hint
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// Success message after registering attendance
  ///
  /// In en, this message translates to:
  /// **'Attendance registered successfully'**
  String get attendanceRegisteredSuccessfully;

  /// Error message when sending fails
  ///
  /// In en, this message translates to:
  /// **'Error sending attendance'**
  String get errorSendingAttendance;

  /// Error when user is not authenticated
  ///
  /// In en, this message translates to:
  /// **'No authenticated user'**
  String get noAuthenticatedUser;

  /// Message when user cancels sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in canceled'**
  String get signInCanceled;

  /// Error message for invalid domain
  ///
  /// In en, this message translates to:
  /// **'Only emails with domain @jasu.us are allowed. Please sign in with a corporate account.'**
  String get onlyJasuDomainAllowed;

  /// Generic sign in error
  ///
  /// In en, this message translates to:
  /// **'Sign in error: {error}'**
  String signInError(String error);

  /// Error when signing out
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String signOutError(String error);

  /// Title of privacy notice screen
  ///
  /// In en, this message translates to:
  /// **'Privacy Notice'**
  String get privacyNoticeTitle;

  /// Privacy notice text
  ///
  /// In en, this message translates to:
  /// **'This application records location only when sending an attendance check (check-in, lunch out, lunch return, check-out).\nIt does not perform continuous tracking or outside working hours.\nThe information is used exclusively for attendance control.'**
  String get privacyNoticeText;

  /// Accept button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Check-in type
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// Lunch out type
  ///
  /// In en, this message translates to:
  /// **'Lunch Out'**
  String get lunchOut;

  /// Lunch return type
  ///
  /// In en, this message translates to:
  /// **'Lunch Return'**
  String get lunchReturn;

  /// Check-out type
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// Label for check type selector
  ///
  /// In en, this message translates to:
  /// **'Select check type'**
  String get selectCheckType;

  /// Error when trying to send duplicate check type
  ///
  /// In en, this message translates to:
  /// **'You cannot send the same check type consecutively. Please select a different type.'**
  String get duplicateCheckTypeError;

  /// History button and screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Message when history is empty
  ///
  /// In en, this message translates to:
  /// **'No attendance records found'**
  String get noHistoryRecords;

  /// History subtitle
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Admin section title
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Locations screen title
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locations;

  /// Manage locations description
  ///
  /// In en, this message translates to:
  /// **'Manage Locations'**
  String get manageLocations;

  /// Add location button
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// Edit location dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// Location name field label
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationName;

  /// Latitude field label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// Longitude field label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// Radius field label
  ///
  /// In en, this message translates to:
  /// **'Radius (meters)'**
  String get radiusMeters;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Validation error for name
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Validation error for latitude
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get invalidLatitude;

  /// Validation error for longitude
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get invalidLongitude;

  /// Validation error for radius
  ///
  /// In en, this message translates to:
  /// **'Radius must be greater than 0'**
  String get invalidRadius;

  /// Delete location confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this location?'**
  String get deleteLocationConfirm;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Information text about suggested check type
  ///
  /// In en, this message translates to:
  /// **'Suggested type based on your last check-in'**
  String get suggestedTypeInfo;

  /// Title of attendance verification modal
  ///
  /// In en, this message translates to:
  /// **'Attendance Verification'**
  String get attendanceVerification;

  /// Status label for valid attendance
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get validAttendance;

  /// Status label for attendance outside zone
  ///
  /// In en, this message translates to:
  /// **'Outside Zone'**
  String get outsideZone;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Status label in history
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get attendanceStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
