import 'package:flutter/material.dart';
import '../model/menu_model.dart';
import '../services/menu_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final name = TextEditingController();
  final price = TextEditingController();
  final descr = TextEditingController();
  final List<TextEditingController> variantNameControllers = [];
  final List<TextEditingController> variantPriceControllers = [];
  String selectedCategory = "Makanan";


  final List<String> categories = ["Makanan", "Minuman", "Cemilan"];

  File? imageFile;
  String? imageUrl;
  bool loading = false;

  List<Variant> variantsList = []; // <---- VARIANTS

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = File(picked.path));
  }

  Future<void> saveMenu() async {
    if (name.text.isEmpty || price.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama & harga wajib diisi")));
      return;
    }

    setState(() => loading = true);

    try {
      if (imageFile != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await Supabase.instance.client.storage
            .from('menu')
            .upload(
              fileName,
              imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
        imageUrl = Supabase.instance.client.storage
            .from('menu')
            .getPublicUrl(fileName);
      }

      final menu = MenuModel(
        0,
        name.text,
        price.text,
        selectedCategory,
        "0",
        descr.text,
        imageUrl ?? "",
        variants: variantsList, // <--- kirim variant ke MenuModel
      );

      await MenuService().addMenu(menu);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Menu berhasil ditambahkan")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal tambah menu: $e")));
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
            _header('Tambahkan Menu'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(blurRadius: 20, color: Colors.grey.shade200),
                    ],
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
                      _variantsSection(), // <---- SECTION VARIANTS
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

  // ======= VARIANTS =======
  Widget _variantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER + BUTTON (+)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Variants",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // tombol +
            InkWell(
              onTap: () {
                setState(() {
                  variantsList.add(Variant(name: "", extraPrice: 0));
                  variantNameControllers.add(TextEditingController());
                  variantPriceControllers.add(TextEditingController());
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (variantsList.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xfff9fafb),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Belum ada variant, klik + buat nambah variant.",
              style: TextStyle(color: Colors.grey),
            ),
          ),

        const SizedBox(height: 10),

        ...List.generate(variantsList.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: variantNameControllers[index],
                    decoration: InputDecoration(
                      labelText: "Variant",
                      filled: true,
                      fillColor: const Color(0xfff9fafb),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      variantsList[index] = Variant(
                        name: val,
                        extraPrice: variantsList[index].extraPrice,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: variantPriceControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Harga",
                      prefixText: "+",
                      filled: true,
                      fillColor: const Color(0xfff9fafb),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      variantsList[index] = Variant(
                        name: variantsList[index].name,
                        extraPrice: int.tryParse(val) ?? 0,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        variantsList.removeAt(index);
                        variantNameControllers.removeAt(index);
                        variantPriceControllers.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xfff9fafb),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          underline: const SizedBox(),
          items: categories.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
            });
          },
        ),
      ),
    );
  }


  Widget _header(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffFF6A00), Color(0xffFF3D00)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.grey[200],
          image: imageFile != null
              ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
              : null,
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Pilih Gambar Menu",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : saveMenu,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5A00),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Simpan Menu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff9fafb),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
