import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeManagementProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> employees = [];
  bool isLoading = false;

  Future<void> fetchEmployees() async {
    isLoading = true;
    notifyListeners();

    final data = await supabase
        .from('emp_profile')
        .select()
        .order('created_at', ascending: false);

    employees = List<Map<String, dynamic>>.from(data);
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEmployee(String id) async {
    await supabase
        .from('emp_profile')
        .delete()
        .eq('id', id);

    employees.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }
}



// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class EmployeeProvider extends ChangeNotifier {
//   Map<String, dynamic>? profile;
//   bool loading = false;

//   Future<void> loadEmployeeProfile() async {
//     loading = true;
//     notifyListeners();

//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) return;

//     final data = await Supabase.instance.client
//         .from('emp_profile')
//         .select()
//         .eq('user_id', user.id)
//         .single();

//     profile = data;
//     loading = false;
//     notifyListeners();
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class EmployeeManagementProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _employees = [];
//   bool _isLoading = true;

//   List<Map<String, dynamic>> get employees => _employees;
//   bool get isLoading => _isLoading;

//   Future<void> fetchEmployees() async {
//     _isLoading = true;
//     notifyListeners();

//     final response = await Supabase.instance.client
//         .from('emp_profile')
//         .select()
//         .eq('role', 'Employee');

//     _employees = List<Map<String, dynamic>>.from(response);
//     _isLoading = false;
//     notifyListeners();
//   }
// }
