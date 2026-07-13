import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final supabase = Supabase.instance.client;

  Future<int> getTotalMenu() async {
    final response = await supabase
        .from('menus')
        .select()
        .count(CountOption.exact);

    return response.count;
  }

  Future<int> getTotalOrders() async {
    final res = await supabase.from('orders').select();
    return res.length;
  }

  Future<int> getActiveOrders() async {
    final res = await supabase.from('orders').select().eq('status', 'diproses');

    return res.length;
  }

  Future<int> getTotalRevenue() async {
    final data = await supabase.from('orders').select('total_price');

    int total = 0;
    for (var item in data) {
      total += (item['total_price'] as num).toInt();
    }
    return total;
  }

  Future<List> getLatestOrders() async {
    final res = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false)
        .limit(5);

    return res;
  }
}
