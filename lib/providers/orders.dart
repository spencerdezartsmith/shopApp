import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    this.id,
    this.amount,
    this.products,
    this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://shop-app-e6f90.firebaseio.com/orders.json';
    final timestamp = DateTime.now();
    try {
      var response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'products': cartProducts
                .map(
                  (cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  },
                )
                .toList(),
            'dateTime': timestamp.toIso8601String(),
          },
        ),
      );
      // Add locally
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetOrders() async {
    print('fetch called');
    const url = 'https://shop-app-e6f90.firebaseio.com/orders.json';
    try {
      final response = await http.get(url);
      final extractedBody = json.decode(response.body) as Map<String, dynamic>;
      if (extractedBody == null) return;
      final List<OrderItem> loadedOrders = [];
      extractedBody.forEach(
        (orderId, orderData) {
          loadedOrders.add(
            OrderItem(
                id: orderId,
                amount: orderData['amount'],
                dateTime: DateTime.parse(orderData['dateTime']),
                products: (orderData['products'] as List<dynamic>)
                    .map(
                      (item) => CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['title'],
                      ),
                    )
                    .toList()),
          );
        },
      );
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {}
  }
}
