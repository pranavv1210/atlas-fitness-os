import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../errors/app_failure.dart';
import '../errors/result.dart';
import '../logging/app_logger.dart';

class SupabaseBootstrap {
  SupabaseBootstrap(this._logger);

  final AppLogger _logger;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  SupabaseClient? get client {
    if (!_initialized) {
      return null;
    }

    return Supabase.instance.client;
  }

  Future<Result<SupabaseClient>> initialize() async {
    if (_initialized) {
      return Success(Supabase.instance.client);
    }

    if (!AppConfig.hasSupabaseConfig) {
      return const Failure(
        AppFailure(
          kind: AppFailureKind.configuration,
          message:
              'Missing SUPABASE_URL or SUPABASE_ANON_KEY. Provide them with --dart-define.',
        ),
      );
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      _initialized = true;
      _logger.info('Supabase initialized');
      return Success(Supabase.instance.client);
    } catch (error, stackTrace) {
      _logger.error(
        'Supabase initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Failure(
        AppFailure(
          kind: AppFailureKind.configuration,
          message: 'Atlas could not initialize Supabase.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
