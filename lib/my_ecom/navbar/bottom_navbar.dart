import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/login_provider.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/user_profile.dart';
import 'package:furniture_ecom_app/my_ecom/categories.dart';
import 'package:furniture_ecom_app/my_ecom/homepage.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/favorites.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_list.dart';

import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  List<Widget> getScreens(bool isLoggedIn) {
    return [
      const Myhome(),
      const CategoriesScreen(),
      const OrderListPage(),
      const FavoritesPage(),
      isLoggedIn ? const ProfileScreen() : const LoginScreen(),
    ];
  }

  Future<bool> _onWillPop() async {
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      return false;
    } else {
      double screenWidth = MediaQuery.of(context).size.width;

      return await showDialog(
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
                      const Icon(Icons.warning_amber_rounded,
                          size: 50, color: mythemecolor),
                      const SizedBox(height: 15),
                      const Text(
                        "Exit App",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Are you sure you want to exit the app?",
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
                            onPressed: () =>
                                Navigator.of(context).pop(false), // Stay in app
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
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
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                   mythemecolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
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
          ) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, _) {
        final isLoggedIn = loginProvider.isLoggedIn;
        final screens = getScreens(isLoggedIn);

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            body: screens[currentIndex],
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  currentIndex: currentIndex,
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  selectedItemColor: mythemecolor,
                  unselectedItemColor: const Color.fromARGB(255, 82, 82, 82),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 10,
                  ),
                  type: BottomNavigationBarType.fixed,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded, size: 26),
                      label: 'Home',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_rounded, size: 26),
                      label: 'Categories',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.card_giftcard_rounded, size: 26),
                      label: 'My Orders',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_border_rounded, size: 26),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.account_circle, size: 26),
                      label: isLoggedIn ? 'Profile' : 'Login',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:model_app/Homepage.dart';
// import 'package:model_app/authentication/login_user.dart';
// import 'package:model_app/authentication/user_profile.dart';
// import 'package:model_app/categories.dart';
// import 'package:model_app/navbar/favorites.dart';
// import 'package:model_app/orders/order_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({super.key});

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int currentIndex = 0;
//   bool isLoggedIn = false;
//   List<Widget> screens = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeScreens();
//   }

//   Future<void> _initializeScreens() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');

//     setState(() {
//       isLoggedIn = token != null;
//       screens = [
//         const Myhome(),
//         const CategoriesScreen(),
//         const OrderListPage(),
//         const FavoritesPage(),
//         isLoggedIn ? const ProfileScreen() : const LoginScreen(),
//       ];
//     });
//   }

//   Future<bool> _onWillPop() async {
//     if (currentIndex != 0) {
//       setState(() {
//         currentIndex = 0;
//       });
//       return false;
//     } else {
//       double screenWidth = MediaQuery.of(context).size.width;

//       return await showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return Dialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Container(
//                   width: screenWidth > 600 ? 400 : null,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.warning_amber_rounded,
//                           size: 50, color: mythemecolor),
//                       const SizedBox(height: 15),
//                       const Text(
//                         "Exit App",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         "Are you sure you want to exit the app?",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () =>
//                                 Navigator.of(context).pop(false), // Stay in app
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey[300],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 12),
//                             ),
//                             child: const Text(
//                               "No",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () => Navigator.of(context).pop(true),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const mythemecolor
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 12),
//                             ),
//                             child: const Text(
//                               "Yes",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ) ??
//           false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (screens.isEmpty) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // ignore: deprecated_member_use
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         body: screens[currentIndex],
//         bottomNavigationBar: Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(0),
//               topRight: Radius.circular(0),
//             ),
//             child: BottomNavigationBar(
//               backgroundColor: Colors.white,
//               currentIndex: currentIndex,
//               onTap: (index) {
//                 setState(() {
//                   currentIndex = index;
//                 });
//               },
//               selectedItemColor: const Color.fromARGB(255, 21, 108, 24),
//               unselectedItemColor: const Color.fromARGB(255, 68, 67, 67),
//               showSelectedLabels: true,
//               showUnselectedLabels: true,
//               selectedLabelStyle: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontSize: 10,
//               ),
//               type: BottomNavigationBarType.fixed,
//               items: [
//                 const BottomNavigationBarItem(
//                   icon: Icon(Icons.home_rounded, size: 26),
//                   label: 'Home',
//                 ),
//                 const BottomNavigationBarItem(
//                   icon: Icon(Icons.grid_view_rounded, size: 26),
//                   label: 'Categories',
//                 ),
//                 const BottomNavigationBarItem(
//                   icon: Icon(Icons.card_giftcard_rounded, size: 26),
//                   label: 'My Orders',
//                 ),
//                 const BottomNavigationBarItem(
//                   icon: Icon(Icons.favorite_border_rounded, size: 26),
//                   label: 'Favorites',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: const Icon(Icons.account_circle, size: 26),
//                   label: isLoggedIn ? 'Profile' : 'Login',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
