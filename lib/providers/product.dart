import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus() async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      var response = await http.patch(
        'https://shop-app-e6f90.firebaseio.com/products/$id.json',
        body: json.encode(
          {
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
            'isFavorite': isFavorite,
          },
        ),
      );
      // http doesn't throw its own error when patching
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
        throw HttpException('Couldn\'t add favorite');
      }
    } catch (err) {
      isFavorite = oldStatus;
      notifyListeners();
      print(err);
    }
  }
}
