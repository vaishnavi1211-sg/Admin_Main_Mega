import 'package:flutter/material.dart';
import 'package:mega_pro/providers/emp_dash_provider.dart';
import 'package:provider/provider.dart';

import 'package:mega_pro/global/global_variables.dart';
 import 'package:mega_pro/screens/emp/emp_AddEmployeeScreen.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EmployeeManagementProvider>().fetchEmployees();
    });
  }

  List<Map<String, dynamic>> _filteredEmployees(
    List<Map<String, dynamic>> employees,
  ) {
    if (_query.isEmpty) return employees;

    return employees.where((emp) {
      final name = (emp['full_name'] ?? '').toLowerCase();
      final email = (emp['email'] ?? '').toLowerCase();
      return name.contains(_query.toLowerCase()) ||
          email.contains(_query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeManagementProvider>();
    final filteredEmployees = _filteredEmployees(provider.employees);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      appBar: AppBar(
        backgroundColor: GlobalColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Employee Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
  backgroundColor: GlobalColors.primaryBlue,
  icon: const Icon(Icons.add, color: AppColors.cardBg),
  label: const Text("Add Employee", style: TextStyle(fontWeight: FontWeight.w600,color: AppColors.cardBg),),
  onPressed: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEmployeeScreen(employeeData: {}),
      ),
    );
    // Refresh the list after adding
    context.read<EmployeeManagementProvider>().fetchEmployees();
  },
),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: GlobalColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Manage Employees",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Add, edit or remove employees",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // SEARCH
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: "Search by name or email",
                      prefixIcon:
                          const Icon(Icons.search, color: GlobalColors.primaryBlue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredEmployees.isEmpty
                            ? _emptyState()
                            : ListView.separated(
                                itemCount: filteredEmployees.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    _buildEmployeeCard(filteredEmployees[i]),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMP CARD =================

  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: GlobalColors.primaryBlue.withOpacity(0.15),
            child: Text(
              emp['full_name'] != null && emp['full_name'].isNotEmpty
                  ? emp['full_name'][0].toUpperCase()
                  : "?",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: GlobalColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp['full_name'] ?? "No Name",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  emp['email'] ?? "No Email",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // ACTIONS
          IconButton(
            icon: const Icon(Icons.edit, color: GlobalColors.primaryBlue),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEmployeeScreen(employeeData: emp),
                ),
              );
              context.read<EmployeeManagementProvider>().fetchEmployees();
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _confirmDelete(emp),
          ),
        ],
      ),
    );
  }

  // ================= DELETE CONFIRM =================

  void _confirmDelete(Map<String, dynamic> emp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Employee"),
        content: Text("Delete ${emp['full_name']} permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<EmployeeManagementProvider>()
                  .deleteEmployee(emp['id']);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text("No employees found"),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:mega_pro/providers/emp_provider)unused.dart';
// import 'package:provider/provider.dart';
// import 'package:mega_pro/global/global_variables';
// import 'package:mega_pro/screens/emp/emp_AddEmployeeScreen.dart';

// class EmployeeManagementScreen extends StatefulWidget {
//   const EmployeeManagementScreen({super.key});

//   @override
//   State<EmployeeManagementScreen> createState() =>
//       _EmployeeManagementScreenState();
// }

// class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
//   final TextEditingController _searchCtrl = TextEditingController();
//   String _query = "";

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       context.read<EmployeeManagementProvider>().fetchEmployees();
//     });
//   }
  

//   List<Map<String, dynamic>> _filteredEmployees(
//       List<Map<String, dynamic>> employees) {
//     if (_query.isEmpty) return employees;
//     return employees.where((emp) {
//       final name = emp['full_name']?.toLowerCase() ?? '';
//       final email = emp['email']?.toLowerCase() ?? '';
//       return name.contains(_query.toLowerCase()) ||
//           email.contains(_query.toLowerCase());
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<EmployeeManagementProvider>();
//     final filteredEmployees = _filteredEmployees(provider.employees);

//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: GlobalColors.primaryBlue,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: GlobalColors.white),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: GlobalColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Employee Management",
//           style: TextStyle(
//             color: GlobalColors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddEmployeeScreen(employeeData: {},)),
//           );
//           context.read<EmployeeManagementProvider>().fetchEmployees();
//         },
//         backgroundColor: GlobalColors.primaryBlue,
//         foregroundColor: GlobalColors.white,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         icon: const Icon(Icons.add, size: 24),
//         label: const Text(
//           "Add Employee",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       body: Column(
//         children: [
//           /// HEADER (UNCHANGED)
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//             decoration: const BoxDecoration(
//               color: GlobalColors.primaryBlue,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Manage Employees",
//                   style: TextStyle(
//                     color: GlobalColors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   "Add and manage enterprise employees",
//                   style: TextStyle(
//                     color: GlobalColors.white,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// BODY
//           Expanded(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: Column(
//                 children: [
//                   /// SEARCH
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: GlobalColors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.shadowGrey.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: _searchCtrl,
//                       onChanged: (v) => setState(() => _query = v),
//                       decoration: InputDecoration(
//                         hintText: "Search employees by name or email...",
//                         prefixIcon: const Icon(Icons.search,
//                             color: GlobalColors.primaryBlue),
//                         filled: true,
//                         fillColor: AppColors.softGreyBg,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 14, horizontal: 16),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Employees",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryText,
//                         ),
//                       ),
//                       Text(
//                         "${filteredEmployees.length} Employees",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.secondaryText,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   Expanded(
//                     child: provider.isLoading
//                         ? _buildLoading()
//                         : filteredEmployees.isEmpty
//                             ? _emptyState()
//                             : ListView.separated(
//                                 physics: const BouncingScrollPhysics(),
//                                 itemCount: filteredEmployees.length,
//                                 separatorBuilder: (_, __) =>
//                                     const SizedBox(height: 12),
//                                 itemBuilder: (context, index) =>
//                                     _buildEmployeeCard(
//                                         filteredEmployees[index]),
//                               ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: GlobalColors.white,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.shadowGrey.withOpacity(0.1),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         /// AVATAR
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: GlobalColors.primaryBlue.withOpacity(0.15),
//           child: Text(
//             (emp['full_name'] != null && emp['full_name'].isNotEmpty)
//                 ? emp['full_name'][0].toUpperCase()
//                 : '?',
//             style: const TextStyle(
//               color: GlobalColors.primaryBlue,
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),

