import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class OrderService {
  static Future<String> createOrder({
    required String orderMethod,
    String? tableNumber,
    required List<Map<String, dynamic>> items,
    required double total,
    required String notes,
    required String paymentMethod,
  }) async {

    // 🔥 1. INSERT KE TABLE ORDERS
    final orderRes = await supabase
        .from('orders')
        .insert({
          'total_items': items.fold(
              0, (sum, e) => sum + (e['quantity'] as int)),
          'total_price': total.toInt(),
          'status': 'diproses',
          'notes': notes,
          'payment_method': paymentMethod,
        })
        .select()
        .single();

    final orderId = orderRes['id']; // bigint
    final orderCode = orderRes['order_code']; // dari trigger

    // 🔥 2. INSERT KE ORDER_ITEMS
    final orderItems = items.map((item) => {
  'order_id': orderId,
  'menu_id': item['id'], // 🔥 BUKAN menu_id
  'name': item['name'],
  'price': item['price'],
  'quantity': item['quantity'],
}).toList();

    await supabase.from('order_items').insert(orderItems);

    // 🔥 RETURN CODE BUAT UI
    return orderCode ?? orderId.toString();
  }
}