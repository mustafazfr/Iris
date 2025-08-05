class CommentModel {
  final String commentId;
  final String userId;
  final String userName;           // ← Yeni
  final String? userAvatarUrl;     // ← Yeni
  final String? saloonId;
  final int rating;
  final String commentText;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.saloonId,
    required this.rating,
    required this.commentText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return CommentModel(
      commentId: json['comment_id'] as String,
      userId:     json['user_id']    as String,
      userName:   user?['name']      as String? ?? 'Misafir',
      userAvatarUrl: user?['profile_photo_url'] as String?,
      saloonId:   json['saloon_id']  as String?,
      rating:     json['rating']     as int,
      commentText: json['comment_text'] as String,
      createdAt:  DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
      updatedAt:  DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id':     commentId,
      'user_id':        userId,
      // userName & userAvatarUrl DB tablosunda yok, onları toJson’a eklemiyoruz
      'saloon_id':      saloonId,
      'rating':         rating,
      'comment_text':   commentText,
      'created_at':     createdAt.toIso8601String(),
      'updated_at':     updatedAt.toIso8601String(),
    };
  }
}
