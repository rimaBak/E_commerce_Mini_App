import 'package:flutter/material.dart';
import '../models/products.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final Map<int, int> _cartItems = {};
  List<Product> _products = [];

  Map<int, int> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0.0;
    _cartItems.forEach((id, quantity) {
      final product = getProductById(id);
      if (product != null) {
        total += product.price * quantity;
      }
    });
    return total;
  }

  void addToCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id] = _cartItems[product.id]! + 1;
    } else {
      _cartItems[product.id] = 1;
    }
    notifyListeners();
  }

  /// Increase quantity
  void increaseQuantity(int productId) {
    _cartItems[productId] = _cartItems[productId]! + 1;
    notifyListeners();
  }

  /// Decrease quantity
  void decreaseQuantity(int productId) {
    if (_cartItems[productId]! > 1) {
      _cartItems[productId] = _cartItems[productId]! - 1;
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  /// Remove completely
  void removeFromCart(int productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }
  void clearCart() {
    _cartItems.clear();
    // Notify all listeners that the cart is now empty
    notifyListeners();
  }
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }


  Future<void> fetchProducts() async {
    _products = await ApiService().fetchProducts(10, 0);
    notifyListeners();
  }
}