import 'package:flutter/material.dart';
import 'package:mega_pro/providers/emp_dash_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Screens
import 'package:mega_pro/auth/login.dart';
import 'package:mega_pro/screens/main_dashboard.dart';

// Providers
import 'providers/user_provider.dart';

import 'providers/authprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://phkkiyxfcepqauxncqpm.supabase.co",
    anonKey: "sb_publishable_GdCo8okHOGBmrW9OH_qsZg_PDOl7a1u",
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
       
       

        ChangeNotifierProvider(create: (_) => EmployeeManagementProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Panel',
        theme: ThemeData(
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const AdminAuthScreen(),
          
          '/dashboard': (_) => const UserDashboardScreen(),

          
        },
      ),
    );
  }
}
