import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek/admin/dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    final res = await Supabase.instance.client
        .from('Admin')
        .select()
        .eq('username', usernameC.text.trim())
        .eq('password', passwordC.text.trim())
        .limit(1)
        .maybeSingle();

    setState(() => loading = false);

    if (!mounted) return;

    if (res != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  AdminDashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Username atau password salah")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF4F4F4),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
          children: [

            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6A00), Color(0xFFFF2E00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 46),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Admin Panel",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "GoBite Management System",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    _inputField(
                      controller: usernameC,
                      hint: "Masukkan username",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 16),

                    _inputField(
                      controller: passwordC,
                      hint: "Masukkan password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Login Admin", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Kembali ke Aplikasi", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:  Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}