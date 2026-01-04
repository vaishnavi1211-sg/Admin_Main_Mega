import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool submitting = false;
  bool markedToday = false;

  /// ================= CHECK TODAY =================
  Future<void> checkTodayAttendance() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final data = await supabase
        .from('emp_attendance')
        .select()
        .eq('employee_id', user.id)
        .gte('created_at', '$today 00:00:00')
        .lte('created_at', '$today 23:59:59');

    markedToday = data.isNotEmpty;
    notifyListeners();
  }

  /// ================= MARK ATTENDANCE =================
  Future<void> markAttendance({
    required File image,
    required String employeeName,
    required String employeeCode,
  }) async {
    submitting = true;
    notifyListeners();

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final fileName =
        '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    /// Upload selfie
    await supabase.storage
        .from('emp_attendance_images')
        .upload(fileName, image);

    final imageUrl = supabase.storage
        .from('emp_attendance_images')
        .getPublicUrl(fileName);

    /// Insert attendance
    await supabase.from('emp_attendance').insert({
      'employee_id': user.id,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'selfie_image': imageUrl,
      'source': 'camera',
    });

    markedToday = true;
    submitting = false;
    notifyListeners();
  }
}
