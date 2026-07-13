import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/menu_model.dart';

class MenuService {
  final supabase = Supabase.instance.client;

  // Ambil semua menu
  Future<List<MenuModel>> getMenus() async {
    try {
      final data = await supabase
          .from('menus')
          .select()
          .order('id', ascending: true);

      if (data.isEmpty) return [];

      return List<Map<String, dynamic>>.from(data).map((e) {
        return MenuModel.fromJson(e);
      }).toList();
    } catch (e) {
      debugPrint("ERROR GET MENU: $e");
      return [];
    }
  }

  // Tambah menu baru
  Future<void> addMenu(MenuModel menu, {File? imageFile}) async {
    try {
      String imageUrl = menu.image;

      if (imageFile != null) {
        final ext = imageFile.path.split('.').last; // png, jpg, gif, dll
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";
        final filePath = "menu/$fileName";

        await supabase.storage
            .from('menu')
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(upsert: true),
            );

        imageUrl = supabase.storage.from('menu').getPublicUrl(filePath);
      }

      await supabase.from('menus').insert({
        'name': menu.name,
        'price': menu.price,
        'category': menu.category,
        'rating': menu.rating,
        'descr': menu.descr,
        'image': imageUrl,
        'variants': menu.variants.map((v) => v.toJson()).toList(),
      });
    } catch (e) {
      debugPrint("ERROR ADD MENU: $e");
    }
  }

  // Update menu
  Future<void> updateMenu(MenuModel menu, {File? imageFile}) async {
    try {
      String imageUrl = menu.image;

      if (imageFile != null) {
        final ext = imageFile.path.split('.').last;
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";
        final filePath = "menu/$fileName";

        await supabase.storage
            .from('menu')
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(upsert: true),
            );

        imageUrl = supabase.storage.from('me  nu').getPublicUrl(filePath);
      }

      await supabase
          .from('menus')
          .update({
            'name': menu.name,
            'price': menu.price,
            'category': menu.category,
            'rating': menu.rating,
            'descr': menu.descr,
            'image': imageUrl,
            'variants': menu.variants.map((v) => v.toJson()).toList(),
          })
          .eq('id', menu.id);
    } catch (e) {
      debugPrint("ERROR UPDATE MENU: $e");
    }
  }

  // Hapus menu
  Future<void> deleteMenu(int id) async {
    try {
      await supabase.from('menus').delete().eq('id', id);
    } catch (e) {
      debugPrint("ERROR DELETE MENU: $e");
    }
  }
}
