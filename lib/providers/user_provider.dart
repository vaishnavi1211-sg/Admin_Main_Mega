// TODO Implement this library.
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_service.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    _users = await MockService.fetchUsers();
    _loading = false;
    notifyListeners();
  }

  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  void updateUser(UserModel user) {
    int index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) _users[index] = user;
    notifyListeners();
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
