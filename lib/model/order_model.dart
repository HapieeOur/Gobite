class Order {
  final String id;
  final String orderMethod;
  final String? tableNumber;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final String notes;
  final String paymentMethod;

  Order({
    required this.id,
    required this.orderMethod,
    this.tableNumber,
    required this.items,
    required this.total,
    required this.status,
    required this.notes,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_method': orderMethod,
        'table_number': tableNumber,
        'items': items,
        'total': total,
        'status': status,
        'notes': notes,
        'payment_method': paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
      };
}