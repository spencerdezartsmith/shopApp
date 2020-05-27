import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

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

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = 'https://shop-app-e6f90.firebaseio.com/products/$id.json';
    final prodIdx = _items.indexWhere((element) => element.id == id);
    if (prodIdx >= 0) {
      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            },
          ),
        );
        _items[prodIdx] = newProduct;
        notifyListeners();
      } catch (error) {
        print(error);
      }
    } else {
      print('Whoops something went wrong');
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> deleteProduct(String id) async {
    // optimisting updating
    final url = 'https://shop-app-e6f90.firebaseio.com/products/$id.json';
    final existingProdIdx = _items.indexWhere((element) => element.id == id);
    var existingProd = _items[existingProdIdx];
    _items.removeWhere((element) => id == element.id);
    notifyListeners();
    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProdIdx, existingProd);
      notifyListeners();
      throw HttpException('Couldn\'t delete product');
    }
    existingProd = null;
  }
}
