import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool loading = false;

  int totalOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;

  /// ================= FETCH ORDER COUNTS =================
  Future<void> fetchOrderCounts() async {
    loading = true;
    notifyListeners();

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('emp_feed_orders')
        .select('status')
        .eq('employee_id', user.id);

    totalOrders = response.length;
    pendingOrders =
        response.where((o) => o['status'] == 'pending').length;
    completedOrders =
        response.where((o) => o['status'] == 'completed').length;

    loading = false;
    notifyListeners();
  }

  /// ================= PLACE ORDER =================
  Future<void> placeOrder({
    required String customerName,
    required String mobile,
    required String address,
    required String category,
    required int bags,
    required int weightPerBag,
    required String unit,
    required int pricePerBag,
    String? remarks,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final totalWeight = bags * weightPerBag;
    final totalPrice = bags * pricePerBag;

    await supabase.from('emp_feed_orders').insert({
      'employee_id': user.id,
      'customer_name': customerName,
      'customer_mobile': mobile,
      'customer_address': address,
      'feed_category': category,
      'bags': bags,
      'weight_per_bag': weightPerBag,
      'weight_unit': unit,
      'total_weight': totalWeight,
      'price_per_bag': pricePerBag,
      'total_price': totalPrice,
      'remarks': remarks,
      'status': 'pending',
    });

    await fetchOrderCounts(); // 🔥 realtime refresh
  }
}


// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class EmployeeProvider extends ChangeNotifier {
//   final supabase = Supabase.instance.client;

//   bool loading = true;

//   Map<String, dynamic>? profile;

//   int totalOrders = 0;
//   int pendingOrders = 0;
//   int completedOrders = 0;

//   RealtimeChannel? _ordersChannel;

//   // ================= LOAD EVERYTHING =================
//   Future<void> loadEmployeeProfile() async {
//     loading = true;
//     notifyListeners();

//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     // Profile
//     profile = await supabase
//         .from('emp_profile')
//         .select()
//         .eq('user_id', user.id)
//         .single();

//     final empId = profile!['id'];

//     await _loadOrders(empId);
//     _listenOrders(empId);

//     loading = false;
//     notifyListeners();
//   }

//   // ================= LOAD ORDERS =================
//   Future<void> _loadOrders(String empId) async {
//     final orders = await supabase
//         .from('orders')
//         .select('status')
//         .eq('employee_id', empId);

//     totalOrders = orders.length;
//     pendingOrders =
//         orders.where((o) => o['status'] == 'pending').length;
//     completedOrders =
//         orders.where((o) => o['status'] == 'completed').length;
//   }

//   // ================= REALTIME =================
//   void _listenOrders(String empId) {
//     _ordersChannel = supabase
//         .channel('orders-$empId')
//         .onPostgresChanges(
//           event: PostgresChangeEvent.all,
//           schema: 'public',
//           table: 'orders',
//           filter: PostgresChangeFilter(
//             type: PostgresChangeFilterType.eq,
//             column: 'employee_id',
//             value: empId,
//           ),
//           callback: (_) async {
//             await _loadOrders(empId);
//             notifyListeners();
//           },
//         )
//         .subscribe();
//   }

//   @override
//   void dispose() {
//     if (_ordersChannel != null) {
//       supabase.removeChannel(_ordersChannel!);
//     }
//     super.dispose();
//   }
// }
