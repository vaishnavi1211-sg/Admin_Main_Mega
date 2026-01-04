import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthProvider with ChangeNotifier {
  User? _admin;

  User? get admin => _admin;

  Future<void> loadAdmin() async {
    _admin = Supabase.instance.client.auth.currentUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _admin = null;
    notifyListeners();
  }
}