//         /// NAME + EMAIL
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 emp['full_name'] ?? 'No Name',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.primaryText,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 emp['email'] ?? 'No Email',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: AppColors.secondaryText,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         /// ACTIONS
//         Row(
//           children: [
//             /// EDIT
//             IconButton(
//               icon: Icon(
//                 Icons.edit_outlined,
//                 color: GlobalColors.primaryBlue,
//               ),
//               tooltip: "Edit Employee",
//               onPressed: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AddEmployeeScreen(
//                       employeeData: emp, // pass existing data
//                     ),
//                   ),
//                 );
//                 context
//                     .read<EmployeeManagementProvider>()
//                     .fetchEmployees();
//               },
//             ),

//             /// DELETE
//             IconButton(
//               icon: Icon(
//                 Icons.delete_outline,
//                 color: AppColors.successGreen,
//               ),
//               tooltip: "Delete Employee",
//               onPressed: () => _confirmDelete(emp),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//   void _confirmDelete(Map<String, dynamic> emp) {
//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//       ),
//       title: const Text("Delete Employee"),
//       content: Text(
//         "Are you sure you want to delete ${emp['full_name']}?",
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.successGreen,
//           ),
//           onPressed: () async {
//             Navigator.pop(context);
//             await context
//                 .read<EmployeeManagementProvider>()
//                 .deleteEmployee(emp['id']);
//           },
//           child: const Text(
//             "Delete",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   // Widget _buildEmployeeCard(Map<String, dynamic> emp) {
//   //   return Container(
//   //     padding: const EdgeInsets.all(16),
//   //     decoration: BoxDecoration(
//   //       color: GlobalColors.white,
//   //       borderRadius: BorderRadius.circular(12),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: AppColors.shadowGrey.withOpacity(0.1),
//   //           blurRadius: 8,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         CircleAvatar(
//   //           radius: 24,
//   //           backgroundColor: GlobalColors.primaryBlue,
//   //           child: Text(
//   //             (emp['full_name'] != null && emp['full_name'].isNotEmpty)
//   //                 ? emp['full_name'][0].toUpperCase()
//   //                 : '?',
//   //             style: const TextStyle(
//   //               color: GlobalColors.white,
//   //               fontSize: 20,
//   //               fontWeight: FontWeight.bold,
//   //             ),
//   //           ),
//   //         ),
//   //         const SizedBox(width: 16),
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 emp['full_name'] ?? 'No Name',
//   //                 style: TextStyle(
//   //                   fontSize: 16,
//   //                   fontWeight: FontWeight.w600,
//   //                   color: AppColors.primaryText,
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 4),
//   //               Text(
//   //                 emp['email'] ?? 'No Email',
//   //                 style: TextStyle(
//   //                   fontSize: 14,
//   //                   color: AppColors.secondaryText,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _emptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.group_off,
//               size: 64, color: AppColors.secondaryText.withOpacity(0.5)),
//           const SizedBox(height: 16),
//           Text(
//             "No employees found.",
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.secondaryText,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoading() {
//     return Center(
//       child: CircularProgressIndicator(
//         valueColor:
//             AlwaysStoppedAnimation<Color>(GlobalColors.primaryBlue),
//       ),
//     );
//   }
// }