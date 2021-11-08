import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get cartItems {
    return {..._items};
  }

  int get carditemCount {
    return _items.length;
  }

  double get cardTotalAmount {
    double total = 0;
    _items.forEach((key, cartItem) {
      double price = cartItem.price * cartItem.quantity;
      total = total + price;
    });
    return total;
  }

  void addItemsOnCard(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: existingCartItem.quantity + 1,
              price: existingCartItem.price));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  void removeCartItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    } else if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingitmes) => CartItem(
              id: productId,
              title: existingitmes.title,
              quantity: existingitmes.quantity - 1,
              price: existingitmes.price));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearallCart() {
    _items = {};
    notifyListeners();
  }
}
