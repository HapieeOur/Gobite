import 'package:flutter/material.dart';
import 'package:projek/admin/kelolamenu.dart';
import 'package:projek/admin/kelolapesanan.dart';
import 'package:projek/pages/splash.dart';
import 'package:projek/services/dashboard_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final service = DashboardService();
  late RealtimeChannel channel;

  int totalMenu = 0;
  int totalOrders = 0;
  int activeOrders = 0;
  int revenue = 0;
  List latestOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
    listenOrdersRealtime();
  }

  @override
  void dispose() {
    channel.unsubscribe();
    super.dispose();
  }

  Future<void> loadDashboard() async {
    try {
      totalMenu = await service.getTotalMenu();
      totalOrders = await service.getTotalOrders();
      activeOrders = await service.getActiveOrders();
      revenue = await service.getTotalRevenue();

      latestOrders = await service.getLatestOrders();
    } catch (e) {
      debugPrint("ERROR DASHBOARD: $e");
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  bool isFetching = false;

  void listenOrdersRealtime() {
    channel = Supabase.instance.client
        .channel('orders-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) async {
            if (!mounted || isFetching) return;
            isFetching = true;
            await loadDashboard();
            await Future.delayed(const Duration(milliseconds: 500));
            isFetching = false;
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _statsGrid(),
                    const SizedBox(height: 20),
                    _menuSection(context),
                    const SizedBox(height: 20),
                    _latestOrders(),
                  ],
                ),
              ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFF6A00), Color(0xffFF3D00)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.grid_view_rounded, color: Colors.white),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin\nDashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "GoBite Management",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SplashPage()),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.home, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS GRID =================
  Widget _statsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
        children: [
          _StatCard(
            title: "Total Pesanan",
            value: "$totalOrders",
            icon: Icons.shopping_bag_outlined,
            iconColor: Colors.blue,
          ),
          _StatCard(
            title: "Total Menu",
            value: "$totalMenu",
            icon: Icons.restaurant_menu,
            iconColor: Colors.orange,
          ),
          _StatCard(
            title: "Pesanan Aktif",
            value: "$activeOrders",
            icon: Icons.inventory_2_outlined,
            iconColor: Colors.purple,
          ),
          _StatCard(
            title: "Total Revenue",
            value: "Rp $revenue",
            icon: Icons.attach_money,
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }

  // ================= MENU SECTION =================
  Widget _menuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),

          // Kelola Menu
          _menuCard(
            icon: Icons.restaurant_menu,
            title: "Kelola Menu",
            subtitle: "CRUD Menu Makanan & Minuman",
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KelolaMenuPage()),
              );

              if (result == true) {
                loadDashboard(); // reload total menu
              }
            },
          ),

          const SizedBox(height: 15),

          // Kelola Pesanan
          _menuCard(
            icon: Icons.receipt_long,
            title: "Kelola Pesanan",
            subtitle: "Lihat & Update Status Pesanan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KelolaPesananPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _latestOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pesanan Terbaru",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // kalau kosong
          if (latestOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.receipt_long, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Belum ada pesanan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            ...latestOrders.map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['order_code'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${order['total_items']} item • Rp ${order['total_price']}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(order['status']),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ================= MENU CARD =================
  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.orange),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
