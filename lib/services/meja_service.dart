import 'package:projek/model/meja_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MejaService {
  final supabase = Supabase.instance.client;

  Future<List<MejaModel>> getMeja() async {
  try {
    final response = await supabase
        .from('meja')
        .select()
        .order('nomor_meja', ascending: true);

    return response
        .map<MejaModel>((json) => MejaModel.fromJson(json))
        .toList();
  } catch (e) {
    return [];
  } 
}

  Future<bool> pilihMeja(int nomorMeja) async {
    final existing = await supabase
        .from('meja')
        .select()
        .eq('nomor_meja', nomorMeja)
        .single();

    if (existing['status'] == 'dipakai') {
      return false;
    }

    await supabase
        .from('meja')
        .update({'status': 'dipakai'})
        .eq('nomor_meja', nomorMeja);

    return true;
  }
}