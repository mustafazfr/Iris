// lib/repositories/favorites_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:denemeye_devam/models/favourite_model.dart';

class FavoritesRepository {
  final SupabaseClient _client;
  FavoritesRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  Future<List<FavouriteModel>> getFavoriteSaloons(String userId) async {
    final data = await _client
        .from('favourites')
        .select('*, saloons(*)') // Sadece salonları çekiyoruz
        .eq('user_id', userId);
    return data.map((item) => FavouriteModel.fromJson(item)).toList();
  }

  Future<void> addFavorite(String salonId) async {
    if (_userId == null) return;
    await _client.from('favourites').insert({
      'user_id': _userId,
      'saloon_id': salonId,
    });
  }

  Future<void> removeFavorite(String salonId) async {
    if (_userId == null) return;
    await _client
        .from('favourites')
        .delete()
        .eq('user_id', _userId!)
        .eq('saloon_id', salonId);
  }

  Future<bool> isFavorite(String salonId) async {
    if (_userId == null) return false;
    final response = await _client
        .from('favourites')
        .select('id')
        .eq('user_id', _userId!)
        .eq('saloon_id', salonId)
        .limit(1);
    return response.isNotEmpty;
  }
}