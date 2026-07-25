class UserProfileDto {
  const UserProfileDto({
    required this.userId,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String displayName;
  final String? avatarUrl;
}
