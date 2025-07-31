// File: lib/models/post_model.dart

class PostModel {
  final int id;
  final String content;
  final String postImageUrl;
  final DateTime createdAt;
  final int userId;
  final String userName;
  final String userProfileImageUrl;
  final int? destinationId;
  final String? destinationName;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser; // tambahkan ini!

  
  // Anda bisa menambahkan 'isLikedByCurrentUser' jika API Anda menyediakannya
  // final bool isLikedByCurrentUser;

  PostModel({
    required this.id,
    required this.content,
    required this.postImageUrl,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.userProfileImageUrl,
    this.destinationId,
    this.destinationName,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByCurrentUser, // tambahkan ini!
    // this.isLikedByCurrentUser = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      postImageUrl: json['postImageUrl'] as String? ?? '',
      // Parsing tanggal dengan aman
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? 'User',
      userProfileImageUrl: json['userProfileImageUrl'] as String? ?? '',
      destinationId: json['destinationId'] as int?,
      destinationName: json['destinationName'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLikedByCurrentUser: (json['isLikedByCurrentUser'] ?? 0) == 1,
    );
  }
}