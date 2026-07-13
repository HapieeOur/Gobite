import 'package:flutter/material.dart';
import 'package:projek/model/menu_model.dart';

class CartItem {
  final int id;
  final String name;
  final int price;
  final String image;
  final Variant variant;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.variant,
    this.qty = 1,
  });
}

class CartModel extends ChangeNotifier {
  final List<CartItem> items = [];

  void addItem(
    int id,
    String name,
    int price,
    String image,
    Variant selectedVariant,
  ) {

    final index = items.indexWhere(
      (item) =>
          item.id == id &&
          item.variant.name == selectedVariant.name,
    );

    if (index != -1) {
      items[index].qty++;
    } else {
      items.add(
        CartItem(
          id: id,
          name: name,
          price: price + selectedVariant.extraPrice,
          image: image,
          variant: selectedVariant,
        ),
      );
    }

    notifyListeners();
  }

  void increaseQty(int index) {
    items[index].qty++;
    notifyListeners();
  }

  void decreaseQty(int index) {
    if (items[index].qty > 1) {
      items[index].qty--;
    } else {
      items.removeAt(index);
    }

    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  int get subtotal {
    int total = 0;

    for (var item in items) {
      total += item.price * item.qty;
    }

    return total;
  }

  int get tax => (subtotal * 0.1).round();

  int get total => subtotal + tax;

  int get totalItems {
    int total = 0;

    for (var item in items) {
      total += item.qty;
    }

    return total;
  }
}