class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? imageUrl;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.imageUrl,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'], // optional, biarkan saja jika tidak dikirim di update
       imageUrl: (json['imageUrl'] ?? '').toString(), // pastikan disini 'imageUrl'
      bio: json['bio'],
    );
  }
}
