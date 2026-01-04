import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mega_pro/screens/main_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthScreen extends StatefulWidget {
  const AdminAuthScreen({super.key});

  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? "Admin Login" : "Admin Sign Up",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isLogin
                      ? "Login to access Admin Panel"
                      : "Create Admin Account",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                /// FORM
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _inputField(
                        label: "Email",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),

                      _inputField(
                        label: "Password",
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),

                      if (!isLogin)
                        _inputField(
                          label: "Confirm Password",
                          icon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          isPassword: true,
                        ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isLogin ? "Login as Admin" : "Sign Up as Admin",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                      errorMessage = null;
                      _confirmPasswordController.clear();
                    });
                  },
                  child: Text.rich(
                    TextSpan(
                      text: isLogin
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      children: [
                        TextSpan(
                          text: isLogin ? "Sign Up" : "Login",
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "This field is required";
        if (label == "Email" && !value.contains("@")) {
          return "Enter valid email";
        }
        if (label == "Confirm Password" &&
            value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  /// 🔐 ADMIN AUTH LOGIC (FIXED)
  Future<void> _handleAuth() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => errorMessage = null);

  try {
    final supabase = Supabase.instance.client;

    final res = await supabase.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final user = res.user;

    if (user == null) {
      throw Exception("Login failed");
    }

    // ✅ Email verification check
    if (user.emailConfirmedAt == null) {
      await supabase.auth.signOut();
      throw Exception("Please verify your email before login");
    }

    // ✅ Check admin table (IMPORTANT FIX)
    final admin = await supabase
        .from('admins')
        .select()
        .eq('id', user.id) // 🔥 FIXED
        .maybeSingle();

    if (admin == null) {
      await supabase.auth.signOut();
      throw Exception("Not authorized as admin");
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const UserDashboardScreen(),
      ),
    );
  } catch (e) {
    setState(() {
      errorMessage = e.toString().replaceAll('Exception:', '');
    });
  }
}




}
