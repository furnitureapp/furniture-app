// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/cart_screen.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
// import 'package:furniture_ecom_app/my_ecom/navbar/notification_screen.dart';
// import 'package:furniture_ecom_app/my_ecom/navbar/searchtab.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:badges/badges.dart' as badges;
// import 'package:shared_preferences/shared_preferences.dart';

// class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;

//   const MyAppbar({super.key, required this.title});

//   Future<bool> _isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//     return token != null && token.isNotEmpty;
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   double screenWidth = MediaQuery.of(context).size.width;

//   //   return AppBar(
//   //     iconTheme: IconThemeData(color: mythemecolor, size: 30),
//   //     backgroundColor: const Color.fromARGB(255, 185, 168, 181),
//   //     title: FutureBuilder<bool>(
//   //       future: _isLoggedIn(),
//   //       builder: (context, snapshot) {
//   //         final loggedIn = snapshot.data ?? false;

//   //         return screenWidth < 600
//   //             ? _buildMobileTitle(context, loggedIn)
//   //             : _buildTabletTitle(context, screenWidth, loggedIn);
//   //       },
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return PreferredSize(
//       preferredSize: const Size.fromHeight(110.0),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: mythemecolor,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//         ),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: const IconThemeData(color: mythemecolor, size: 30),
//           title: FutureBuilder<bool>(
//             future: _isLoggedIn(),
//             builder: (context, snapshot) {
//               final loggedIn = snapshot.data ?? false;
//               return screenWidth < 600
//                   ? _buildMobileTitle(context, loggedIn)
//                   : _buildTabletTitle(context, screenWidth, loggedIn);
//             },
//           ),
//           centerTitle: true,
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileTitle(BuildContext context, bool isLoggedIn) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         GestureDetector(
//           onTap: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const BottomNavBar()),
//               (route) => false,
//             );
//           },
//           child:

//               CircleAvatar(
//                 radius: 20,

//                 child: ClipOval(
//                   child: Image.asset(
//                     'assets/images/kaii.jpg',
//                     fit: BoxFit.cover,
//                     height: 35,
//                     width: 38,
//                   ),
//                 ),
//               ),
//         ),

//         const Spacer(),

//         Text(
//           "KAI",
//           style: GoogleFonts.arvo(
//             fontStyle: FontStyle.normal,
//             fontSize: 22,
//             textBaseline: TextBaseline.ideographic,
//             letterSpacing: 5.3,
//             fontWeight: FontWeight.bold,
//             color: mythemecolor,
//           ),
//         ),

//         const Spacer(),

//         IconButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NotificationScreen(),
//               ),
//             );
//           },
//           icon: const Icon(
//             Icons.notifications_active_outlined,
//             color: mythemecolor,
//             size: 25,
//           ),
//         ),

//         Consumer<CartProvider>(
//           builder: (context, cartProvider, child) {
//             Widget cartIcon = IconButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const CartScreen()),
//                 ).then((_) {
//                   Provider.of<CartProvider>(
//                     context,
//                     listen: false,
//                   ).fetchCartCount();
//                 });
//               },
//               icon: const Icon(
//                 Icons.shopping_cart_outlined,
//                 color: mythemecolor,
//                 size: 27,
//               ),
//             );

//             if (isLoggedIn && cartProvider.cartCount >= 0) {
//               return badges.Badge(
//                 position: badges.BadgePosition.topEnd(top: -5, end: -1),
//                 badgeStyle: const badges.BadgeStyle(
//                   badgeColor: mythemecolor1,
//                   padding: EdgeInsets.all(5),
//                 ),
//                 badgeContent: Text(
//                   "${cartProvider.cartCount}",
//                   style: const TextStyle(color: mythemecolor, fontSize: 10),
//                 ),
//                 child: cartIcon,
//               );
//             } else {
//               return cartIcon;
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildTabletTitle(
//     BuildContext context,
//     double screenWidth,
//     bool isLoggedIn,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             const SizedBox(width: 10),

//             GestureDetector(
//               onTap: () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const BottomNavBar()),
//                   (route) => false,
//                 );
//               },
//               child: CircleAvatar(
//                 backgroundImage: AssetImage('assets/images/kaii.jpg'),
//                 radius: 20,
//                 backgroundColor: Colors.transparent,
//                 onBackgroundImageError: (_, __) {},
//               ),
//             ),

//             const SizedBox(width: 20),

//             // ✅ Title
//             Text(
//               title,
//               style: GoogleFonts.arvo(
//                 fontStyle: FontStyle.normal,
//                 fontSize: 30,
//                 color: mythemecolor,
//               ),
//             ),
//           ],
//         ),

//         // ✅ Search bar (unchanged)
//         Flexible(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 5),
//             width: 800,
//             child: const SearchScreensTablet(),
//           ),
//         ),

//         // ✅ Notification icon
//         IconButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NotificationScreen(),
//               ),
//             );
//           },
//           icon: const Icon(
//             Icons.notifications_active,
//             color: mythemecolor,
//             size: 30,
//           ),
//         ),

//         Consumer<CartProvider>(
//           builder: (context, cartProvider, child) {
//             Widget cartIcon = IconButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const CartScreen()),
//                 ).then((_) {
//                   Provider.of<CartProvider>(
//                     context,
//                     listen: false,
//                   ).fetchCartCount();
//                 });
//               },
//               icon: Image.asset(
//                 'assets/images/cartt.png',
//                 fit: BoxFit.contain,
//                 height: 30,
//                 width: 30,
//               ),
//             );

//             if (isLoggedIn && cartProvider.cartCount > 0) {
//               return badges.Badge(
//                 position: badges.BadgePosition.topEnd(top: -5, end: -1),
//                 badgeStyle: const badges.BadgeStyle(
//                   badgeColor: mythemecolor1,
//                   padding: EdgeInsets.all(5),
//                 ),
//                 badgeContent: Text(
//                   "${cartProvider.cartCount}",
//                   style: const TextStyle(color: mythemecolor, fontSize: 12),
//                 ),
//                 child: cartIcon,
//               );
//             } else {
//               return cartIcon;
//             }
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(90.0);
// }

// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/cart_screen.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
// import 'package:furniture_ecom_app/my_ecom/navbar/notification_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:badges/badges.dart' as badges;
// import 'package:shared_preferences/shared_preferences.dart';

// class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
//   final String title; // keep for compatibility

//   const MyAppbar({super.key, required this.title});

//   Future<bool> _isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//     return token != null && token.isNotEmpty;
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isTablet = screenWidth > 600;

//     return PreferredSize(
//       preferredSize: const Size.fromHeight(120.0),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               Color.fromARGB(255, 227, 211, 244),
//               Colors.white,
//               Color.fromARGB(255, 227, 211, 244),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.45),
//               offset: const Offset(0, 3),
//               blurRadius: 8,
//             ),
//           ],
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(28),
//             bottomRight: Radius.circular(28),
//           ),
//         ),
//         child: AppBar(
//           automaticallyImplyLeading: true,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: const IconThemeData(color: mythemecolor, size: 32),

//           centerTitle: true,
//           title: FutureBuilder<bool>(
//             future: _isLoggedIn(),
//             builder: (context, snapshot) {
//               final loggedIn = snapshot.data ?? false;
//               return _buildAppbarContent(context, loggedIn, isTablet);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppbarContent(
//     BuildContext context,
//     bool isLoggedIn,
//     bool isTablet,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isTablet ? 30 : 20,
//         vertical: 10,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const BottomNavBar()),
//                   (route) => false,
//                 );
//               },
//               child: Image.asset(
//                 'assets/images/woodpecker_logo.png',
//                 height: isTablet ? 70 : 100,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),

          
//           Padding(
//             padding: const EdgeInsets.only(right: 30), 
//             child: Row(
//               children: [
//                 _buildIconButton(
//                   icon: Icons.notifications_active_outlined,
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const NotificationScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(width: 10),
//                 _buildCartBadge(context, isLoggedIn),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: mythemecolor1.withOpacity(0.15),
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(icon, color: mythemecolor, size: 23),
//         onPressed: onPressed,
//       ),
//     );
//   }

//   Widget _buildCartBadge(BuildContext context, bool isLoggedIn) {
//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, child) {
//         Widget cartIcon = _buildIconButton(
//           icon: Icons.shopping_cart_outlined,
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const CartScreen()),
//             ).then((_) {
//               Provider.of<CartProvider>(
//                 context,
//                 listen: false,
//               ).fetchCartCount();
//             });
//           },
//         );

//         if (isLoggedIn && cartProvider.cartCount > 0) {
//           return badges.Badge(
//             position: badges.BadgePosition.topEnd(top: -5, end: -1),
//             badgeStyle: const badges.BadgeStyle(
//               badgeColor: Colors.orangeAccent,
//               padding: EdgeInsets.all(5),
//             ),
//             badgeContent: Text(
//               "${cartProvider.cartCount}",
//               style: const TextStyle(color: mythemecolor, fontSize: 10),
//             ),
//             child: cartIcon,
//           );
//         } else {
//           return cartIcon;
//         }
//       },
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(90);
// }

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_screen.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/notification_screen.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/searchtab.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // keep for compatibility with other pages

  const MyAppbar({super.key, required this.title});

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
        // Logo → Home
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavBar()),
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
            children: [
              _buildIconButton(
                icon: Icons.notifications_active_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              _buildCartBadge(context, isLoggedIn),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletAppbar(BuildContext context, bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo → Home
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavBar()),
                (route) => false,
              );
            },
            child: Image.asset(
              'assets/images/woodpecker_logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SearchScreensTablet(),
            ),
          ),

          Row(
            children: [
              _buildIconButton(
                icon: Icons.notifications_active_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCartBadge(context, isLoggedIn),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Reusable Icon Button
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: mythemecolor1.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: mythemecolor, size: 23),
        onPressed: onPressed,
      ),
    );
  }

  // 🔹 Cart Badge
  Widget _buildCartBadge(BuildContext context, bool isLoggedIn) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        Widget cartIcon = _buildIconButton(
          icon: Icons.shopping_cart_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ).then((_) {
              Provider.of<CartProvider>(context, listen: false).fetchCartCount();
            });
          },
        );

        if (isLoggedIn && cartProvider.cartCount > 0) {
          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: -5, end: -1),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Color.fromARGB(255, 63, 38, 84),
              padding: EdgeInsets.all(4),
            ),
            badgeContent: Text(
              "${cartProvider.cartCount}",
              style: const TextStyle(color: Colors.white, fontSize: 11),
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
  Size get preferredSize => const Size.fromHeight(90);
}



// Color(0xFF461066), Color(0xFF69309E)