import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/models/auth_session.dart';
import '../../domain/models/auth_user.dart';
import '../dtos/auth_user_dto.dart';

class AuthUserMapper {
  const AuthUserMapper._();

  static AuthUserDto fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return AuthUserDto(
      id: user.id,
      email: user.email ?? '',
      displayName:
          metadata['full_name'] as String? ??
          metadata['name'] as String? ??
          user.email,
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }

  static AuthUser toDomain(AuthUserDto dto) {
    return AuthUser(
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
    );
  }

  static AuthSession sessionFromSupabaseUser(User user) {
    return AuthSession(user: toDomain(fromSupabaseUser(user)));
  }
}
