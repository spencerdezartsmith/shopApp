import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favortieItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> addProduct(Product product) async {
    const url = 'https://shop-app-e6f90.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite
          },
        ),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://shop-app-e6f90.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      final extractedBody = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedBody.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
                id: prodId,
                description: prodData['description'],
                price: prodData['price'],
                title: prodData['title'],
                imageUrl: prodData['imageUrl']),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  void updateProduct(String id, Product newProduct) {
    final prodIdx = _items.indexWhere((element) => element.id == id);
    if (prodIdx >= 0) {
      _items[prodIdx] = newProduct;
      notifyListeners();
    } else {
      print('Whoops something went wrong');
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  void deleteProduct(String id) {
    _items.removeWhere((element) => id == element.id);
    notifyListeners();
  }
}
