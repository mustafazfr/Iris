import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  late final StreamSubscription<AuthState> _authStateSubscription;

  User? _user;
  User? get user => _user;

  AuthViewModel() {
    _user = Supabase.instance.client.auth.currentUser;
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
          _user = data.session?.user;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // --- BU FONKSİYON GÜNCELLENDİ ---
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'surname': surname,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
  // ------------------------------

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}