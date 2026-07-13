// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:projek/admin/addmenu.dart';
import 'package:projek/admin/editmenu.dart';
import 'package:projek/services/menu_service.dart';
import 'package:projek/model/menu_model.dart';

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage>
    with SingleTickerProviderStateMixin {
  final service = MenuService();

  List<MenuModel> menuList = [];
  List<MenuModel> filteredList = [];

  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    setState(() => isLoading = true);

    try {
      final data = await service.getMenus();

      if (!mounted) return;

      setState(() {
        menuList = data;
        filteredList = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal load menu: $e")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void filterMenu(String query) {
    final results = menuList.where((menu) {
      final name = menu.name.toLowerCase();
      final category = menu.category.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input) || category.contains(input);
    }).toList();

    setState(() {
      filteredList = results;
    });
  }

  Future<void> deleteMenu(int id) async {
    await service.deleteMenu(id);

    if (!mounted) return;

    setState(() {
      menuList.removeWhere((e) => e.id == id);
      filteredList.removeWhere((e) => e.id == id);
    });

    ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Menu dihapus")));

      loadMenu();
  }

  Future<void> confirmDelete(MenuModel menu) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Hapus Menu?"),
        content: Text("Yakin mau hapus ${menu.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      );
    },
  );

  if (result == true) {
    await deleteMenu(menu.id);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _totalMenuCard(),
                  const SizedBox(height: 15),
                  Expanded(child: _menuList()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 25),
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
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "Kelola Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterMenu,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Cari menu...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddMenuPage()),
                  );
                  if (result == true) {
                    loadMenu();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.orange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= TOTAL CARD =================
  Widget _totalMenuCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          const Text(
            "Total Menu: ",
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "${filteredList.length}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          )
        ],
      ),
    );
  }

  // ================= LIST =================
  Widget _menuList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          "Menu tidak ditemukan",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final menu = filteredList[index];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Dismissible(
            key: Key(menu.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.delete,
                  color: Colors.white),
            ),
            confirmDismiss: (_) async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Hapus Menu?"),
                    content: Text("Yakin mau hapus ${menu.name}?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Batal"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Hapus"),
                      ),
                    ],
                  );
                },
              );

              if (result == true) {
                await deleteMenu(menu.id);
                return true;
              }

              return false;
            },
            child: _menuItem(menu),
          ),
        );
      },
    );
  }

  // ================= ITEM CARD =================
  Widget _menuItem(MenuModel menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: menu.image.isNotEmpty && menu.image.startsWith("http")
                ? Image.network(
                    menu.image,
                    height: 85,
                    width: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 85,
                        width: 85,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  )
                : Container(
                    height: 85,
                    width: 85,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  menu.category,
                  style:
                      const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Rp ${menu.price}",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _circleButton(
                icon: Icons.edit,
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            EditMenuPage(menu: menu)),
                  );
                  if (result == true) loadMenu();
                },
              ),
              const SizedBox(height: 8),
              _circleButton(
                icon: Icons.delete,
                color: Colors.red,
                onTap: () => confirmDelete(menu),
              ),
            ],
          ) 
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}