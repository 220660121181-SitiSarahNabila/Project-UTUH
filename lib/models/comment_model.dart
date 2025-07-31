class CommentModel {
  final int id;
  final String commentText;
  final String userName;
  final String userProfileImageUrl;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.commentText,
    required this.userName,
    required this.userProfileImageUrl,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      commentText: json['comment_text'] ?? '',     // <--- sesuai field DB/API
      userName: json['userName'] ?? '-',
      userProfileImageUrl: json['userProfileImageUrl'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
