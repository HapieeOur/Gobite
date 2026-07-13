import 'package:flutter/material.dart';
import '../model/menu_model.dart';
import '../services/menu_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditMenuPage extends StatefulWidget {
  final MenuModel menu;
  const EditMenuPage({super.key, required this.menu});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final name = TextEditingController();
  final price = TextEditingController();
  final category = TextEditingController();
  final descr = TextEditingController();

  String selectedCategory = "Makanan";

  final List<String> categories = ["Makanan", "Minuman", "Cemilan"];

  File? imageFile;
  String? imageUrl;
  bool loading = false;

  // Variants langsung di menu
  List<Variant> variantsList = [];

  @override
  void initState() {
    super.initState();
    name.text = widget.menu.name;
    price.text = widget.menu.price;
    category.text = widget.menu.category;
    descr.text = widget.menu.descr;
    imageUrl = widget.menu.image;

    if (categories.contains(category.text)) selectedCategory = category.text;

    // INIT VARIANTS
    variantsList = List.from(widget.menu.variants);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = File(picked.path));
  }

  void addVariant() {
  setState(() => variantsList.add(
        Variant(name: "", extraPrice: 0),
      ));
}

  void removeVariant(int index) {
    setState(() => variantsList.removeAt(index));
  }

  Future<void> updateMenu() async {
    if (name.text.isEmpty || price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama & harga wajib diisi")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      if (imageFile != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final filePath = fileName;

        await Supabase.instance.client.storage
            .from('menu')
            .upload(filePath, imageFile!,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

        imageUrl = Supabase.instance.client.storage
            .from('menu')
            .getPublicUrl(filePath);
      }

      final updatedMenu = MenuModel(
        widget.menu.id,
        name.text,
        price.text,
        selectedCategory,
        widget.menu.rating,
        descr.text,
        imageUrl ?? widget.menu.image,
        variants: variantsList, // langsung masuk sini
      );

      await MenuService().updateMenu(updatedMenu);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Menu berhasil diupdate")));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal update menu: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: SafeArea(
        child: Column(
          children: [
            _header('Edit Menu'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(blurRadius: 20, color: Colors.grey.shade200)],
                  ),
                  child: Column(
                    children: [
                      _imagePicker(),
                      const SizedBox(height: 20),
                      _input("Nama Menu", name),
                      _input("Harga", price),
                      _categoryDropdown(),
                      _input("Deskripsi", descr, maxLines: 3),
                      const SizedBox(height: 20),
                      _variantsSection(),
                      const SizedBox(height: 25),
                      _saveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _variantsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Variants",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
              onPressed: addVariant,
              icon: const Icon(Icons.add_circle, color: Colors.orange)),
        ],
      ),
      ...List.generate(variantsList.length, (index) {
        final v = variantsList[index];

        return Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                decoration:
                    const InputDecoration(hintText: "Nama variant"),
                controller: TextEditingController(text: v.name),
                onChanged: (val) {
                  variantsList[index] = Variant(
                    name: val,
                    extraPrice: v.extraPrice,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                decoration:
                    const InputDecoration(hintText: "Harga tambahan"),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: v.extraPrice.toString()),
                onChanged: (val) {
                  variantsList[index] = Variant(
                    name: v.name,
                    extraPrice: int.tryParse(val) ?? 0,
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => removeVariant(index),
            ),
          ],
        );
      }),
    ],
  );
}

  Widget _header(String title) => Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xffFF6A00), Color(0xffFF3D00)]),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context, true)),
            ),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _imagePicker() => GestureDetector(
        onTap: pickImage,
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.grey[200],
            image: imageFile != null
                ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                : imageUrl != null
                    ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                    : null,
          ),
          child: imageFile == null && (imageUrl == null || imageUrl!.isEmpty)
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text("Pilih Gambar Menu", style: TextStyle(color: Colors.grey)),
                ])
              : null,
        ),
      );

  Widget _categoryDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xfff9fafb), borderRadius: BorderRadius.circular(16)),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            items: categories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (val) => setState(() => selectedCategory = val!),
          ),
        ),
      );

  

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : updateMenu,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A00),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Update Menu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );

  Widget _input(String label, TextEditingController controller, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xfff9fafb),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      );
}