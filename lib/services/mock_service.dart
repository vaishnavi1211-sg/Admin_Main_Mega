import '../models/user_model.dart';

class MockService {
  static List<UserModel> getUsers() {
    return [
      UserModel(id: '1', name: 'Alice', email: 'alice@example.com', role: 'Admin'),
      UserModel(id: '2', name: 'Bob', email: 'bob@example.com', role: 'Manager'),
      UserModel(id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'Staff'),
    ];
  }

  static Future<List<UserModel>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getUsers();
  }
}
