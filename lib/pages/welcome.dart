import 'package:flutter/material.dart';
import 'package:projek/model/cart_model.dart';
import 'home.dart';
import 'meja.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF3D00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Selamat Datang!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Pilih metode pemesanan Anda",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 40),

                buildMenuCard(
                  context: context,
                  icon: Icons.restaurant,
                  title: "Makan di Tempat",
                  subtitle: "Pesan dan nikmati makanan di restoran",
                  onTap: () async {
                    final meja = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(builder: (_) => PilihMejaPage()),
                    );

                    if (!context.mounted) return;

                    if (meja != null) {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setString("orderMethod", "Makan di Tempat");
                      await prefs.setString("tableNumber", meja.toString());

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(
                            orderType: "Makan di Tempat",
                            meja: meja,
                            cart: CartModel(),
                          ),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                buildMenuCard(
                  context: context,
                  icon: Icons.shopping_bag,
                  title: "Bawa Pulang",
                  subtitle: "Pesan dan ambil di konter",
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setString("orderMethod", "Bawa Pulang");
                    await prefs.remove("tableNumber"); // biar ga nyangkut

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          orderType: "Bawa Pulang",
                          cart: CartModel(),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                const Center(
                  child: Text(
                    "GoBite - Pesan Cepat, Makan Enak",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
