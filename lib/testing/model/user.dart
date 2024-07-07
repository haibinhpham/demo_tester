class User {
  final int userId;
  final String username;
  final String password;
  final String email;

  User({
    required this.userId,
    required this.username,
    required this.password,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
    );
  }
}
