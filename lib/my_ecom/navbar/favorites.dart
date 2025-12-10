import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/cart_service.dart';
import 'package:furniture_ecom_app/core/services/wishlist_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/drawer.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/new_appbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';

import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  WishlistService wapiService = WishlistService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WishlistManager>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: NewAppbar(title: 'My Favorites'),
      ),
      drawer: const CustomDrawer(),

      body: SizedBox.expand(
        child: Stack(
          children: [
            // Positioned.fill(
            //   child: Image.asset(
            //     isTablet
            //         ? 'assets/images/theme.png'
            //         : 'assets/images/theme.png',
            //     fit: BoxFit.cover,
            //   ),
            // ),

            isTablet ? const MyTabView() : const MyMobileView(),
          ],
        ),
      ),
    );
  }
}

class MyMobileView extends StatelessWidget {
  const MyMobileView({super.key});

  Future<void> addToCartItem(Product product, BuildContext context) async {
    try {
      final response = await CartService.addToCart(product, context);
      await Provider.of<CartProvider>(context, listen: false).fetchCartCount();
      if (response.containsKey('error')) {
       
        showTopSnackBar(context, response['error']);
      } else {
       

        showTopSnackBar(context, "Product Added to Cart!!");
      }
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("An unexpected error occurred"),
      //   ),
      // );
      showTopSnackBar(context, "An unexpected error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistManager>(
      builder: (context, wishlistManager, child) {
        return RefreshIndicator(
          color: mythemecolor,
          backgroundColor: const Color.fromARGB(255, 245, 240, 242),
          displacement: 40,
          strokeWidth: 2.5,
          onRefresh: () async {
            await wishlistManager.initialize();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: WishlistService.getWishlistItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AnimationPage1());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final wishlistItems = snapshot.data ?? [];

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // no items in wishlist
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: mythemecolor1.withOpacity(0.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/fav.png',
                              width: 150,
                              height: 150,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "No items in wishlist!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Please do shop & add your favorites !",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/myhome',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mythemecolor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Go To Shop"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index];

                  final productId = product['_id'] ?? '';
                  if (productId.isEmpty) {
                    return const Center(child: Text('Invalid Product Data'));
                  }

                  final productObj = Product(
                    id: product['_id'] ?? '',
                    title: product['title'] ?? '',
                    price: (product['price'] ?? 0).toDouble(),
                    offerPrice: (product['offerPrice'] ?? 0).toDouble(),
                    description: product['description'] ?? '',
                    images: List<String>.from(product['images'] ?? []),
                    gstPercentage: (product['gstPercentage'] ?? 0).toDouble(),
                    stock: product['stock'] != null
                        ? product['stock'] as int
                        : 0,
                    measurement: product['measurement'] ?? '',
                    size: product['size'] ?? '',
                    weight: product['weight'] ?? '',
                  );

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPagep(product: productObj),
                      ),
                    ),
                    child: Card(
                      color: const Color.fromARGB(255, 247, 251, 248),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                productObj.images.isNotEmpty
                                    ? productObj.images[0]
                                    : 'https://yourbackupimage.com/placeholder.png',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 130,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/fav.png',
                                    width: 80,
                                    height: 80,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productObj.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: mythemecolor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${productObj.offerPrice.round()}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            28,
                                            116,
                                            31,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹${productObj.price.round()}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (productObj.price >
                                          productObj.offerPrice)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade600,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${(((productObj.price - productObj.offerPrice) / productObj.price) * 100).round()}% OFF',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: mythemecolor,
                                            width: 1.5, // Border width
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(0),
                                        child: IconButton(
                                          icon:
                                              wishlistManager.isInWishlist(
                                                productId,
                                              )
                                              ? const Icon(
                                                  Icons.favorite,
                                                  size: 20,
                                                  color: Colors.red,
                                                )
                                              : const Icon(
                                                  Icons.favorite_border,
                                                  size: 20,
                                                ),
                                          onPressed: () {
                                            wishlistManager.toggleWishlist(
                                              productId,
                                              context,
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: mythemecolor,
                                            width: 1.5, // Border width
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.shopping_cart_outlined,
                                            color: productObj.stock > 0
                                                ? mythemecolor
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          onPressed: productObj.stock > 0
                                              ? () {
                                                  addToCartItem(
                                                    productObj,
                                                    context,
                                                  );
                                                }
                                              : null,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: productObj.stock > 0
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderConfirmationPage(
                                                          product: productObj,
                                                        ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mythemecolor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "BUY NOW",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class MyTabView extends StatelessWidget {
  const MyTabView({super.key});

  Future<void> addToCartItem(Product product, BuildContext context) async {
    try {
      final response = await CartService.addToCart(product, context);
      await Provider.of<CartProvider>(context, listen: false).fetchCartCount();
      if (response.containsKey('error')) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(response['error']),
        //   ),
        // );
        showTopSnackBar(context, response['error']);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("Product Added to Cart!"),
        //   ),
        // );
        showTopSnackBar(context, "Product Added to Cart!!");
      }
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("An unexpected error occurred"),
      //   ),
      // );
      showTopSnackBar(context, "An unexpected error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistManager>(
      builder: (context, wishlistManager, child) {
        return RefreshIndicator(
          color: mythemecolor,
          backgroundColor: const Color.fromARGB(255, 245, 240, 242),
          displacement: 40,
          strokeWidth: 2.5,
          onRefresh: () async {
            await wishlistManager.initialize();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: WishlistService.getWishlistItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AnimationPage1());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final wishlistItems = snapshot.data ?? [];
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 228, 215, 226),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/fav.png',
                              width: 150,
                              height: 150,
                            ),
                            Text(
                              "Add your favos!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Please do shop & add your favorites !",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/myhome',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mythemecolor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 14,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Go To Shop"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Two items per row
                    childAspectRatio: 0.85, // Adjust height for better fit
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final product = wishlistItems[index];
                    final productId = product['_id'] ?? '';
                    if (productId.isEmpty) {
                      return const Center(child: Text('Invalid Product Data'));
                    }

                    final productObj = Product(
                      id: product['_id'] ?? '',
                      title: product['title'] ?? '',
                      price: (product['price'] ?? 0).toDouble(),
                      offerPrice: (product['offerPrice'] ?? 0).toDouble(),
                      description: product['description'] ?? '',
                      images: List<String>.from(product['images'] ?? []),
                      stock: product['stock'] != null
                          ? product['stock'] as int
                          : 0,
                      gstPercentage: (product['gstPercentage'] ?? 0).toDouble(),
                      measurement: product['measurement'] ?? '',
                      size: product['size'] ?? '',
                      weight: product['weight'] ?? '',
                    );

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPagep(product: productObj),
                        ),
                      ),
                      child: Card(
                        color: const Color.fromARGB(255, 228, 215, 226),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    productObj.images.isNotEmpty
                                        ? productObj.images[0]
                                        : 'https://yourbackupimage.com/placeholder.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 160,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/placeholder.png',
                                        width: double.infinity,
                                        height: 160,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                productObj.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '₹${productObj.offerPrice.round()}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${productObj.price.round()}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (productObj.price > productObj.offerPrice)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${(((productObj.price - productObj.offerPrice) / productObj.price) * 100).round()}% OFF',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: mythemecolor,
                                        width: 3, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    padding: const EdgeInsets.all(1),
                                    child: IconButton(
                                      icon:
                                          wishlistManager.isInWishlist(
                                            productId,
                                          )
                                          ? const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            )
                                          : const Icon(Icons.favorite_border),
                                      onPressed: () {
                                        wishlistManager.toggleWishlist(
                                          productId,
                                          context,
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: mythemecolor,
                                        width: 3, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    padding: const EdgeInsets.all(1),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.shopping_cart_outlined,
                                        color: productObj.stock > 0
                                            ? mythemecolor
                                            : Colors.grey,
                                        size: 26,
                                      ),
                                      onPressed: productObj.stock > 0
                                          ? () {
                                              addToCartItem(
                                                productObj,
                                                context,
                                              );
                                            }
                                          : null,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: productObj.stock > 0
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderConfirmationPage(
                                                      product: productObj,
                                                    ),
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: mythemecolor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      productObj.stock > 0
                                          ? "BUY NOW"
                                          : "OUT OF STOCK",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
