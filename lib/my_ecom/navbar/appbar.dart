import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_screen.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/homepage.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/notifications/notif_provider.dart';
import 'package:furniture_ecom_app/my_ecom/notifications/notification_screen.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/searchtab.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isPreview;

  const MyAppbar({super.key, required this.title, this.isPreview = false});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return PreferredSize(
      preferredSize: const Size.fromHeight(120.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 227, 211, 244),
              Colors.white,
              Color.fromARGB(255, 227, 211, 244),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: mythemecolor, size: 32),
          centerTitle: true,
          title: FutureBuilder<bool>(
            future: _isLoggedIn(),
            builder: (context, snapshot) {
              final loggedIn = snapshot.data ?? false;
              return isTablet
                  ? _buildTabletAppbar(context, loggedIn)
                  : _buildMobileAppbar(context, loggedIn);
            },
          ),
        ),
      ),
    );
  }

  // ✅ MOBILE VIEW
  Widget _buildMobileAppbar(BuildContext context, bool isLoggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: isPreview
                ? () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Myhome(isPreview: true),
                      ),
                      (route) => false,
                    );
                  }
                : () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomNavBar(),
                      ),
                      (route) => false,
                    );
                  },
            child: Image.asset(
              'assets/images/woodpecker_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNotificationBadge(context),
              const SizedBox(width: 20),
              _buildCartBadge(context, isLoggedIn),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, child) {
        Widget icon = _buildIconButton(
          icon: Icons.notifications_active_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        );
        if (isPreview) {
          return icon;
        }
        if (notifProvider.unreadCount > 0) {
          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: -5, end: -1),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Color.fromARGB(255, 63, 38, 84),
              padding: EdgeInsets.all(4),
            ),
            badgeContent: Text(
              "${notifProvider.unreadCount}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: icon,
          );
        }

        return icon;
      },
    );
  }

  Widget _buildTabletAppbar(BuildContext context, bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: isPreview
                ? () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Myhome(isPreview: true),
                      ),
                      (route) => false,
                    );
                  }
                : () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomNavBar(),
                      ),
                      (route) => false,
                    );
                  },
            child: Image.asset(
              'assets/images/woodpecker_logo.png',
              height: 90,
              fit: BoxFit.contain,
            ),
          ),

           Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SearchScreensTablet(isPreview: isPreview),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNotificationBadge(context),
                const SizedBox(width: 20),
                _buildCartBadge(context, isLoggedIn),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed, // <- make it nullable
  }) {
    return Container(
      decoration: BoxDecoration(
        color: mythemecolor1.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: mythemecolor, size: 23),
        onPressed: onPressed, // nullable is allowed
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context, bool isLoggedIn) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        Widget cartIcon = _buildIconButton(
          icon: Icons.shopping_cart_outlined,
          onPressed: isPreview
              ? null
              : () {
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
        );
        if (isPreview) {
          return cartIcon;
        }

        if (isLoggedIn && cartProvider.cartCount > 0) {
          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: -5, end: -1),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Color.fromARGB(255, 63, 38, 84),
              padding: EdgeInsets.all(4),
            ),
            badgeContent: Text(
              "${cartProvider.cartCount}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: cartIcon,
          );
        } else {
          return cartIcon;
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}
























