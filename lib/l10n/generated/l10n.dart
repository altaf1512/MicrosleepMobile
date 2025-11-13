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

  /// `Name`
  String get profile_name {
    return Intl.message('Name', name: 'profile_name', desc: '', args: []);
  }

  /// `Email`
  String get profile_email {
    return Intl.message('Email', name: 'profile_email', desc: '', args: []);
  }

  /// `Address`
  String get profile_address {
    return Intl.message('Address', name: 'profile_address', desc: '', args: []);
  }

  /// `Age`
  String get profile_age {
    return Intl.message('Age', name: 'profile_age', desc: '', args: []);
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

  /// `Search rest area...`
  String get location_search_hint {
    return Intl.message(
      'Search rest area...',
      name: 'location_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get location_tab_map {
    return Intl.message('Map', name: 'location_tab_map', desc: '', args: []);
  }

  /// `List`
  String get location_tab_list {
    return Intl.message('List', name: 'location_tab_list', desc: '', args: []);
  }

  /// `Test Alarm`
  String get location_alarm_test {
    return Intl.message(
      'Test Alarm',
      name: 'location_alarm_test',
      desc: '',
      args: [],
    );
  }

  /// `Test Alarm`
  String get location_alarm_title {
    return Intl.message(
      'Test Alarm',
      name: 'location_alarm_title',
      desc: '',
      args: [],
    );
  }

  /// `Manual alarm successfully triggered.`
  String get location_alarm_body {
    return Intl.message(
      'Manual alarm successfully triggered.',
      name: 'location_alarm_body',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for location data...`
  String get location_waiting_data {
    return Intl.message(
      'Waiting for location data...',
      name: 'location_waiting_data',
      desc: '',
      args: [],
    );
  }

  /// `Your Location`
  String get location_panel_title {
    return Intl.message(
      'Your Location',
      name: 'location_panel_title',
      desc: '',
      args: [],
    );
  }

  /// `Latitude`
  String get location_latitude {
    return Intl.message(
      'Latitude',
      name: 'location_latitude',
      desc: '',
      args: [],
    );
  }

  /// `Longitude`
  String get location_longitude {
    return Intl.message(
      'Longitude',
      name: 'location_longitude',
      desc: '',
      args: [],
    );
  }

  /// `Speed`
  String get location_speed {
    return Intl.message('Speed', name: 'location_speed', desc: '', args: []);
  }

  /// `Last update`
  String get location_last_update {
    return Intl.message(
      'Last update',
      name: 'location_last_update',
      desc: '',
      args: [],
    );
  }

  /// `Rest Area Jember 1`
  String get restarea_1 {
    return Intl.message(
      'Rest Area Jember 1',
      name: 'restarea_1',
      desc: '',
      args: [],
    );
  }

  /// `Rest Area Jember 2`
  String get restarea_2 {
    return Intl.message(
      'Rest Area Jember 2',
      name: 'restarea_2',
      desc: '',
      args: [],
    );
  }

  /// `Highway Rest Area`
  String get restarea_type {
    return Intl.message(
      'Highway Rest Area',
      name: 'restarea_type',
      desc: '',
      args: [],
    );
  }

  /// `24 Hours`
  String get restarea_24hours {
    return Intl.message(
      '24 Hours',
      name: 'restarea_24hours',
      desc: '',
      args: [],
    );
  }

  /// `Toilet`
  String get facility_toilet {
    return Intl.message('Toilet', name: 'facility_toilet', desc: '', args: []);
  }

  /// `Food`
  String get facility_food {
    return Intl.message('Food', name: 'facility_food', desc: '', args: []);
  }

  /// `Parking`
  String get facility_parking {
    return Intl.message(
      'Parking',
      name: 'facility_parking',
      desc: '',
      args: [],
    );
  }

  /// `Fuel`
  String get facility_fuel {
    return Intl.message('Fuel', name: 'facility_fuel', desc: '', args: []);
  }

  /// `ATM`
  String get facility_atm {
    return Intl.message('ATM', name: 'facility_atm', desc: '', args: []);
  }

  /// `Search location or date...`
  String get history_search_hint {
    return Intl.message(
      'Search location or date...',
      name: 'history_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `No microsleep history.`
  String get history_no_data {
    return Intl.message(
      'No microsleep history.',
      name: 'history_no_data',
      desc: '',
      args: [],
    );
  }

  /// `Microsleep Detection`
  String get history_title {
    return Intl.message(
      'Microsleep Detection',
      name: 'history_title',
      desc: '',
      args: [],
    );
  }

  /// `Eyes closed for 3 consecutive seconds`
  String get history_detail_info {
    return Intl.message(
      'Eyes closed for 3 consecutive seconds',
      name: 'history_detail_info',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get history_date {
    return Intl.message('Date', name: 'history_date', desc: '', args: []);
  }

  /// `Location`
  String get history_location {
    return Intl.message(
      'Location',
      name: 'history_location',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get history_duration {
    return Intl.message(
      'Duration',
      name: 'history_duration',
      desc: '',
      args: [],
    );
  }

  /// `Response Time`
  String get history_response {
    return Intl.message(
      'Response Time',
      name: 'history_response',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Alarm`
  String get alarm {
    return Intl.message('Alarm', name: 'alarm', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Profile updated successfully`
  String get profile_edit_success {
    return Intl.message(
      'Profile updated successfully',
      name: 'profile_edit_success',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit_title {
    return Intl.message('Edit', name: 'edit_title', desc: '', args: []);
  }

  /// `Cancel`
  String get edit_cancel {
    return Intl.message('Cancel', name: 'edit_cancel', desc: '', args: []);
  }

  /// `Save`
  String get edit_save {
    return Intl.message('Save', name: 'edit_save', desc: '', args: []);
  }

  /// `Profile`
  String get settings_tab_profile {
    return Intl.message(
      'Profile',
      name: 'settings_tab_profile',
      desc: '',
      args: [],
    );
  }

  /// `Alarm`
  String get settings_tab_alarm {
    return Intl.message(
      'Alarm',
      name: 'settings_tab_alarm',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get settings_tab_stats {
    return Intl.message(
      'Statistics',
      name: 'settings_tab_stats',
      desc: '',
      args: [],
    );
  }

  /// `Warning Sound`
  String get alarm_sound {
    return Intl.message(
      'Warning Sound',
      name: 'alarm_sound',
      desc: '',
      args: [],
    );
  }

  /// `Emergency alarm active`
  String get alarm_sound_desc {
    return Intl.message(
      'Emergency alarm active',
      name: 'alarm_sound_desc',
      desc: '',
      args: [],
    );
  }

  /// `Vibration`
  String get alarm_vibration {
    return Intl.message(
      'Vibration',
      name: 'alarm_vibration',
      desc: '',
      args: [],
    );
  }

  /// `Active during microsleep`
  String get alarm_vibration_desc {
    return Intl.message(
      'Active during microsleep',
      name: 'alarm_vibration_desc',
      desc: '',
      args: [],
    );
  }

  /// `Location Tracking`
  String get alarm_tracking {
    return Intl.message(
      'Location Tracking',
      name: 'alarm_tracking',
      desc: '',
      args: [],
    );
  }

  /// `Used for rest area recommendation`
  String get alarm_tracking_desc {
    return Intl.message(
      'Used for rest area recommendation',
      name: 'alarm_tracking_desc',
      desc: '',
      args: [],
    );
  }

  /// `Driving Statistics`
  String get stats_title {
    return Intl.message(
      'Driving Statistics',
      name: 'stats_title',
      desc: '',
      args: [],
    );
  }

  /// `Monitor your safety progress`
  String get stats_subtitle {
    return Intl.message(
      'Monitor your safety progress',
      name: 'stats_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Total Monitoring Hours`
  String get stats_total_monitoring {
    return Intl.message(
      'Total Monitoring Hours',
      name: 'stats_total_monitoring',
      desc: '',
      args: [],
    );
  }

  /// `Safe Days`
  String get stats_safe_days {
    return Intl.message(
      'Safe Days',
      name: 'stats_safe_days',
      desc: '',
      args: [],
    );
  }

  /// `Total Incidents`
  String get stats_total_incidents {
    return Intl.message(
      'Total Incidents',
      name: 'stats_total_incidents',
      desc: '',
      args: [],
    );
  }

  /// `Improvement This Month`
  String get stats_monthly_improvement {
    return Intl.message(
      'Improvement This Month',
      name: 'stats_monthly_improvement',
      desc: '',
      args: [],
    );
  }

  /// `Total Monitoring Hours`
  String get stats_total_hours {
    return Intl.message(
      'Total Monitoring Hours',
      name: 'stats_total_hours',
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
