class User {
  final String id;
  String username;
  List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.roles,
  });

  // fromJson Methode
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
    );
  }

  // toJson Methode
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'roles': roles,
    };
  }
}
