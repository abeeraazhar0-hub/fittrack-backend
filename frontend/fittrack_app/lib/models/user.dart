class User {
  final int userId;
  final String name;
  final String token;

  User({required this.userId, required this.name, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'],
      token: json['token'],
    );
  }
}