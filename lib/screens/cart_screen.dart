import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {

    final cartProvider = Provider.of<CartProvider>(context);

    double subTotal = cartProvider.totalPrice;
    double tax = subTotal * 0.12;
    double grandTotal = subTotal + tax;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),

      /// CART ITEMS
      body: cartProvider.cartItems.isEmpty
          ? const Center(child: Text("Cart is Empty"))
          : ListView.builder(
        itemCount: cartProvider.cartItems.length,
        itemBuilder: (context, index) {

          final productId =
          cartProvider.cartItems.keys.elementAt(index);

          final quantity =
          cartProvider.cartItems[productId]!;

          final product =
          cartProvider.getProductById(productId);

          if (product == null) {
            return const SizedBox();
          }

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [

                  Image.network(product.image, width: 60),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text("\$${product.price}"),

                        Row(
                          children: [

                            /// decrease
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cartProvider
                                    .decreaseQuantity(productId);
                              },
                            ),

                            Text(quantity.toString()),

                            /// increase
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider
                                    .increaseQuantity(productId);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  Column(
                    children: [

                      Text(
                        "\$${product.price * quantity}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          cartProvider
                              .removeFromCart(productId);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),

      /// CHECKOUT SECTION

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// SUBTOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("\$${subTotal.toStringAsFixed(2)}"),
              ],
            ),

            const SizedBox(height: 5),

            /// TAX
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax (12%)"),
                Text("\$${tax.toStringAsFixed(2)}"),
              ],
            ),

            const Divider(),

            /// GRAND TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// CHECKOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  handleCheckout();
                },
                child: const Text("Checkout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================
  /// CHECKOUT LOGIC
  /// ==========================

  void handleCheckout() async {

    final cartProvider =
    Provider.of<CartProvider>(context, listen: false);

    /// 1️⃣ VALIDATION
    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart is empty! Please add items."),
        ),
      );
      return;
    }

    /// 2️⃣ SHOW LOADING OVERLAY
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
      const Center(child: CircularProgressIndicator()),
    );

    /// Mock payment delay
    await Future.delayed(const Duration(seconds: 2));

    /// CLOSE LOADER
    Navigator.pop(context);

    /// 3️⃣ CLEAR CART STATE
    cartProvider.clearCart();


    /// 4️⃣ SUCCESS DIALOG
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 60,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}


