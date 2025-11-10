import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/user_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/edit_user_profile.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/login_provider.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/favorites.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/notification_screen.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_list.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  String? userId;

  String? userName = '';
  String? userEmail = '';
  String? userPhone = '';
  String? userAddress = '';

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('user_email');
    print(prefs);
    setState(() {
      userEmail = email ?? 'Error: Email not found, please log in again.';
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      if (!_isDisposed) {
        setState(() {
          _isLoggedIn = true;
        });
      }
      await _fetchUserProfile(token);
      if (!_isDisposed) {
        await Provider.of<CartProvider>(
          context,
          listen: false,
        ).fetchCartCount();
      }
    } else {
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      }
    }
  }

  Future<void> _fetchUserProfile(String token) async {
    try {
      final userProfile = await UserService.getUserProfile();

      if (userProfile != null && userProfile['username'] != null) {
        if (!_isDisposed) {
          setState(() {
            userName = userProfile['username'] ?? 'User';
            userEmail = userProfile['email'] ?? '';
            userPhone = userProfile['phoneNo'] ?? '';
            userAddress = userProfile['address'] ?? '';
          });
        }
      } else {
        await _handleUserNotFound();
      }
    } catch (error) {
      if (!_isDisposed) {
        if (error.toString().contains('User not found') ||
            error.toString().contains('Unauthorized')) {
          await _handleUserNotFound();
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text('Error fetching profile: ${error.toString()}')),
          // );
          showTopSnackBar(
            context,
            'Error fetching profile: ${error.toString()}',
          );
        }
      }
    }
  }

  Future<void> _handleUserNotFound() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!_isDisposed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? email = prefs.getString('user_email');
    String? fcmToken = prefs.getString('fcm_token');

    if (fcmToken == null) {
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await prefs.setString('fcm_token', fcmToken);
      }
    }

    if (email == null || fcmToken == null) {
      showTopSnackBar(context, 'Missing user data. Please try again.');
      return;
    }

    final result = await UserService.logout();

    if (result['success'] == true) {
      await prefs.remove('auth_token');
      await prefs.remove('fcm_token');
      await prefs.remove('user_email');
      await prefs.remove('wishlist');

      // ✅ Notify provider once
      Provider.of<LoginProvider>(context, listen: false).setLogin(false);

      Provider.of<WishlistManager>(context, listen: false).clearWishlist();

      if (!_isDisposed) {
        await Provider.of<CartProvider>(
          context,
          listen: false,
        ).fetchCartCount();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      }
    } else {
      if (!_isDisposed) {
        showTopSnackBar(
          context,
          result['message'] ?? 'Logout failed. Try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _isLoggedIn
        ? RefreshIndicator(
            color: mythemecolor,
            backgroundColor: Colors.grey[200],
            displacement: 60,
            strokeWidth: 3.0,
            onRefresh: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('auth_token');
              if (token != null) {
                await _fetchUserProfile(token);
                await Provider.of<CartProvider>(
                  context,
                  listen: false,
                ).fetchCartCount();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: isTablet(context)
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 800, // You can adjust the width as needed
                              child: _buildInfoTile(),
                            ),
                          ),

                          // _buildInfoTile(),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 24,
                                child: _buildNavigationCard(
                                  context,
                                  "My Orders",
                                  Icons.shopping_bag,
                                  OrderListPage(),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 24,
                                child: _buildNavigationCard(
                                  context,
                                  "Notifications",
                                  Icons.notifications,
                                  NotificationScreen(),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 24,
                                child: _buildNavigationCard(
                                  context,
                                  "Liked Items",
                                  Icons.favorite,
                                  FavoritesPage(),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 24,
                                child: _buildLogoutCard(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildInfoTile(),
                        _buildNavigationCard(
                          context,
                          "My Orders",
                          Icons.shopping_bag,
                          OrderListPage(),
                        ),
                        _buildNavigationCard(
                          context,
                          "Notifications",
                          Icons.notifications,
                          NotificationScreen(),
                        ),
                        _buildNavigationCard(
                          context,
                          "Liked Items",
                          Icons.favorite,
                          FavoritesPage(),
                        ),
                        // _buildLogoutCard(context),
                        SizedBox(
                          width: isTablet(context)
                              ? MediaQuery.of(context).size.width / 2 - 32
                              : double.infinity,
                          child: _buildLogoutCard(context),
                        ),
                      ],
                    ),
            ),
          )
        : Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet(context) ? 250.0 : 300.0),
        // preferredSize: const Size.fromHeight(300.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
               mythemecolor1,
               mythemecolor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BottomNavBar(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: isTablet(context) ? 40 : 48,
                        backgroundColor: Color.fromARGB(255, 193, 177, 186),
                        child: Icon(
                          Icons.person,
                          size: isTablet(context) ? 37 : 47,
                          color: mythemecolor
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditUserDetailsPage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: isTablet(context) ? 18 : 22,
                          backgroundColor: Color.fromARGB(255, 64, 152, 189),
                          child: Icon(
                            Icons.edit_note,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet(context) ? 10 : 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      children: [
                        const TextSpan(text: 'Hi, '),
                        TextSpan(
                          text: userName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' 👋🏻'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ready to explore amazing deals today?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'josefin',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: content,
    );
  }

  Widget _buildInfoTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.person, color: Colors.black),
        title: const Text(
          'Personal Info',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        children: [
          _buildInfoRow("Username", userName),
          _buildInfoRow("Email", userEmail),
          _buildInfoRow("City", userAddress),
          _buildInfoRow("Phone", userPhone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              textAlign: TextAlign.right,
              maxLines: null,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.black),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Logout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: screenWidth > 600 ? 400 : null,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Hey!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "No",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          241,
                          113,
                          104,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
