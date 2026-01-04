import 'package:flutter/material.dart';
import 'package:mega_pro/screens/emp/emp_AddEmployeeScreen.dart';
import 'package:mega_pro/screens/emp/emp_management.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mega_pro/global/app_colors.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int employeeCount = 0;
  int productionManagerCount = 0;
  int marketingManagerCount = 0;
  int ownerCount = 0;
  int totalUsers = 0;
  int totalBranches = 0;
  
  List<Map<String, dynamic>> recentUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      
      final employees = await supabase
          .from('emp_profile')
          .select('*');
      
      employeeCount = employees.where((e) => e['role'] == 'Employee').length;
      productionManagerCount = employees.where((e) => e['role'] == 'Production Manager').length;
      marketingManagerCount = employees.where((e) => e['role'] == 'Marketing Manager').length;
      ownerCount = employees.where((e) => e['role'] == 'Owner').length;
      totalUsers = employees.length;
      
      recentUsers = employees
        .where((e) => e['joining_date'] != null)
        .toList()
        ..sort((a, b) => DateTime.parse(b['joining_date'] ?? '')
            .compareTo(DateTime.parse(a['joining_date'] ?? '')));
      
      if (recentUsers.length > 5) {
        recentUsers = recentUsers.sublist(0, 5);
      }
      
      try {
        final branches = await supabase
            .from('branches')
            .select('*')
            .catchError((_) => []);
        totalBranches = branches.length;
      } catch (_) {
        totalBranches = 0;
      }
      
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      // Changed from Add Branch to Add User
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEmployeeScreen(employeeData: {},), // Changed to AddEmployeeScreen
            ),
          ).then((_) => _refreshData());
        },
        icon: const Icon(Icons.person_add, color: Colors.white), // Changed icon
        label: const Text(
          "Add User", // Changed label
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dashboard Overview                  ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Total: $totalUsers Users • $totalBranches Branches",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    const Text(
                      "User Statistics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Summary of all personnel by role",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 11,
                      childAspectRatio: 1.3,
                      children: [
                        _statCard(
                          icon: Icons.badge_outlined,
                          title: "Employees",
                          count: employeeCount,
                          color: AppColors.primaryBlue,
                          subtitle: "Regular Staff",
                        ),
                        _statCard(
                          icon: Icons.precision_manufacturing_outlined,
                          title: "Production",
                          count: productionManagerCount,
                          color: const Color(0xFFFF8A00),
                          subtitle: "Managers",
                        ),
                        _statCard(
                          icon: Icons.campaign_outlined,
                          title: "Marketing",
                          count: marketingManagerCount,
                          color: const Color(0xFF7B3FF2),
                          subtitle: "Managers",
                        ),
                        _statCard(
                          icon: Icons.verified_user_outlined,
                          title: "Owners",
                          count: ownerCount,
                          color: const Color(0xFF0FBF75),
                          subtitle: "Administrators",
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Additional Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _compactStatCard(
                            title: "Total Users",
                            value: totalUsers.toString(),
                            color: AppColors.primaryBlue,
                            icon: Icons.people,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[200],
                          ),
                          _compactStatCard(
                            title: "Branches",
                            value: totalBranches.toString(),
                            color: const Color(0xFF7B3FF2),
                            icon: Icons.business,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Registrations Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Registrations",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EmployeeManagementScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (recentUsers.isEmpty)
                      _emptyState("No recent registrations")
                    else
                      Column(
                        children: recentUsers.map((user) {
                          return _recentTile(user);
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        String role;
        switch (title) {
          case "Employees":
            role = 'Employee';
            break;
          case "Production":
            role = 'Production Manager';
            break;
          case "Marketing":
            role = 'Marketing Manager';
            break;
          case "Owners":
            role = 'Owner';
            break;
          default:
            role = 'Employee';
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoleUsersScreen(title: "$title $subtitle", role: role),
          ),
        ).then((_) => _refreshData());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _recentTile(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(.15),
          radius: 22,
          child: Text(
            user['full_name'] != null && user['full_name'].isNotEmpty
                ? user['full_name'][0].toUpperCase()
                : "?",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        title: Text(
          user['full_name'] ?? 'No Name',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['role'] ?? 'No Role',
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (user['position'] != null)
              Text(
                user['position'],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0FBF75).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Active",
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF0FBF75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RoleUsersScreen extends StatefulWidget {
  final String title;
  final String role;

  const RoleUsersScreen({
    super.key,
    required this.title,
    required this.role,
  });

  @override
  State<RoleUsersScreen> createState() => _RoleUsersScreenState();
}

class _RoleUsersScreenState extends State<RoleUsersScreen> {
  String search = '';
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('emp_profile')
          .select('*')
          .eq('role', widget.role);
      
      setState(() => users = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('emp_profile').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final name = (user['full_name'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      final query = search.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Chip(
                  label: Text('Total: ${users.length}'),
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Showing: ${filteredUsers.length}'),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFF0FBF75)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? _emptyState("No users found")
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (_, i) {
                          final user = filteredUsers[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryBlue.withOpacity(.15),
                                child: Text(
                                  user['full_name'] != null && user['full_name'].isNotEmpty
                                      ? user['full_name'][0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              title: Text(user['full_name'] ?? 'No Name'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? 'No Email'),
                                  if (user['position'] != null)
                                    Text(
                                      user['position'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(user),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Delete ${user['full_name']} permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user['id']);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:mega_pro/screens/add_branch.dart';
// import 'package:mega_pro/screens/emp/emp_management.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:mega_pro/global/app_colors.dart';

// class UserDashboardScreen extends StatefulWidget {
//   const UserDashboardScreen({super.key});

//   @override
//   State<UserDashboardScreen> createState() => _UserDashboardScreenState();
// }

// class _UserDashboardScreenState extends State<UserDashboardScreen> {
//   int employeeCount = 0;
//   int productionManagerCount = 0;
//   int marketingManagerCount = 0;
//   int ownerCount = 0;
//   int totalUsers = 0;
//   int totalBranches = 0;
  
//   List<Map<String, dynamic>> recentUsers = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }

//   Future<void> _loadDashboardData() async {
//     setState(() => isLoading = true);
    
//     try {
//       final supabase = Supabase.instance.client;
      
//       final employees = await supabase
//           .from('emp_profile')
//           .select('*');
      
//       employeeCount = employees.where((e) => e['role'] == 'Employee').length;
//       productionManagerCount = employees.where((e) => e['role'] == 'Production Manager').length;
//       marketingManagerCount = employees.where((e) => e['role'] == 'Marketing Manager').length;
//       ownerCount = employees.where((e) => e['role'] == 'Owner').length;
//       totalUsers = employees.length;
      
//       recentUsers = employees
//         .where((e) => e['joining_date'] != null)
//         .toList()
//         ..sort((a, b) => DateTime.parse(b['joining_date'] ?? '')
//             .compareTo(DateTime.parse(a['joining_date'] ?? '')));
      
//       if (recentUsers.length > 5) {
//         recentUsers = recentUsers.sublist(0, 5);
//       }
      
//       try {
//         final branches = await supabase
//             .from('branches')
//             .select('*')
//             .catchError((_) => []);
//         totalBranches = branches.length;
//       } catch (_) {
//         totalBranches = 0;
//       }
      
//     } catch (e) {
//       print('Error loading dashboard data: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _refreshData() async {
//     await _loadDashboardData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryBlue,
//         elevation: 0,
//         title: const Text(
//           "Admin Dashboard",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshData,
//             tooltip: 'Refresh Data',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const AddBranchScreen(),
//             ),
//           ).then((_) => _refreshData());
//         },
//         icon: const Icon(Icons.add_business, color: Colors.white), // White icon
//         label: const Text(
//           "Add Branch",
//           style: TextStyle(color: Colors.white), // White text
//         ),
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: Colors.white, // This ensures ripple effect is white
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _refreshData,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.only(
//                   left: 16,
//                   right: 16,
//                   top: 16,
//                   bottom: 100, // Extra bottom padding for FAB
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Dashboard Header
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryBlue,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Dashboard Overview                  ",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Total: $totalUsers Users • $totalBranches Branches",
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.9),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     const SizedBox(height: 20),

//                     const Text(
//                       "User Statistics",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       "Summary of all personnel by role",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 20),

//                     // Stats Grid - Fixed aspect ratio
//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 11,
//                       childAspectRatio: 1.3, // Adjusted for better fit
//                       children: [
//                         _statCard(
//                           icon: Icons.badge_outlined,
//                           title: "Employees",
//                           count: employeeCount,
//                           color: AppColors.primaryBlue,
//                           subtitle: "Regular Staff",
//                         ),
//                         _statCard(
//                           icon: Icons.precision_manufacturing_outlined,
//                           title: "Production",
//                           count: productionManagerCount,
//                           color: const Color(0xFFFF8A00),
//                           subtitle: "Managers",
//                         ),
//                         _statCard(
//                           icon: Icons.campaign_outlined,
//                           title: "Marketing",
//                           count: marketingManagerCount,
//                           color: const Color(0xFF7B3FF2),
//                           subtitle: "Managers",
//                         ),
//                         _statCard(
//                           icon: Icons.verified_user_outlined,
//                           title: "Owners",
//                           count: ownerCount,
//                           color: const Color(0xFF0FBF75),
//                           subtitle: "Administrators",
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Additional Stats - Compact layout
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(.04),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           _compactStatCard(
//                             title: "Total Users",
//                             value: totalUsers.toString(),
//                             color: AppColors.primaryBlue,
//                             icon: Icons.people,
//                           ),
//                           Container(
//                             width: 1,
//                             height: 40,
//                             color: Colors.grey[200],
//                           ),
//                           _compactStatCard(
//                             title: "Branches",
//                             value: totalBranches.toString(),
//                             color: const Color(0xFF7B3FF2),
//                             icon: Icons.business,
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Recent Registrations Section
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Recent Registrations",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => const EmployeeManagementScreen(),
//                                 ),
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(horizontal: 8),
//                             ),
//                             child: const Text(
//                               "View All",
//                               style: TextStyle(
//                                 color: AppColors.primaryBlue,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     if (recentUsers.isEmpty)
//                       _emptyState("No recent registrations")
//                     else
//                       Column(
//                         children: recentUsers.map((user) {
//                           return _recentTile(user);
//                         }).toList(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _statCard({
//     required IconData icon,
//     required String title,
//     required int count,
//     required Color color,
//     required String subtitle,
//   }) {
//     return InkWell(
//       onTap: () {
//         String role;
//         switch (title) {
//           case "Employees":
//             role = 'Employee';
//             break;
//           case "Production":
//             role = 'Production Manager';
//             break;
//           case "Marketing":
//             role = 'Marketing Manager';
//             break;
//           case "Owners":
//             role = 'Owner';
//             break;
//           default:
//             role = 'Employee';
//         }
        
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => RoleUsersScreen(title: "$title $subtitle", role: role),
//           ),
//         ).then((_) => _refreshData());
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(.06),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(.12),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(icon, color: color, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey[600],
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               count.toString(),
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _compactStatCard({
//     required String title,
//     required String value,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(.12),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: color, size: 22),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _recentTile(Map<String, dynamic> user) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 1.5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         leading: CircleAvatar(
//           backgroundColor: AppColors.primaryBlue.withOpacity(.15),
//           radius: 22,
//           child: Text(
//             user['full_name'] != null && user['full_name'].isNotEmpty
//                 ? user['full_name'][0].toUpperCase()
//                 : "?",
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryBlue,
//             ),
//           ),
//         ),
//         title: Text(
//           user['full_name'] ?? 'No Name',
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 15,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               user['role'] ?? 'No Role',
//               style: const TextStyle(fontSize: 13),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (user['position'] != null)
//               Text(
//                 user['position'],
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[600],
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//           ],
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: const Color(0xFF0FBF75).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             "Active",
//             style: TextStyle(
//               fontSize: 11,
//               color: const Color(0xFF0FBF75),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _emptyState(String message) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(color: Colors.grey[500]),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RoleUsersScreen extends StatefulWidget {
//   final String title;
//   final String role;

//   const RoleUsersScreen({
//     super.key,
//     required this.title,
//     required this.role,
//   });

//   @override
//   State<RoleUsersScreen> createState() => _RoleUsersScreenState();
// }

// class _RoleUsersScreenState extends State<RoleUsersScreen> {
//   String search = '';
//   List<Map<String, dynamic>> users = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }

//   Future<void> _loadUsers() async {
//     setState(() => isLoading = true);
    
//     try {
//       final supabase = Supabase.instance.client;
      
//       final response = await supabase
//           .from('emp_profile')
//           .select('*')
//           .eq('role', widget.role);
      
//       setState(() => users = List<Map<String, dynamic>>.from(response));
//     } catch (e) {
//       print('Error loading users: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _deleteUser(String id) async {
//     try {
//       final supabase = Supabase.instance.client;
//       await supabase.from('emp_profile').delete().eq('id', id);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('User deleted successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       _loadUsers();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredUsers = users.where((user) {
//       final name = (user['full_name'] ?? '').toLowerCase();
//       final email = (user['email'] ?? '').toLowerCase();
//       final query = search.toLowerCase();
//       return name.contains(query) || email.contains(query);
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search by name or email',
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               ),
//               onChanged: (v) => setState(() => search = v),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Chip(
//                   label: Text('Total: ${users.length}'),
//                   backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//                   labelStyle: TextStyle(color: AppColors.primaryBlue),
//                 ),
//                 const SizedBox(width: 8),
//                 Chip(
//                   label: Text('Showing: ${filteredUsers.length}'),
//                   backgroundColor: Colors.green.withOpacity(0.1),
//                   labelStyle: const TextStyle(color: Color(0xFF0FBF75)),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : filteredUsers.isEmpty
//                     ? _emptyState("No users found")
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         itemCount: filteredUsers.length,
//                         itemBuilder: (_, i) {
//                           final user = filteredUsers[i];
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             child: ListTile(
//                               leading: CircleAvatar(
//                                 backgroundColor: AppColors.primaryBlue.withOpacity(.15),
//                                 child: Text(
//                                   user['full_name'] != null && user['full_name'].isNotEmpty
//                                       ? user['full_name'][0].toUpperCase()
//                                       : "?",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.primaryBlue,
//                                   ),
//                                 ),
//                               ),
//                               title: Text(user['full_name'] ?? 'No Name'),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(user['email'] ?? 'No Email'),
//                                   if (user['position'] != null)
//                                     Text(
//                                       user['position'],
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               trailing: IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _confirmDelete(user),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _emptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmDelete(Map<String, dynamic> user) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete User"),
//         content: Text("Delete ${user['full_name']} permanently?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteUser(user['id']);
//             },
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:mega_pro/screens/emp/emp_management.dart';
// // import 'package:provider/provider.dart';
// // import 'package:mega_pro/models/user_model.dart';
// // import 'package:mega_pro/providers/user_provider.dart';

// // class UserDashboardScreen extends StatelessWidget {
// //   const UserDashboardScreen({super.key});

// //   static const Color primaryBlue = Color(0xFF2563EB);
// //   static const Color scaffoldBg = Color(0xFFF1F5F9);

// //   @override
// //   Widget build(BuildContext context) {
// //     final users = context.watch<UserProvider>().users;

// //     final employees = users.where((u) => u.role == 'Employee').toList();
// //     final production =
// //         users.where((u) => u.role == 'Production Manager').toList();
// //     final marketing =
// //         users.where((u) => u.role == 'Marketing Manager').toList();
// //     final owners = users.where((u) => u.role == 'Owner').toList();

// //     return Scaffold(
// //       backgroundColor: scaffoldBg,

// //       // 🔵 BLUE ADMIN APP BAR
// //       appBar: AppBar(
// //         backgroundColor: primaryBlue,
// //         elevation: 0,
// //         title: const Text(
// //           "Admin Dashboard",
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         iconTheme: const IconThemeData(color: Colors.white),
// //       ),

// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               "Registered Users",
// //               style: TextStyle(
// //                 fontSize: 22,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             const Text(
// //               "Summary of all registered personnel by role",
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //             const SizedBox(height: 20),

// //             _statCard(
// //               context,
// //               icon: Icons.badge_outlined,
// //               title: "Employees",
// //               count: employees.length,
// //               color: primaryBlue,
// //               users: employees,
              
// //             ),
// //             _statCard(
// //               context,
// //               icon: Icons.precision_manufacturing_outlined,
// //               title: "Production Managers",
// //               count: production.length,
// //               color: const Color(0xFFFF8A00),
// //               users: production,
// //             ),
// //             _statCard(
// //               context,
// //               icon: Icons.campaign_outlined,
// //               title: "Marketing Managers",
// //               count: marketing.length,
// //               color: const Color(0xFF7B3FF2),
// //               users: marketing,
// //             ),
// //             _statCard(
// //               context,
// //               icon: Icons.verified_user_outlined,
// //               title: "Owners",
// //               count: owners.length,
// //               color: const Color(0xFF0FBF75),
// //               users: owners,
// //             ),

// //             const SizedBox(height: 30),

// //             const Text(
// //               "Recent Registrations",
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 10),

// //             if (users.isEmpty)
// //               const Text(
// //                 "No users registered yet",
// //                 style: TextStyle(color: Colors.grey),
// //               )
// //             else
// //               ...users.reversed.take(5).map(_recentTile),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================= STAT CARD =================
// //   Widget _statCard(
// //     BuildContext context, {
// //     required IconData icon,
// //     required String title,
// //     required int count,
// //     required Color color,
// //     required List<UserModel> users,
// //   }) {
// //     return InkWell(
// //       onTap: () {
// //   if (title == "Employees") {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => const EmployeeManagementScreen(),
// //       ),
// //     );
// //   } else {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => RoleUsersScreen(title: title, users: users),
// //       ),
// //     );
// //   }
// // },

// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 14),
// //         padding: const EdgeInsets.all(18),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(.06),
// //               blurRadius: 12,
// //               offset: const Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: color.withOpacity(.12),
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Icon(icon, color: color),
// //             ),
// //             const SizedBox(width: 16),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     title,
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //                   Text(
// //                     "$count",
// //                     style: TextStyle(
// //                       fontSize: 26,
// //                       fontWeight: FontWeight.bold,
// //                       color: color,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const Icon(Icons.arrow_forward_ios,
// //                 size: 16, color: Colors.grey),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _recentTile(UserModel user) {
// //     return Card(
// //       elevation: 1.5,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundColor: primaryBlue.withOpacity(.15),
// //           child: const Icon(Icons.person, color: primaryBlue),
// //         ),
// //         title: Text(user.name),
// //         subtitle: Text(user.role),
// //         trailing: const Chip(label: Text("Active")),
// //       ),
// //     );
// //   }
// // }

// // class RoleUsersScreen extends StatefulWidget {
// //   final String title;
// //   final List<UserModel> users;

// //   const RoleUsersScreen({
// //     super.key,
// //     required this.title,
// //     required this.users,
// //   });

// //   @override
// //   State<RoleUsersScreen> createState() => _RoleUsersScreenState();
// // }   

// // class _RoleUsersScreenState extends State<RoleUsersScreen> {
// //   String search = '';
// //   String roleFilter = 'All';

// //   @override
// //   Widget build(BuildContext context) {
// //     final provider = context.watch<UserProvider>();

// //     final filtered = provider.users.where((u) {
// //       final matchesSearch =
// //           u.name.toLowerCase().contains(search.toLowerCase()) ||
// //               u.email.toLowerCase().contains(search.toLowerCase());
// //       final matchesRole = roleFilter == 'All' || u.role == roleFilter;
// //       return matchesSearch && matchesRole;
// //     }).toList();

// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.title)),
// //       body: Column(
// //         children: [
// //           _filterBar(),
// //           Expanded(
// //             child: filtered.isEmpty
// //                 ? const Center(child: Text("No users found"))
// //                 : ListView.builder(
// //                     itemCount: filtered.length,
// //                     itemBuilder: (_, i) {
// //                       final user = filtered[i];
// //                       return Card(
// //                         child: ListTile(
// //                           leading:
// //                               const CircleAvatar(child: Icon(Icons.person)),
// //                           title: Text(user.name),
// //                           subtitle: Text(user.email),
// //                           trailing: IconButton(
// //                             icon:
// //                                 const Icon(Icons.delete, color: Colors.red),
// //                             onPressed: () =>
// //                                 _confirmDelete(context, user),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _filterBar() {
// //     return Padding(
// //       padding: const EdgeInsets.all(12),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextField(
// //               decoration: const InputDecoration(
// //                 hintText: 'Search name or email',
// //                 prefixIcon: Icon(Icons.search),
// //               ),
// //               onChanged: (v) => setState(() => search = v),
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           DropdownButton<String>(
// //             value: roleFilter,
// //             items: const [
// //               'All',
// //               'Owner',
// //               'Marketing Manager',
// //               'Production Manager',
// //               'Employee'
// //             ]
// //                 .map(
// //                   (e) =>
// //                       DropdownMenuItem(value: e, child: Text(e)),
// //                 )
// //                 .toList(),
// //             onChanged: (v) => setState(() => roleFilter = v!),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _confirmDelete(BuildContext context, UserModel user) {
// //     showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text("Delete User"),
// //         content: Text("Delete ${user.name}?"),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text("Cancel"),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               context.read<UserProvider>().deleteUser(user.id);
// //               Navigator.pop(context);
// //             },
// //             child: const Text(
// //               "Delete",
// //               style: TextStyle(color: Colors.red),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }




// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:mega_pro/models/user_model.dart';
// // import 'package:mega_pro/providers/user_provider.dart';

// // class UserDashboardScreen extends StatelessWidget {
// //   const UserDashboardScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final users = context.watch<UserProvider>().users;

// //     final employees = users.where((u) => u.role == 'Employee').toList();
// //     final production =
// //         users.where((u) => u.role == 'Production Manager').toList();
// //     final marketing =
// //         users.where((u) => u.role == 'Marketing Manager').toList();
// //     final owners = users.where((u) => u.role == 'Owner').toList();

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FB),

// //       // ✅ PROPER APP BAR (no FAB anywhere)
// //       appBar: AppBar(
// //         title: const Text(
// //           "User Management",
// //           style: TextStyle(fontWeight: FontWeight.w600),
// //         ),
// //       ),

// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               "Registered Users",
// //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 4),
// //             const Text(
// //               "Summary of all registered personnel by role",
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //             const SizedBox(height: 20),

// //             _statCard(
// //               context,
// //               icon: Icons.badge_outlined,
// //               title: "Employees",
// //               count: employees.length,
// //               color: const Color(0xFF1E6FFF),
// //               users: employees,
// //             ),
// //             _statCard(
// //               context,
// //               icon: Icons.precision_manufacturing_outlined,
// //               title: "Production Managers",
// //               count: production.length,
// //               color: const Color(0xFFFF8A00),
// //               users: production,
// //             ),
// //             _statCard(
// //               context,
// //               icon: Icons.campaign_outlined,
// //               title: "Marketing Managers",
// //               count: marketing.length,
// //               color: const Color(0xFF7B3FF2),
// //               users: marketing,
// //             ),
// //             _statCard(
// //               context,
// //               icon: Icons.verified_user_outlined,
// //               title: "Owners",
// //               count: owners.length,
// //               color: const Color(0xFF0FBF75),
// //               users: owners,
// //             ),

// //             const SizedBox(height: 30),
// //             const Text(
// //               "Recent Registrations",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 10),

// //             if (users.isEmpty)
// //               const Text(
// //                 "No users registered yet",
// //                 style: TextStyle(color: Colors.grey),
// //               )
// //             else
// //               ...users.reversed.take(5).map(_recentTile),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _statCard(
// //     BuildContext context, {
// //     required IconData icon,
// //     required String title,
// //     required int count,
// //     required Color color,
// //     required List<UserModel> users,
// //   }) {
// //     return InkWell(
// //       onTap: () {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => RoleUsersScreen(title: title, users: users),
// //           ),
// //         );
// //       },
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 14),
// //         padding: const EdgeInsets.all(18),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(.05),
// //               blurRadius: 10,
// //               offset: const Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: color.withOpacity(.12),
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Icon(icon, color: color),
// //             ),
// //             const SizedBox(width: 16),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     title,
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //                   Text(
// //                     "$count",
// //                     style: TextStyle(
// //                       fontSize: 26,
// //                       fontWeight: FontWeight.bold,
// //                       color: color,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const Icon(Icons.arrow_forward_ios,
// //                 size: 16, color: Colors.grey),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _recentTile(UserModel user) {
// //     return Card(
// //       child: ListTile(
// //         leading: const CircleAvatar(child: Icon(Icons.person)),
// //         title: Text(user.name),
// //         subtitle: Text(user.role),
// //         trailing: const Chip(label: Text("Active")),
// //       ),
// //     );
// //   }
// // }

// // ////////////////////////////////////////////////////////////////
// // /// ROLE USERS SCREEN (unchanged)
// // ////////////////////////////////////////////////////////////////

// // class RoleUsersScreen extends StatefulWidget {
// //   final String title;
// //   final List<UserModel> users;

// //   const RoleUsersScreen({
// //     super.key,
// //     required this.title,
// //     required this.users,
// //   });

// //   @override
// //   State<RoleUsersScreen> createState() => _RoleUsersScreenState();
// // }

// // class _RoleUsersScreenState extends State<RoleUsersScreen> {
// //   String search = '';
// //   String roleFilter = 'All';

// //   @override
// //   Widget build(BuildContext context) {
// //     final provider = context.watch<UserProvider>();

// //     final filtered = provider.users.where((u) {
// //       final matchesSearch =
// //           u.name.toLowerCase().contains(search.toLowerCase()) ||
// //               u.email.toLowerCase().contains(search.toLowerCase());
// //       final matchesRole = roleFilter == 'All' || u.role == roleFilter;
// //       return matchesSearch && matchesRole;
// //     }).toList();

// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.title)),
// //       body: Column(
// //         children: [
// //           _filterBar(),
// //           Expanded(
// //             child: filtered.isEmpty
// //                 ? const Center(child: Text("No users found"))
// //                 : ListView.builder(
// //                     itemCount: filtered.length,
// //                     itemBuilder: (_, i) {
// //                       final user = filtered[i];
// //                       return Card(
// //                         child: ListTile(
// //                           leading:
// //                               const CircleAvatar(child: Icon(Icons.person)),
// //                           title: Text(user.name),
// //                           subtitle: Text(user.email),
// //                           trailing: IconButton(
// //                             icon:
// //                                 const Icon(Icons.delete, color: Colors.red),
// //                             onPressed: () =>
// //                                 _confirmDelete(context, user),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _filterBar() {
// //     return Padding(
// //       padding: const EdgeInsets.all(12),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextField(
// //               decoration: const InputDecoration(
// //                 hintText: 'Search name or email',
// //                 prefixIcon: Icon(Icons.search),
// //               ),
// //               onChanged: (v) => setState(() => search = v),
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           DropdownButton<String>(
// //             value: roleFilter,
// //             items: const [
// //               'All',
// //               'Owner',
// //               'Marketing Manager',
// //               'Production Manager',
// //               'Employee'
// //             ]
// //                 .map(
// //                   (e) =>
// //                       DropdownMenuItem(value: e, child: Text(e)),
// //                 )
// //                 .toList(),
// //             onChanged: (v) => setState(() => roleFilter = v!),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _confirmDelete(BuildContext context, UserModel user) {
// //     showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text("Delete User"),
// //         content: Text("Delete ${user.name}?"),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text("Cancel"),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               context.read<UserProvider>().deleteUser(user.id);
// //               Navigator.pop(context);
// //             },
// //             child: const Text(
// //               "Delete",
// //               style: TextStyle(color: Colors.red),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
