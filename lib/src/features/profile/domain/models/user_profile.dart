class UserProfile {
  const UserProfile({
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
