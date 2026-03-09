import 'package:flutter/material.dart';
import '../models/products.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {

  final List<Product> _products = [];
  bool _isFetching = false;

  List<Product> get products => _products;
  bool get isFetching => _isFetching;

  /// CART STORAGE
  final Map<int, int> _cart = {};
  Map<int, int> get cart => _cart;

  /// ADD TO CART
  void addToCart(Product product) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id] = _cart[product.id]! + 1;
    } else {
      _cart[product.id] = 1;
    }
    notifyListeners();
  }

  /// TOTAL CART ITEMS
  int get totalCartItems {
    return _cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  /// FETCH PRODUCTS (Pagination)
  Future<void> fetchProducts() async {

    if (_isFetching) return;

    _isFetching = true;
    notifyListeners();

    try {

      List<Product> newProducts =
      await ApiService().fetchProducts(10, _products.length);

      _products.addAll(newProducts);

    } catch (e) {
      debugPrint("Product fetch error: $e");
    }

    _isFetching = false;
    notifyListeners();
  }

  /// SEARCH PRODUCTS
  Future<List<Product>> searchProducts(String query) async {
    return await ApiService().searchProducts(query);
  }

  /// REFRESH PRODUCTS (Pull to Refresh)
  Future<void> refreshProducts() async {

    _products.clear();

    notifyListeners();

    await fetchProducts();
  }
}