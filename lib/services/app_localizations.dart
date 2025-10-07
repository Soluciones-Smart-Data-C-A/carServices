// app_localizations.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/l10n/app_${locale.languageCode}.arb',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String _getString(String key) => _localizedStrings[key] ?? key;

  // Getters para todas las traducciones
  String get dashboardTitle => _getString('dashboard_title');
  String get upcomingServices => _getString('upcoming_services');
  String get recentServices => _getString('recent_services');
  String get quickActions => _getString('quick_actions');
  String get addService => _getString('add_service');
  String get addVehicle => _getString('add_vehicle');
  String get viewHistory => _getString('view_history');
  String get settings => _getString('settings');
  String get home => _getString('home');
  String get services => _getString('services');
  String get history => _getString('history');
  String get lastService => _getString('last_service');
  String get estimated => _getString('estimated');
  String get daily => _getString('daily');
  String get daysAgo => _getString('days_ago');
  String get km => _getString('km');
  String get locationTrackingActive => _getString('location_tracking_active');
  String get locationTrackingDisabled =>
      _getString('location_tracking_disabled');
  String get enableLocation => _getString('enable_location');
  String get todayDistance => _getString('today_distance');
  String get noVehicleFound => _getString('no_vehicle_found');
  String get addVehicleToStart => _getString('add_vehicle_to_start');
  String get serviceAt => _getString('service_at');
  String get recommendedAt => _getString('recommended_at');
  String get approxIn => _getString('approx_in');
  String get myVehicles => _getString('my_vehicles');
  String get registeredVehicles => _getString('registered_vehicles');
  String get noVehiclesRegistered => _getString('no_vehicles_registered');
  String get appSettings => _getString('app_settings');
  String get notifications => _getString('notifications');
  String get changePassword => _getString('change_password');
  String get signOut => _getString('sign_out');
  String get appInformation => _getString('app_information');
  String get version => _getString('version');
  String get developer => _getString('developer');
  String get language => _getString('language');
  String get english => _getString('english');
  String get spanish => _getString('spanish');
  String get serviceHistory => _getString('service_history');
  String get serviceDetails => _getString('service_details');
  String get close => _getString('close');
  String get errorLoadingHistory => _getString('error_loading_history');
  String get noServiceRecords => _getString('no_service_records');
  String get servicesWillAppearHere => _getString('services_will_appear_here');
  String get retry => _getString('retry');
  String get notes => _getString('notes');
  String get service => _getString('service');
  String get vehicle => _getString('vehicle');
  String get mileage => _getString('mileage');
  String get date => _getString('date');
  String get currentMileage => _getString('current_mileage');
  String get autoMileage => _getString('auto_mileage');
  String get enterCurrentMileage => _getString('enter_current_mileage');
  String todaysAutoMileage(String distance) =>
      _getString('todays_auto_mileage').replaceFirst('{distance}', distance);
  String totalMileage(int total) =>
      _getString('total_mileage').replaceFirst('{total}', total.toString());
  String get autoMileageUnavailable => _getString('auto_mileage_unavailable');
  String get enableLocationForAutoMileage =>
      _getString('enable_location_for_auto_mileage');
  String get includesServices => _getString('includes_services');
  String get servicesPerformed => _getString('services_performed');
  String get notesOptional => _getString('notes_optional');
  String get addAdditionalNotes => _getString('add_additional_notes');
  String get saveRecord => _getString('save_record');
  String get auto => _getString('auto');
  String get loadingServices => _getString('loading_services');
  String get errorLoadingData => _getString('error_loading_data');
  String get addVehicleFirst => _getString('add_vehicle_first');
  String get locationTrackingEnabled => _getString('location_tracking_enabled');
  String get selectVehicleFirst => _getString('select_vehicle_first');
  String get selectVehicleAndMileage =>
      _getString('select_vehicle_and_mileage');
  String get enterValidMileage => _getString('enter_valid_mileage');
  String mileageCannotBeLess(int currentMileage) => _getString(
    'mileage_cannot_be_less',
  ).replaceFirst('{currentMileage}', currentMileage.toString());
  String get selectAtLeastOneService =>
      _getString('select_at_least_one_service');
  String get serviceRecordSaved => _getString('service_record_saved');
  String errorSavingRecord(String error) =>
      _getString('error_saving_record').replaceFirst('{error}', error);
  String autoMileageSet(int estimated, String today) =>
      _getString('auto_mileage_set')
          .replaceFirst('{estimated}', estimated.toString())
          .replaceFirst('{today}', today);

  String get loadingVehicles => _getString('loading_vehicles');
  String get viewAll => _getString('view_all');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
