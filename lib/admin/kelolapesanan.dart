import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaPesananPage extends StatefulWidget {
  const KelolaPesananPage({super.key});

  @override
  State<KelolaPesananPage> createState() => _KelolaPesananPageState();
}

class _KelolaPesananPageState extends State<KelolaPesananPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String selectedStatus = "Semua";

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  Future<void> updateStatus(String orderCode) async {
    try {
      await supabase
          .from('orders')
          .update({'status': 'selesai'})
          .eq('order_code', orderCode);

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffFF6A00), Color(0xffFF3D00)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                // 🔙 BACK + TITLE
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Kelola Pesanan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 🔍 SEARCH
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.search),
                            hintText: "Cari nomor pesanan...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // 🔥 FILTER tetap versi lama
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    filterBtn("Semua"),
                    filterBtn("diproses"),
                    filterBtn("selesai"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 LIST ORDER REALTIME
          Expanded(
            child: StreamBuilder(
              stream: supabase
                  .from('orders')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List data = snapshot.data!;

                // 🔍 SEARCH FILTER
                if (searchQuery.isNotEmpty) {
                  data = data.where((e) {
                    final code = (e['order_code'] ?? "")
                        .toString()
                        .toLowerCase();
                    return code.contains(searchQuery);
                  }).toList();
                }

                // 🔥 FILTER STATUS
                if (selectedStatus != "Semua") {
                  data = data
                      .where((e) => e['status'] == selectedStatus)
                      .toList();
                }

                if (data.isEmpty) {
                  return buildEmpty();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final order = data[index];

                    return buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filterBtn(String title) {
    bool active = selectedStatus == title;

    return GestureDetector(
      onTap: () {
        setState(() => selectedStatus = title);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
        ), // spacing antar button
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ), // lebih besar
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.orange.shade200,
          borderRadius: BorderRadius.circular(30), // lebih bulat
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.orange : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16, // lebih besar
          ),
        ),
      ),
    );
  }

  Widget buildOrderCard(Map order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['order_code'] ?? "No Code",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              statusBadge(order['status']),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            order['created_at'] ?? "",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            order['payment_method'] ?? "",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 10),
          // LIST ITEM
          if (order['items'] != null)
            ...List<Widget>.from(
              order['items'].map<Widget>((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item['quantity']}x ${item['name']}"),
                    Text("Rp ${item['price'].toStringAsFixed(0)}"),
                  ],
                );
              }),
            ),
          const SizedBox(height: 10),
          // TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Rp ${order['total_price']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // BUTTON SELESAI / PESANAN SIAP
          if (order['status'] != 'selesai')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => updateStatus(order['order_code']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Pesanan Siap"),
              ),
            ),
        ],
      ),
    );
  }

  // 🔥 BADGE STATUS PILLS
  Widget statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "diproses":
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case "selesai":
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == "selesai" ? "Siap" : status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // 🔥 EMPTY STATE
  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Tidak ada pesanan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text("Belum ada pesanan masuk"),
        ],
      ),
    );
  }
}
