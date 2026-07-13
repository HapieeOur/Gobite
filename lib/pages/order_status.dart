import 'package:flutter/material.dart';
import 'package:projek/model/cart_model.dart';
import 'package:projek/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderStatusPage extends StatefulWidget {
  final String orderId;
  final String paymentMethod;

  const OrderStatusPage({
    super.key,
    required this.orderId,
    required this.paymentMethod,
  });

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _lastOrder;

  late final Stream<List<Map<String, dynamic>>> orderStream;

  @override
  void initState() {
    super.initState();

    orderStream = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('order_code', widget.orderId);
  }

  IconData getStatusIconFromString(String status) {
    switch (status) {
      case "selesai":
        return Icons.check_circle;
      case "dibatalkan":
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  String getStatusTextFromString(String status) {
    switch (status) {
      case "diproses":
        return "Pesanan Anda sedang diproses";
      case "selesai":
        return "Pesanan sudah siap diambil";
      case "dibatalkan":
        return "Pesanan dibatalkan";
      default:
        return "Menunggu...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF3D00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: orderStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                _lastOrder = snapshot.data!.first;
              }

              final order = _lastOrder;

              if (order == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final status = order['status'] ?? 'diproses';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Pesanan Berhasil!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Nomor Pesanan",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 38,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        widget.orderId,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 50,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            getStatusIconFromString(status),
                            size: 58,
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "Silahkan Ditunggu",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            getStatusTextFromString(status),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (widget.paymentMethod == "QRIS")
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      "assets/images/qrisDana.jpeg",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          if (status == "diproses")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Dot(), Dot(), Dot()],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HomePage(cart: CartModel()),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text("Pesan Lagi"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(cart: CartModel()),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                "Kembali ke Beranda",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Terima kasih telah memesan di GoBite!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
    );
  }
}