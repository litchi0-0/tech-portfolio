class User {
  final int id;
  final String username;
  final String nickname;
  final String? email;
  final String? avatarUrl;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String? ?? json['username'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nickname': nickname,
        'email': email,
        'avatarUrl': avatarUrl,
      };
}
