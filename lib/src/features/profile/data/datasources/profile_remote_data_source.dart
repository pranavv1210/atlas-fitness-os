import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/remote_data_source.dart';
import '../dtos/user_profile_dto.dart';
import '../mappers/user_profile_mapper.dart';

abstract interface class ProfileRemoteDataSource implements RemoteDataSource {
  Future<Result<UserProfileDto>> loadInitialProfile();
}

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  SupabaseProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  String get sourceName => 'SupabaseProfile';

  @override
  Future<Result<UserProfileDto>> loadInitialProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Atlas needs an authenticated session to load a profile.',
        ),
      );
    }

    return Success(UserProfileMapper.fromSupabaseUser(user));
  }
}
