import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    checkLoginStatus();

    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      checkLoginStatus();
    });
  }

  void checkLoginStatus() {
    _isLoggedIn =
        Supabase.instance.client.auth.currentSession != null;

    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    checkLoginStatus();
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user != null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'username': username,
      });
    }

    checkLoginStatus();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    checkLoginStatus();
  }
}