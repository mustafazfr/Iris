import 'package:flutter/material.dart';
import 'package:denemeye_devam/models/comment_model.dart';
import 'package:denemeye_devam/repositories/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsViewModel extends ChangeNotifier {
  final CommentRepository _repo = CommentRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  String? _error;
  String? get error => _error;

  Future<void> fetchComments(String salonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await _repo.getCommentsBySalon(salonId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postComment({
    required String userId,
    required String salonId,
    required int rating,
    required String text,
    required String userName,           // ← ekleyin
    String? userAvatarUrl,              // ← ekleyin
  }) async {
    final now = DateTime.now();
    final comment = CommentModel(
      commentId:    '',
      userId:       userId,
      userName:     userName,           // ←
      userAvatarUrl: userAvatarUrl,     // ←
      saloonId:     salonId,
      rating:       rating,
      commentText:  text,
      createdAt:    now,
      updatedAt:    now,
    );
    await _repo.addComment(comment);
    await fetchComments(salonId);
  }

}
