import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AtlasPreferences {
  AtlasPreferences(this._prefs);

  static const _notificationPromptedKey = 'atlas.notification_prompted';
  static const _notificationEnabledKey = 'atlas.notification_enabled';
  static const _hydrationIntervalMinutesKey =
      'atlas.hydration_interval_minutes';
  static const _biometricEnabledKey = 'atlas.biometric_enabled';
  static const _themeModeKey = 'atlas.theme_mode';
  static const _customWorkoutPlanKey = 'atlas.custom_workout_plan';
  static const _workoutDraftKey = 'atlas.workout_draft';
  static const _dashboardSnapshotKey = 'atlas.dashboard_snapshot';
  static const _agentOrbXKey = 'atlas.agent_orb_x';
  static const _agentOrbYKey = 'atlas.agent_orb_y';

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

  int get hydrationIntervalMinutes =>
      _prefs.getInt(_hydrationIntervalMinutesKey) ?? 60;

  Future<void> setHydrationIntervalMinutes(int value) {
    return _prefs.setInt(_hydrationIntervalMinutesKey, value);
  }

  bool get biometricEnabled => _prefs.getBool(_biometricEnabledKey) ?? false;

  Future<void> setBiometricEnabled(bool value) {
    return _prefs.setBool(_biometricEnabledKey, value);
  }

  String get themeMode => _prefs.getString(_themeModeKey) ?? 'system';

  Future<void> setThemeMode(String value) {
    return _prefs.setString(_themeModeKey, value);
  }

  List<Map<String, dynamic>> get customWorkoutPlan {
    final raw = _prefs.getString(_customWorkoutPlanKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final item in decoded)
          if (item is Map)
            {
              for (final entry in item.entries)
                if (entry.key is String) entry.key as String: entry.value,
            },
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> setCustomWorkoutPlan(List<Map<String, dynamic>> value) {
    return _prefs.setString(_customWorkoutPlanKey, jsonEncode(value));
  }

  Map<String, dynamic>? workoutDraftFor(String userId) {
    final raw = _prefs.getString(_workoutDraftKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['userId'] != userId) {
        return null;
      }
      return {
        for (final entry in decoded.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> setWorkoutDraft(String userId, Map<String, dynamic> value) {
    return _prefs.setString(
      _workoutDraftKey,
      jsonEncode({'userId': userId, ...value}),
    );
  }

  Future<void> clearWorkoutDraft(String userId) async {
    final draft = workoutDraftFor(userId);
    if (draft == null) return;
    await _prefs.remove(_workoutDraftKey);
  }

  Map<String, dynamic>? dashboardSnapshotFor(String userId) {
    final raw = _prefs.getString(_dashboardSnapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['userId'] != userId) return null;
      return {
        for (final entry in decoded.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> setDashboardSnapshot(String userId, Map<String, dynamic> value) {
    return _prefs.setString(
      _dashboardSnapshotKey,
      jsonEncode({'userId': userId, ...value}),
    );
  }

  double? get agentOrbX => _prefs.getDouble(_agentOrbXKey);

  double? get agentOrbY => _prefs.getDouble(_agentOrbYKey);

  Future<void> setAgentOrbPosition(double x, double y) async {
    await _prefs.setDouble(_agentOrbXKey, x.clamp(0, 1));
    await _prefs.setDouble(_agentOrbYKey, y.clamp(0, 1));
  }
}
