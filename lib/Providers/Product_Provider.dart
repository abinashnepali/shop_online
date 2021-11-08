import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/Models/http_Exception.dart';

import 'Product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   ),
  ];

  final String tokenauth;
  final String userId;

  ProductProvider(this.tokenauth, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  Product findProductById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  List<Product> get FavoritesItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    // it check  the product by user. if it false it load all the product on the screen
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // final url = Uri.https('myshop-flutter-8958e-default-rtdb.firebaseio.com',
    //     '/products.json?auth=$tokenauth');
    Uri url = Uri.parse(
        'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/products.json?auth=$tokenauth&$filterString');
    try {
      print('The Urls is $url');
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || extractedData == {}) {
        return;
      }

      Uri ur = Uri.parse(
          'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/userFavorites/$userId/.json?auth=$tokenauth');
      final favoriteresponse = await http.get(ur);
      // print(favoriteresponse.body);

      final favExtractedData = json.decode(favoriteresponse.body);

      List<Product> loadProducts = [];
      // print('Isfav test ${favExtractedData['-Mfg_PthCMQCxW2CAp8D']}');

      extractedData.forEach((prodID, prodData) {
        // print('prodcut id saga test haii ${favExtractedData[prodID]}');
        var favStatus; //= false;
        final favboolval = favExtractedData[prodID].toString();
        if (favExtractedData == null) {
          favStatus = false;
        } else {
          if (favboolval != '') {
            favboolval == '{isFavorite: true}'
                ? favStatus = true
                : favStatus = false;
          } else {
            favStatus = false;
          }
        }
        print(favStatus);

        loadProducts.add(Product(
          id: prodID,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favStatus,
          // favExtractedData == null
          //     ? false
          //     : favExtractedData[prodID]['isFavorite']   ?? false,
        ));
      });
      _items = loadProducts;
      notifyListeners();

      //print(responseBody);
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> addProduct(Product prodinfo) async {
    // final url = Uri.https(
    //     'myshop-flutter-8958e-default-rtdb.firebaseio.com', '/products.jsonauth=$tokenauth');
    Uri url = Uri.parse(
        'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/products.json?auth=$tokenauth');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': prodinfo.title,
          'description': prodinfo.description,
          'imageUrl': prodinfo.imageUrl,
          'price': prodinfo.price,
          'isFavorite': prodinfo.isFavorite,
          'creatorId': userId,
        }),
      );
      // the next line is invisible wrapped on then on Aysn method
      var resid = jsonDecode(response.body)['name'];
      final newProduct = Product(
          id: resid,
          title: prodinfo.title,
          description: prodinfo.description,
          price: prodinfo.price,
          isFavorite: prodinfo.isFavorite,
          imageUrl: prodinfo.imageUrl);
      // in list  _items.insert(0, newProduct);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product prodinfo) async {
    final productindex = _items.indexWhere((prod) => prod.id == id);
    if (productindex >= 0) {
      try {
        // final url = Uri.https(
        //     'myshop-flutter-8958e-default-rtdb.firebaseio.com',
        //     '/products/$id.json');
        Uri url = Uri.parse(
            'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/products/$id.json?auth=$tokenauth');
        await http.patch(url,
            body: json.encode({
              'title': prodinfo.title,
              'description': prodinfo.description,
              'price': prodinfo.price,
              'imageUrl': prodinfo.imageUrl,
            }));
        _items[productindex] = prodinfo;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    // final url = Uri.https('myshop-flutter-8958e-default-rtdb.firebaseio.com',
    //     '/products/$id.json');
    Uri url = Uri.parse(
        'https://myshop-flutter-8958e-default-rtdb.firebaseio.com/products/$id.json?auth=$tokenauth');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HtppException('Cannot Deleted Product.');
    }
    existingProduct = null as Product;
  }
}
