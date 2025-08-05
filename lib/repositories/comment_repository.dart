import 'package:denemeye_devam/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepository {
  final SupabaseClient _client;
  CommentRepository(this._client);

  /// Bir salonun tüm yorumlarını alır.
  /// Eğer kullanıcı adı/avatari ile birlikte ihtiyaç varsa,
  /// şu şekilde bir join kullanabilirsiniz:
  /// .select('*, users(name,profile_photo_url)')
  Future<List<CommentModel>> getCommentsBySalon(String salonId) async {
    final data = await _client
        .from('comments')
        .select('*, users(name, profile_photo_url)') // ← users tablosundan name & avatar
        .eq('saloon_id', salonId)
        .order('created_at', ascending: false) as List;

    return data.map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Yeni yorum ekler
  Future<void> addComment(CommentModel comment) async {
    final json = comment.toJson()..remove('comment_id');
    await _client.from('comments').insert(json);
  }
}
