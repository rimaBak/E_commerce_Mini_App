import 'package:e_commerce_app_rima_bakshi/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/products.dart';

import '../provider/cart_provider.dart';
import '../provider/product_provider.dart';
import 'cart_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final productProvider = Provider.of<ProductProvider>(context);


    /// Filter products by title
    List<Product> filteredProducts = productProvider.products
        .where((product) => product.title
        .toLowerCase()
        .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              final itemCount = provider.cartItems.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$itemCount",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10),
                        ),
                      ),
                    )
                ],
              );
            },
          )
        ],
      ),

      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {

          /// Loader when first loading
          if (productProvider.products.isEmpty && productProvider.isFetching) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// Retry button when API fails or no data
          if (productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),

                  const SizedBox(height: 10),

                  const Text(
                    "Failed to load products",
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      productProvider.fetchProducts();
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          /// Filter products
          List<Product> filteredProducts = productProvider.products
              .where((product) => product.title
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
              .toList();

          return Column(
            children: [

              /// SEARCH FIELD
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search product...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),

              /// REFRESH + GRID
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await productProvider.refreshProducts();
                  },

                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {

                      /// Pagination Loader
                      if (!productProvider.isFetching &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        productProvider.fetchProducts();
                      }

                      return true;
                    },

                    child: GridView.builder(

                      padding: const EdgeInsets.all(10),

                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),

                      itemCount: filteredProducts.length +
                          (productProvider.isFetching ? 1 : 0),

                      itemBuilder: (context, index) {

                        /// Bottom Loader
                        if (index == filteredProducts.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        Product product = filteredProducts[index];

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailPage(product: product),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: Image.network(
                                      product.image,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  "\$${product.price}",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {

                                      Provider.of<CartProvider>(
                                          context,
                                          listen: false)
                                          .addToCart(product);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Added ${product.title} to cart!"),
                                        ),
                                      );
                                    },
                                    child: const Text("Add to Cart"),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
