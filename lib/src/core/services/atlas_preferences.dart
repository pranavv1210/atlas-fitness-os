import 'package:shared_preferences/shared_preferences.dart';

class AtlasPreferences {
  AtlasPreferences(this._prefs);

  static const _notificationPromptedKey = 'atlas.notification_prompted';
  static const _notificationEnabledKey = 'atlas.notification_enabled';
  static const _biometricEnabledKey = 'atlas.biometric_enabled';

  final SharedPreferences _prefs;

  bool get notificationPrompted =>
      _prefs.getBool(_notificationPromptedKey) ?? false;

  Future<void> setNotificationPrompted() {
    return _prefs.setBool(_notificationPromptedKey, true);
  }

  bool get notificationEnabled =>
      _prefs.getBool(_notificationEnabledKey) ?? false;

  Future<void> setNotificationEnabled(bool value) {
    return _prefs.setBool(_notificationEnabledKey, value);
  }

  bool get biometricEnabled => _prefs.getBool(_biometricEnabledKey) ?? false;

  Future<void> setBiometricEnabled(bool value) {
    return _prefs.setBool(_biometricEnabledKey, value);
  }
}
