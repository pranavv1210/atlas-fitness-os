import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/atlas/data/atlas_data_repository.dart';
import '../../features/agent/data/atlas_agent_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/google_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/profile/data/datasources/profile_local_cache.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/default_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../logging/app_logger.dart';
import '../logging/dev_logger.dart';
import '../network/connectivity_plus_service.dart';
import '../network/connectivity_service.dart';
import '../services/atlas_biometric_service.dart';
import '../services/atlas_notification_service.dart';
import '../services/atlas_preferences.dart';
import '../services/supabase_bootstrap.dart';

class AppDependencies {
  AppDependencies._({
    required this.logger,
    required this.connectivityService,
    required this.supabaseBootstrap,
    required this.notificationService,
    required this.biometricService,
    required GoogleAuthRemoteDataSource googleAuthRemoteDataSource,
  }) : _googleAuthRemoteDataSource = googleAuthRemoteDataSource;

  factory AppDependencies.create() {
    const logger = DevLogger();
    return AppDependencies._(
      logger: logger,
      connectivityService: ConnectivityPlusService(Connectivity()),
      supabaseBootstrap: SupabaseBootstrap(logger),
      notificationService: AtlasNotificationService(
        FlutterLocalNotificationsPlugin(),
      ),
      biometricService: AtlasBiometricService(LocalAuthentication()),
      googleAuthRemoteDataSource: GoogleSignInRemoteDataSource(logger),
    );
  }

  final AppLogger logger;
  final ConnectivityService connectivityService;
  final SupabaseBootstrap supabaseBootstrap;
  final AtlasNotificationService notificationService;
  final AtlasBiometricService biometricService;
  final GoogleAuthRemoteDataSource _googleAuthRemoteDataSource;

  AuthRepository? _authRepository;
  ProfileRepository? _profileRepository;
  AtlasDataRepository? _atlasDataRepository;
  AtlasAgentService? _atlasAgentService;
  AtlasPreferences? _preferences;
  int _handledHydrationTapCount = 0;
  bool _listeningForHydrationTaps = false;
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  Future<void> initializeLocalServices() async {
    _preferences ??= AtlasPreferences(await SharedPreferences.getInstance());
    themeMode.value = _themeModeFromString(_preferences!.themeMode);
    await notificationService.initialize();
  }

  AtlasPreferences get preferences {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError(
        'Preferences requested before local services initialize',
      );
    }
    return preferences;
  }

  AuthRepository get authRepository {
    final repository = _authRepository;
    if (repository == null) {
      throw StateError(
        'AuthRepository requested before Supabase is configured',
      );
    }
    return repository;
  }

  ProfileRepository get profileRepository {
    final repository = _profileRepository;
    if (repository == null) {
      throw StateError(
        'ProfileRepository requested before Supabase is configured',
      );
    }
    return repository;
  }

  AtlasDataRepository get atlasDataRepository {
    final repository = _atlasDataRepository;
    if (repository == null) {
      throw StateError(
        'AtlasDataRepository requested before Supabase is configured',
      );
    }
    return repository;
  }

  AtlasAgentService get atlasAgentService {
    final service = _atlasAgentService;
    if (service == null) {
      throw StateError(
        'AtlasAgentService requested before Supabase is configured',
      );
    }
    return service;
  }

  void registerSupabaseClient(SupabaseClient client) {
    if (_authRepository != null &&
        _profileRepository != null &&
        _atlasDataRepository != null &&
        _atlasAgentService != null) {
      return;
    }

    _authRepository = SupabaseAuthRepository(
      authRemoteDataSource: SupabaseAuthRemoteDataSource(client),
      googleAuthRemoteDataSource: _googleAuthRemoteDataSource,
      logger: logger,
    );
    _profileRepository = DefaultProfileRepository(
      remoteDataSource: SupabaseProfileRemoteDataSource(client),
      localCache: const NoopProfileLocalCache(),
    );
    _atlasDataRepository = AtlasDataRepository(
      client,
      preferences: preferences,
    );
    _atlasAgentService = AtlasAgentService(client);
    _startHydrationTapListener();
  }

  void _startHydrationTapListener() {
    if (_listeningForHydrationTaps) return;
    _listeningForHydrationTaps = true;
    notificationService.hydrationTapRequests.addListener(
      _handleHydrationNotificationTap,
    );
    _handleHydrationNotificationTap();
  }

  void _handleHydrationNotificationTap() {
    final current = notificationService.hydrationTapRequests.value;
    if (current <= _handledHydrationTapCount) return;
    _handledHydrationTapCount = current;
    final repository = _atlasDataRepository;
    if (repository == null) return;
    unawaited(
      repository.saveHydration().catchError((Object error, StackTrace stack) {
        logger.warning(
          'Hydration notification tap could not be saved',
          error: error,
          stackTrace: stack,
        );
      }),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await preferences.setThemeMode(mode.name);
  }
}

ThemeMode _themeModeFromString(String value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
