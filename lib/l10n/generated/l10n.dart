// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Microsleep Guard`
  String get appTitle {
    return Intl.message(
      'Microsleep Guard',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Good Morning, Driver`
  String get welcomeDriver {
    return Intl.message(
      'Good Morning, Driver',
      name: 'welcomeDriver',
      desc: '',
      args: [],
    );
  }

  /// `Monitor microsleep and your trip in real-time.`
  String get monitoringSubtitle {
    return Intl.message(
      'Monitor microsleep and your trip in real-time.',
      name: 'monitoringSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Realtime monitoring active`
  String get monitoringActive {
    return Intl.message(
      'Realtime monitoring active',
      name: 'monitoringActive',
      desc: '',
      args: [],
    );
  }

  /// `Microsleep Detected`
  String get microsleepDetected {
    return Intl.message(
      'Microsleep Detected',
      name: 'microsleepDetected',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get normalStatus {
    return Intl.message('Normal', name: 'normalStatus', desc: '', args: []);
  }

  /// `Driver Status`
  String get driverStatus {
    return Intl.message(
      'Driver Status',
      name: 'driverStatus',
      desc: '',
      args: [],
    );
  }

  /// `Microsleep Duration`
  String get microsleepDuration {
    return Intl.message(
      'Microsleep Duration',
      name: 'microsleepDuration',
      desc: '',
      args: [],
    );
  }

  /// `Battery`
  String get battery {
    return Intl.message('Battery', name: 'battery', desc: '', args: []);
  }

  /// `GPS`
  String get gps {
    return Intl.message('GPS', name: 'gps', desc: '', args: []);
  }

  /// `IoT Device`
  String get iotDevice {
    return Intl.message('IoT Device', name: 'iotDevice', desc: '', args: []);
  }

  /// `Device Status`
  String get deviceStatus {
    return Intl.message(
      'Device Status',
      name: 'deviceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Turn Off Alarm / Save to History`
  String get turnOffAlarm {
    return Intl.message(
      'Turn Off Alarm / Save to History',
      name: 'turnOffAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Alarm stopped`
  String get alarmStopped {
    return Intl.message(
      'Alarm stopped',
      name: 'alarmStopped',
      desc: '',
      args: [],
    );
  }

  /// `Microsleep Detected!`
  String get alarmDetected {
    return Intl.message(
      'Microsleep Detected!',
      name: 'alarmDetected',
      desc: '',
      args: [],
    );
  }

  /// `Stop the vehicle safely`
  String get alarmInstruction {
    return Intl.message(
      'Stop the vehicle safely',
      name: 'alarmInstruction',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Age`
  String get age {
    return Intl.message('Age', name: 'age', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Warning Sound`
  String get sound {
    return Intl.message('Warning Sound', name: 'sound', desc: '', args: []);
  }

  /// `Vibration`
  String get vibration {
    return Intl.message('Vibration', name: 'vibration', desc: '', args: []);
  }

  /// `Location Tracking`
  String get tracking {
    return Intl.message(
      'Location Tracking',
      name: 'tracking',
      desc: '',
      args: [],
    );
  }

  /// `Emergency alarm active`
  String get soundDesc {
    return Intl.message(
      'Emergency alarm active',
      name: 'soundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Vibrates on microsleep`
  String get vibrationDesc {
    return Intl.message(
      'Vibrates on microsleep',
      name: 'vibrationDesc',
      desc: '',
      args: [],
    );
  }

  /// `For rest area recommendation`
  String get trackingDesc {
    return Intl.message(
      'For rest area recommendation',
      name: 'trackingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Safe Days`
  String get safeDays {
    return Intl.message('Safe Days', name: 'safeDays', desc: '', args: []);
  }

  /// `Total Incidents`
  String get totalIncidents {
    return Intl.message(
      'Total Incidents',
      name: 'totalIncidents',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Improvement`
  String get monthlyImprovement {
    return Intl.message(
      'Monthly Improvement',
      name: 'monthlyImprovement',
      desc: '',
      args: [],
    );
  }

  /// `Total Monitoring Hours`
  String get totalMonitoringHours {
    return Intl.message(
      'Total Monitoring Hours',
      name: 'totalMonitoringHours',
      desc: '',
      args: [],
    );
  }

  /// `Current Location`
  String get currentLocation {
    return Intl.message(
      'Current Location',
      name: 'currentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `No data available`
  String get noData {
    return Intl.message(
      'No data available',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Indonesian`
  String get indonesian {
    return Intl.message('Indonesian', name: 'indonesian', desc: '', args: []);
  }

  /// `Choose Language`
  String get chooseLanguage {
    return Intl.message(
      'Choose Language',
      name: 'chooseLanguage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'id'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
