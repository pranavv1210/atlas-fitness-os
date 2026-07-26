import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user_profile.dart';
import '../dtos/user_profile_dto.dart';

class UserProfileMapper {
  const UserProfileMapper._();

  static UserProfileDto fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? '';
    return UserProfileDto(
      userId: user.id,
      email: email,
      displayName:
          metadata['full_name'] as String? ??
          metadata['name'] as String? ??
          (email.isEmpty ? 'Atlas User' : email.split('@').first),
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }

  static UserProfile toDomain(UserProfileDto dto) {
    return UserProfile(
      userId: dto.userId,
      email: dto.email,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
    );
  }
}
