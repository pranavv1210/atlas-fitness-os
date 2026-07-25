import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/atlas/data/atlas_data_repository.dart';
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
import '../services/supabase_bootstrap.dart';

class AppDependencies {
  AppDependencies._({
    required this.logger,
    required this.connectivityService,
    required this.supabaseBootstrap,
    required GoogleAuthRemoteDataSource googleAuthRemoteDataSource,
  }) : _googleAuthRemoteDataSource = googleAuthRemoteDataSource;

  factory AppDependencies.create() {
    const logger = DevLogger();
    return AppDependencies._(
      logger: logger,
      connectivityService: ConnectivityPlusService(Connectivity()),
      supabaseBootstrap: SupabaseBootstrap(logger),
      googleAuthRemoteDataSource: GoogleSignInRemoteDataSource(logger),
    );
  }

  final AppLogger logger;
  final ConnectivityService connectivityService;
  final SupabaseBootstrap supabaseBootstrap;
  final GoogleAuthRemoteDataSource _googleAuthRemoteDataSource;

  AuthRepository? _authRepository;
  ProfileRepository? _profileRepository;
  AtlasDataRepository? _atlasDataRepository;

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

  void registerSupabaseClient(SupabaseClient client) {
    if (_authRepository != null &&
        _profileRepository != null &&
        _atlasDataRepository != null) {
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
    _atlasDataRepository = AtlasDataRepository(client);
  }
}
