import 'package:flutter/material.dart';
import 'package:projek/pages/keranjang.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/menu_model.dart';
import '../model/cart_model.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  final String? orderType;
  final int? meja;
  final CartModel cart;

  const HomePage({super.key, this.orderType, this.meja, required this.cart});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;

  final supabase = Supabase.instance.client;

  List<MenuModel> menuList = [];
  List<MenuModel> popularList = [];

  bool isLoading = true;

  final List<String> categories = ["Semua", "Makanan", "Cemilan", "Minuman"];

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    try {
      final response = await supabase
          .from('menus')
          .select()
          .order('id', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);

      menuList = data.map((e) => MenuModel.fromJson(e)).toList();

      popularList = menuList.where((e) {
        final rating = double.tryParse(e.rating) ?? 0;
        return rating >= 4;
      }).toList();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH MENU: $e");
    }
  }

  List<MenuModel> get filteredMenu {
    if (selectedCategory == 0) return menuList;

    return menuList.where((e) {
      return e.category.toLowerCase().trim() ==
          categories[selectedCategory].toLowerCase().trim();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _topSection(),
                  const SizedBox(height: 18),
                  _categorySection(),
                ],
              ),
            ),

            if (selectedCategory == 0 && popularList.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text(
                    "Populer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _popularCard(popularList[index]),
                    childCount: popularList.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
                child: Text(
                  selectedCategory == 0
                      ? "Semua Menu"
                      : "Menu ${categories[selectedCategory]}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            filteredMenu.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          "Tidak ada menu",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _menuCard(filteredMenu[index]),
                      childCount: filteredMenu.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _topSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFFFF3D00)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),

      child: Column(
        children: [
          _headerRow(),
          const SizedBox(height: 16),
          _searchBox(),
          const SizedBox(height: 16),
          _promoCard(),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.orderType == "Makan di Tempat"
                  ? "Meja ${widget.meja ?? '-'}"
                  : widget.orderType ?? "GoBite",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 4),

            const Text(
              "GoBite",
              style: TextStyle(
                fontSize: 34,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        Stack(
          children: [
            CircleAvatar(
              radius: 24, // ukuran lingkaran
              backgroundColor: Colors.deepOrange, // warna lingkaran
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartPage(cart: widget.cart.items),
                    ),
                  );
                },
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white, // warna icon supaya kontras
                  size: 28,
                ),
              ),
            ),

            // update badge biar auto refresh
            AnimatedBuilder(
              animation: widget.cart,
              builder: (context, _) {
                if (widget.cart.totalItems == 0) return const SizedBox();
                return Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.cart.totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari menu favorit...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _promoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🎉 Promo Hari Ini", style: TextStyle(color: Colors.white)),

          SizedBox(height: 4),

          Text(
            "Diskon 20% All Menu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "Khusus untuk makan di tempat",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _categorySection() {
    return SizedBox(
      height: 45,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: categories.length,

        itemBuilder: (context, index) {
          final selected = selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
              });
            },

            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF7A00) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _popularCard(MenuModel item) {
    final rating = int.tryParse(item.rating) ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(menu: item, cart: widget.cart),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1, // 🔥 bikin kotak biar konsisten
                  child: Image.network(
                    item.image.isEmpty
                        ? "https://via.placeholder.com/150"
                        : item.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(
                rating,
                (index) =>
                    const Icon(Icons.star, color: Colors.orange, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(MenuModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(menu: item, cart: widget.cart),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),

        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),

              child: Image.network(
                item.image.isEmpty
                    ? "https://via.placeholder.com/150"
                    : item.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.descr,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("⭐ ${item.rating}"),

                      Text(
                        "Rp ${item.price}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
