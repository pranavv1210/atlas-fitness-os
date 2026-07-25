import '../../../../core/network/local_cache.dart';
import '../dtos/user_profile_dto.dart';

abstract interface class ProfileLocalCache
    implements LocalCache<UserProfileDto> {}

class NoopProfileLocalCache implements ProfileLocalCache {
  const NoopProfileLocalCache();

  @override
  Future<UserProfileDto?> read(String key) async => null;

  @override
  Future<void> remove(String key) async {}

  @override
  Future<void> write(String key, UserProfileDto value) async {}
}
