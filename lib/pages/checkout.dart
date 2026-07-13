import 'package:flutter/material.dart';
import 'package:projek/model/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek/services/order_service.dart';
import 'order_status.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;
  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<CartItem> cart;

  String orderMethod = "";
  String tableNumber = "";
  String orderNotes = "";
  String? paymentMethod;

  double subtotal = 0;
  double tax = 0;
  double total = 0;

  @override
  void initState() {
    super.initState();
    cart = widget.cart;
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      orderMethod = prefs.getString("orderMethod") ?? "Bawa Pulang";
      tableNumber = prefs.getString("tableNumber") ?? "";
      orderNotes = prefs.getString("orderNotes") ?? "";
      calculateTotals();
    });
  }

  void calculateTotals() {
    subtotal = cart.fold(0, (sum, item) => sum + (item.price * item.qty));
    tax = subtotal * 0.1;
    total = subtotal + tax;
  }

  String formatRp(num value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}";
  }

  void handleConfirm() async {
    if (paymentMethod == null) return;

    final orderCode = await OrderService.createOrder(
      orderMethod: orderMethod,
      tableNumber: tableNumber,
      items: cart
          .map(
            (e) => {
              "id": e.id,
              "name": e.name,
              "price": e.price,
              "quantity": e.qty,
            },
          )
          .toList(),
      total: total,
      notes: orderNotes,
      paymentMethod: paymentMethod!,
    );

    if (!mounted) return;

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OrderStatusPage(
      orderId: orderCode,
      paymentMethod: paymentMethod!, // 🔥 kirim ini
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),

      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF3D00)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Konfirmasi Pesanan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Pesanan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Metode: $orderMethod",
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            "Total Item: ${cart.fold(0, (s, e) => s + e.qty)}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ringkasan Pesanan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...cart.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${item.qty}x ${item.name}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    formatRp(item.price * item.qty),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(),

                          _row("Subtotal", formatRp(subtotal)),
                          _row("Pajak", formatRp(tax)),
                          _row(
                            "Total",
                            formatRp(total),
                            bold: true,
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                    ),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Metode Pembayaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),

                          paymentUI(
                            "QRIS",
                            "Scan QR pakai semua e-wallet",
                            Icons.qr_code,
                          ),
                          paymentUI(
                            "GoPay",
                            "Bayar cepat pakai GoPay",
                            Icons.payment,
                          ),
                          paymentUI(
                            "OVO",
                            "Transaksi instan pakai OVO",
                            Icons.account_balance_wallet,
                          ),
                          paymentUI(
                            "Tunai Di Kasir",
                           "Bayar dikasir setelah ambil pesanan",
                            Icons.payment
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= BOTTOM =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                formatRp(total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: paymentMethod != null ? handleConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Konfirmasi", style: TextStyle(fontSize: 15, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT =================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _row(String left, String right, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontSize: 15)),
          Text(
            right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentUI(String method, String subtitle, IconData icon) {
    final selected = paymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => paymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.deepOrange : Colors.grey.shade300,
            width: 2,
          ),
          color: selected ? Colors.orange.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.black),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Transform.scale(
              scale: 1.2,
              child: Radio(
                value: method,
                groupValue: paymentMethod,
                activeColor: Colors.deepOrange,
                onChanged: (val) =>
                    setState(() => paymentMethod = val.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
