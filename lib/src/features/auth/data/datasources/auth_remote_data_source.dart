import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/remote_data_source.dart';
import '../dtos/auth_user_dto.dart';
import '../mappers/auth_user_mapper.dart';

abstract interface class AuthRemoteDataSource implements RemoteDataSource {
  Future<Result<AuthUserDto?>> currentUser();

  Future<Result<AuthUserDto>> signInWithGoogleIdToken(String idToken);

  Future<Result<void>> signOut();
}

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  String get sourceName => 'SupabaseAuth';

  @override
  Future<Result<AuthUserDto?>> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Success(null);
    }

    return Success(AuthUserMapper.fromSupabaseUser(user));
  }

  @override
  Future<Result<AuthUserDto>> signInWithGoogleIdToken(String idToken) async {
    try {
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      final user = response.user;
      if (user == null) {
        return const Failure(
          AppFailure(
            kind: AppFailureKind.authentication,
            message: 'Supabase did not return an authenticated user.',
          ),
        );
      }

      return Success(AuthUserMapper.fromSupabaseUser(user));
    } on AuthException catch (error, stackTrace) {
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: error.message,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Atlas could not authenticate with Supabase.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success(null);
    } catch (error, stackTrace) {
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Atlas could not sign out.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
