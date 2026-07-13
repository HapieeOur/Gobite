import 'package:flutter/material.dart';
import '../model/menu_model.dart';
import '../model/cart_model.dart';

class DetailPage extends StatefulWidget {
  final MenuModel menu;
  final CartModel cart;

  const DetailPage({super.key, required this.menu, required this.cart});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
  }

  int qty = 1;
  int extraPrice = 0;
  String? size;
  final TextEditingController note = TextEditingController();
  int get basePrice => int.parse(widget.menu.price.replaceAll('.', ''));
  int get total => (basePrice + extraPrice) * qty;
  Variant? selectedVariant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: Image.network(
                          widget.menu.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.orange[100],
                              child: Icon(Icons.fastfood, size: 80),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black26, Colors.transparent],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.menu.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(widget.menu.rating),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Text(
                        widget.menu.descr,
                        style: TextStyle(color: Colors.black54),
                      ),

                      SizedBox(height: 16),

                      Text(
                        "Rp ${widget.menu.price}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        "Variant",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: widget.menu.variants.asMap().entries.map((
                          entry,
                        ) {
                          final variant = entry.value;

                          final selected = selectedVariant == variant;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVariant = variant;
                                  extraPrice = variant.extraPrice;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.deepOrange
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  "${variant.name}${variant.extraPrice > 0 ? " (+Rp ${variant.extraPrice})" : ""}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selected
                                        ? Colors.deepOrange
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),

                      Text(
                        "Catatan Pesanan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 8),

                      TextField(
                        controller: note,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Contoh: Tidak pakai bawang",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        "Jumlah",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 10),

                      Row(
                        children: [
                          qtyButton(Icons.remove, () {
                            if (qty > 1) setState(() => qty--);
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              qty.toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          qtyButton(Icons.add, () {
                            setState(() => qty++);
                          }),
                        ],
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Rp $total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // tambahin item ke cart
                      widget.cart.addItem(
                        widget.menu.id,
                        widget.menu.name,
                        basePrice + extraPrice, // harga + tambahan variant
                        widget.menu.image,
                        selectedVariant!,
                      );

                      // langsung balik ke halaman sebelumnya
                      Navigator.pop(context);

                      // kasih feedback snack bar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${widget.menu.name} ditambahkan ke keranjang",
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    label: Text(
                      "Tambah ke Keranjang",
                      style: TextStyle(color: Colors.white),
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

  Widget sizeButton(String title, int price) {
    final selected = size == title;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            size = title;
            extraPrice = price;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.deepOrange : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Text(
            title == "Large" ? "Large (+Rp 10.000)" : title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.deepOrange : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepOrange),
      ),
    );
  }
}
