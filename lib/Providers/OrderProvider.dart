import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/Models/http_Exception.dart';
import 'dart:convert';

import 'package:my_shop/Providers/CartProvider.dart';

class OrderModel {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderModel(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class OrderProvider with ChangeNotifier {
  final String authtoken;
  final String userId;
  OrderProvider(this.authtoken, this._orderList, this.userId);

  List<OrderModel> _orderList = [];

  List<OrderModel> get getOrderItems {
    return [..._orderList];
  }

  Future<void> fetchAndSetOrders() async {
    // final url = Uri.https(
    //     'myshop-flutter-8958e-default-rtdb.firebaseio.com', '/Orders.json');
    Uri url = Uri.parse(
        'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authtoken');
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        throw HtppException("No OrderItems");
      }

      List<OrderModel> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderModel(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']))
                .toList(),
          ),
        );
      });
      _orderList = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrderItems(List<CartItem> cartProducts, double total) async {
    Uri url = Uri.parse(
        'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authtoken');
    // final url = Uri.https(
    //     'myshop-flutter-8958e-default-rtdb.firebaseio.com', '/Orders.json');
    final timeStamp = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          }));
      // it will add at the begining of the list
      _orderList.insert(
          0,
          OrderModel(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: timeStamp));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
