import '../../../../core/errors/result.dart';
import '../models/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Result<UserProfile>> loadInitialProfile();
}
