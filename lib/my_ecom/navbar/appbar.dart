import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/settings_service.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_screen.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/notification_screen.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/searchtab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyAppbar({super.key, required this.title});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      iconTheme: IconThemeData(color: mythemecolor, size: 30),
      backgroundColor: Colors.white,
      title: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          final loggedIn = snapshot.data ?? false;

          return screenWidth < 600
              ? _buildMobileTitle(context, loggedIn)
              : _buildTabletTitle(context, screenWidth, loggedIn);
        },
      ),
    );
  }

  Widget _buildMobileTitle(BuildContext context, bool isLoggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder<ShopSettings?>(
          future: SettingsService.fetchShopSettings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BottomNavBar(),
                    ),
                    (route) => false,
                  );
                },
                // child: CircleAvatar(
                //   radius: 23,
                //   backgroundColor: Colors.transparent,
                  // child: Image.asset(
                  //   'assets/images/kai.png',
                  //   height: 90,
                  //   width: 90,
                  // ),
                 child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/kai.png'),
                radius: 23,
                backgroundColor: Colors.transparent,
                onBackgroundImageError: (_, __) {},
              ),
                
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.profileImage.isEmpty) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BottomNavBar(),
                    ),
                    (route) => false,
                  );
                },
                child: Image.asset(
                  'assets/images/kai.png',
                  height: 90,
                  width: 90,
                ),
              );
            }

            final settings = snapshot.data!;
            return GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const BottomNavBar()),
                  (route) => false,
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(settings.profileImage),
                radius: 20,
                backgroundColor: Colors.white,
                onBackgroundImageError: (_, __) {},
              ),
            );
          },
        ),

        const Spacer(),

        Text(
          title,
          style: GoogleFonts.arvo(
            fontStyle: FontStyle.normal,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:  mythemecolor,
          ),
        ),

        const Spacer(),

        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.notifications_active,
            color: mythemecolor,
            size: 25,
          ),
        ),

        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            Widget cartIcon = IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ).then((_) {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).fetchCartCount();
                });
              },
              icon: Icon(
                Icons.shopping_cart,
                color: mythemecolor,
                size: 27,
              ),  
              //  Image.asset(
              //   'assets/images/cartt.png',
              //   fit: BoxFit.contain,
              //   height: 25,
              //   width: 20,
              // ),
            );

            if (isLoggedIn && cartProvider.cartCount >= 0) {
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: -5, end: -1),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red,
                  padding: EdgeInsets.all(5),
                ),
                badgeContent: Text(
                  "${cartProvider.cartCount}",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: cartIcon,
              );
            } else {
              return cartIcon;
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildTabletTitle(
    BuildContext context,
    double screenWidth,
    bool isLoggedIn,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            FutureBuilder<ShopSettings?>(
              future: SettingsService.fetchShopSettings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavBar(),
                        ),
                        (route) => false,
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        'assets/images/kai.png',
                        height: 90,
                        width: 90,
                      ),
                    ),
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.profileImage.isEmpty) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavBar(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Image.asset(
                      'assets/images/kai.png',
                      height: 90,
                      width: 90,
                    ),
                  );
                }

                final settings = snapshot.data!;
                return GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomNavBar(),
                      ),
                      (route) => false,
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(settings.profileImage),
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    onBackgroundImageError: (_, __) {
                    },
                  ),
                );
              },
            ),

            const SizedBox(width: 20),

            // ✅ Title
            Text(
              title,
              style: GoogleFonts.arvo(
                fontStyle: FontStyle.normal,
                fontSize:30 ,
                color:  mythemecolor,
              ),
            ),
          ],
        ),

        // ✅ Search bar
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 800,
            child: const SearchScreensTablet(),
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.notifications_active,
            color: mythemecolor,
            size: 30,
          ),
        ),

        // ✅ Cart with badge
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            Widget cartIcon = IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ).then((_) {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).fetchCartCount();
                });
              },
              icon: Image.asset(
                'assets/images/cartt.png',
                fit: BoxFit.contain,
                height: 30,
                width: 30,
              ),
            );

            if (isLoggedIn && cartProvider.cartCount > 0) {
              return badges.Badge(
                badgeContent: Text(
                  "${cartProvider.cartCount}",
                  style: const TextStyle(color: Colors.white),
                ),
                child: cartIcon,
              );
            } else {
              return cartIcon;
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90.0);
}
