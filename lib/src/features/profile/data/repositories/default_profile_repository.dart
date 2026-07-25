import '../../../../core/errors/result.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_cache.dart';
import '../datasources/profile_remote_data_source.dart';
import '../dtos/user_profile_dto.dart';
import '../mappers/user_profile_mapper.dart';

class DefaultProfileRepository implements ProfileRepository {
  DefaultProfileRepository({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileLocalCache localCache,
  }) : _remoteDataSource = remoteDataSource,
       _localCache = localCache;

  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalCache _localCache;

  @override
  Future<Result<UserProfile>> loadInitialProfile() async {
    final remoteResult = await _remoteDataSource.loadInitialProfile();
    if (remoteResult case Failure<UserProfileDto> failure) {
      return Failure(failure.failure);
    }

    final dto = (remoteResult as Success<UserProfileDto>).value;
    await _localCache.write(dto.userId, dto);
    return Success(UserProfileMapper.toDomain(dto));
  }
}
