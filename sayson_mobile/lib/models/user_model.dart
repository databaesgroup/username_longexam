class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String type;
  final bool isActive;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.type,
    required this.isActive,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final src =
        json['user'] is Map ? Map<String, dynamic>.from(json['user']) : json;
    return AppUser(
      id: (src['_id'] ?? src['id'] ?? '').toString(),
      firstName: (src['firstName'] ?? '').toString(),
      lastName: (src['lastName'] ?? '').toString(),
      email: (src['email'] ?? '').toString(),
      username: (src['username'] ?? '').toString(),
      type: (src['type'] ?? 'user').toString(),
      isActive: src['isActive'] == true ||
          src['isActive'] == 1 ||
          (src['isActive']?.toString().toLowerCase() == 'true'),
    );
  }

  String get fullName =>
      [firstName, lastName].where((e) => e.trim().isNotEmpty).join(' ');
}
