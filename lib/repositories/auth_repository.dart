import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthRepository{
  final SupabaseClient _client;
  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn(String email, String password) async{
    try{
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch(e){
      debugPrint('Giriş yaparken hata: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {String? displayName}) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        // data: {'display_name': displayName}, // Kullanıcı adı gibi ek veriler
      );
    } catch (e) {
      debugPrint('Kayıt olurken hata: $e');
      rethrow;
    }
  }
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Çıkış yaparken hata: $e');
      rethrow;
    }
  }
  // Auth durumundaki değişiklikleri dinlemek için bir stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}