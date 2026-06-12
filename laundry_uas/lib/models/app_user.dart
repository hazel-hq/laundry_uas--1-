class AppUser {
  final String username;
  final String fullName;
  final String role;

  const AppUser({
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      username: '${data['username']}',
      fullName: '${data['full_name']}',
      role: '${data['role']}',
    );
  }

  bool get isAdmin => role == 'admin';
}

AppUser? currentAppUser;
