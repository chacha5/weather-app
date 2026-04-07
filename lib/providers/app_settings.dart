import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _kTemperatureUnit = 'temperature_unit';
  static const _kWindSpeedUnit = 'wind_speed_unit';
  static const _kTimeFormat = 'time_format';
  static const _kPushNotifications = 'push_notifications';

  final SharedPreferences _prefs;

  String _temperatureUnit = 'Celsius (°C)';
  String _windSpeedUnit = 'Km/h';
  String _timeFormat = '24 Hour';
  bool _pushNotifications = true;

  AppSettings(this._prefs) {
    _temperatureUnit = _prefs.getString(_kTemperatureUnit) ?? _temperatureUnit;
    _windSpeedUnit = _prefs.getString(_kWindSpeedUnit) ?? _windSpeedUnit;
    _timeFormat = _prefs.getString(_kTimeFormat) ?? _timeFormat;
    _pushNotifications = _prefs.getBool(_kPushNotifications) ?? _pushNotifications;
  }

  String get temperatureUnit => _temperatureUnit;
  String get windSpeedUnit => _windSpeedUnit;
  String get timeFormat => _timeFormat;
  bool get pushNotifications => _pushNotifications;

  Future<void> toggleTemperatureUnit() async {
    _temperatureUnit = _temperatureUnit == 'Celsius (°C)' ? 'Fahrenheit (°F)' : 'Celsius (°C)';
    await _prefs.setString(_kTemperatureUnit, _temperatureUnit);
    notifyListeners();
  }

  Future<void> toggleWindSpeedUnit() async {
    _windSpeedUnit = _windSpeedUnit == 'Km/h' ? 'Mph' : 'Km/h';
    await _prefs.setString(_kWindSpeedUnit, _windSpeedUnit);
    notifyListeners();
  }

  Future<void> toggleTimeFormat() async {
    _timeFormat = _timeFormat == '24 Hour' ? '12 Hour' : '24 Hour';
    await _prefs.setString(_kTimeFormat, _timeFormat);
    notifyListeners();
  }

  Future<void> togglePushNotifications() async {
    _pushNotifications = !_pushNotifications;
    await _prefs.setBool(_kPushNotifications, _pushNotifications);
    notifyListeners();
  }

  // Optional setters for explicit values
  Future<void> setTemperatureUnit(String v) async {
    _temperatureUnit = v;
    await _prefs.setString(_kTemperatureUnit, v);
    notifyListeners();
  }
}
