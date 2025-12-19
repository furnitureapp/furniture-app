import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/notif_maitence.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/notifications/notif_provider.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_page.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_detail.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<List<Notifications>>? _notificationHistory;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkLoginStatus();
    if (_isLoggedIn) {
      setState(() {
        _notificationHistory = NotifMaintenanceService.getNotifications();
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }



void handleNotificationTap(
  String? page,
  String? productId,
  String notificationId,
  String? orderId,
  String? deliveryId,
) {
  final provider = context.read<NotificationProvider>();
  provider.markAsRead(notificationId);

  if (productId != null && productId.isNotEmpty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPagep(productId: productId),
      ),
    );
  } else if (orderId != null && orderId.isNotEmpty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(
          orderId: orderId,
        ),
      ),
    );
  } else if (page == '/homeoffer') {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OfferPage()),
    );
  }
  else if (page == '/myhome') {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BottomNavBar()),
    );
  }

  NotifMaintenanceService.markNotificationAsRead(notificationId);
}

  String formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 215, 226),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mythemecolor1, mythemecolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Notification History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<List<Notifications>>(
        future: _notificationHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AnimationPage1());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyNotifications(isTablet);
          } else {
            final notifications = snapshot.data!;

            return _buildNotificationList(notifications, isTablet);
          }
        },
      ),
    );
  }

  Widget _buildEmptyNotifications(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 10),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 30 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 228, 215, 226),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/notif.png', width: 170, height: 170),
                Text(
                  "Hey Keep Shopping!",
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Your notifications will appear here!",
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<Notifications> notifications,
    bool isTablet,
  ) {
    final provider = context.watch<NotificationProvider>();

    // 🔥 SYNC PROVIDER WITH API DATA

    return RefreshIndicator(
      onRefresh: () async {
        final data = await NotifMaintenanceService.getNotifications();

        setState(() {
          _notificationHistory = Future.value(data);
        });
        context.read<NotificationProvider>().loadInitialUnreadCount();
      },

      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isRead =
              provider.isRead(notification.id) || notification.isRead;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: isTablet
                  ? Colors.white
                  : const Color.fromARGB(255, 225, 224, 225),
              child: GestureDetector(
                onTap: () => handleNotificationTap(
                  notification.page,
                  notification.productId,
                  notification.id,
                  notification.orderId,
                  notification.deliveryId,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      isRead
                          ? Container(
                              decoration: const BoxDecoration(
                                color: mythemecolor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                FontAwesomeIcons.check,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              FontAwesomeIcons.bell,
                              color: mythemecolor1,
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: mythemecolor,
                              ),
                            ),
                            Text(notification.body),
                            Text(
                              formatDate(notification.date),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: mythemecolor),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



  // void handleNotificationTap(
  //   String? page,
  //   String? productId,
  //   String notificationId,
  //   String? orderId,
  //   String? deliveryId,
  // ) {
  //   context.read<NotificationProvider>().markAsRead(notificationId);

  //   if (productId != null && productId.isNotEmpty) {
  //     Navigator.pushNamed(context, '/productdetailpagep', arguments: productId);
  //   } else if (orderId != null && orderId.isNotEmpty) {
  //     Navigator.pushNamed(
  //       context,
  //       '/order-details',
  //       arguments: {'orderId': orderId, 'deliveryId': deliveryId},
  //     );
  //   } else if (page == '/homeoffer') {
  //     Navigator.pushNamed(context, '/homeoffer');
  //   } else if (page != null && page.isNotEmpty) {
  //     Navigator.pushNamed(context, page);
  //   }
  // }


// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
// import 'package:furniture_ecom_app/core/services_ecom/notif_maitence.dart';
// import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:intl/intl.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});

//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   late Future<List<Notifications>> _notificationHistory;
//   Map<String, bool> _readStatus = {};
//   bool _isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     await _checkLoginStatus();
//     if (_isLoggedIn) {
//       setState(() {
//         _notificationHistory = NotifMaintenanceService.getNotifications();
//       });
//     }
//     _loadReadStatus();
//   }
// int getUnreadCount(List<Notifications> notifications) {
//   return notifications
//       .where((n) => _readStatus[n.id] != true)
//       .length;
// }
 
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//     setState(() {
//       _isLoggedIn = token != null && token.isNotEmpty;
//     });
//   }

//   Future<void> _loadReadStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedStatus = prefs.getStringList('readNotifications') ?? [];
//     setState(() {
//       _readStatus = {for (var id in savedStatus) id: true};
//     });
//   }

//   Future<void> _saveReadStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final readIds = _readStatus.keys
//         .where((id) => _readStatus[id] == true)
//         .toList();
//     await prefs.setStringList('readNotifications', readIds);
//   }

//   void handleNotificationTap(
//     String? page,
//     String? productId,
//     String notificationId,
//     String? orderId,
//     String? deliveryId,
//   ) {
//     setState(() {
//       _readStatus[notificationId] = true;
//     });
//     _saveReadStatus();

//     if (productId != null && productId.isNotEmpty) {
//       Navigator.pushNamed(context, '/productdetailpagep', arguments: productId);
//     } else if (orderId != null && orderId.isNotEmpty) {
//       Navigator.pushNamed(
//         context,
//         '/order-details',
//         arguments: {'orderId': orderId, 'deliveryId': deliveryId},
//       );
//     } else if (page == '/homeoffer') {
//       Navigator.pushNamed(context, '/homeoffer');
//     } else if (page != null && page.isNotEmpty) {
//       Navigator.pushNamed(context, page);
//     } else {
//       print("No valid page or productId found in the notification.");
//     }
//   }

//   String formatDate(DateTime date) {
//     return DateFormat('MMM dd').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 228, 215, 226),
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [mythemecolor1, mythemecolor],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: Text(
//               "Notification History",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             centerTitle: true,
//           ),
//         ),
//       ),
//       body: Container(
//         color: Colors.transparent,
//         child: Stack(
//           children: [
            
            
//                  FutureBuilder<List<Notifications>>(
//                     future: _notificationHistory,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: AnimationPage1());
//                       } else if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       } else if (snapshot.data == null ||
//                           snapshot.data!.isEmpty) {
//                         return _buildEmptyNotifications(isTablet);
//                       } else {
//                         return _buildNotificationList(snapshot.data!, isTablet);
//                       }
//                     },
//                   )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyNotifications(bool isTablet) {
    
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(isTablet ? 40 : 10),
//         child: Card(
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(isTablet ? 30 : 10),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: const Color.fromARGB(255, 228, 215, 226),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Image.asset(
//                   'assets/images/notif.png',
//                   width: 170,
//                   height: 170,
//                   fit: BoxFit.cover,
//                 ),
//                 if (!isTablet) const SizedBox(height: 5),
//                 Text(
//                   "Hey Keep Shopping!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isTablet ? 24 : 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   "Your notifications will appear here!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isTablet ? 18 : 14,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
                
              
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationList(
//     List<Notifications> notifications,
//     bool isTablet,
//   ) {
//     return isTablet
//         ? RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _notificationHistory =
//                     NotifMaintenanceService.getNotifications();
//               });
//             },
//             color: mythemecolor,
//             backgroundColor: const Color.fromARGB(255, 245, 240, 242),
//             displacement: 40,
//             strokeWidth: 2.5,
//             child: Center(
//               child: Card(
//                 shadowColor: mythemecolor,
//                 elevation: 5,
//                 margin: const EdgeInsets.all(50),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width - 50,
//                   padding: const EdgeInsets.all(15),
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: notifications.length,
//                     itemBuilder: (context, index) {
//                       final notification = notifications[index];
//                       final isRead = _readStatus[notification.id] ?? false;

//                       return Card(
//                         color: Colors.white,
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: GestureDetector(
//                           onTap: () {
//                             handleNotificationTap(
//                               notification.page,
//                               notification.productId,
//                               notification.id,
//                               notification.orderId,
//                               notification.deliveryId,
//                             );
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               children: [
//                                 isRead
//                                     ? Container(
//                                         decoration: const BoxDecoration(
//                                           color: mythemecolor,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: const Icon(
//                                           FontAwesomeIcons.check,
//                                           size: 25,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : const Icon(
//                                         FontAwesomeIcons.bell,
//                                         size: 35,
//                                         color: mythemecolor1,
//                                       ),
//                                 const SizedBox(width: 30),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         notification.title,
//                                         style: const TextStyle(
//                                           fontSize: 20,
//                                           color: mythemecolor,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         notification.body,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w300,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         formatDate(notification.date),
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const Icon(
//                                   Icons.chevron_right,
//                                   size: 30,
//                                   color: mythemecolor,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           )
//         : RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _notificationHistory =
//                     NotifMaintenanceService.getNotifications();
//               });
//             },
//             color: mythemecolor,
//             backgroundColor: const Color.fromARGB(255, 245, 240, 242),
//             displacement: 40,
//             strokeWidth: 2.5,
//             child: ListView.builder(
//               itemCount: notifications.length + 1,
//               itemBuilder: (context, index) {
//                 if (index < notifications.length) {
//                   final notification = notifications[index];
//                   final isRead = _readStatus[notification.id] ?? false;
//                   return Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Card(
//                       color: const Color.fromARGB(255, 225, 224, 225),
//                       margin: const EdgeInsets.all(2),
//                       child: GestureDetector(
//                         onTap: () {
//                           handleNotificationTap(
//                             notification.page,
//                             notification.productId,
//                             notification.id,
//                             notification.orderId,
//                             notification.deliveryId,
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: Row(
//                             children: [
//                               isRead
//                                   ? Container(
//                                       decoration: const BoxDecoration(
//                                         color: mythemecolor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: const Icon(
//                                         FontAwesomeIcons.check,
//                                         size: 14,
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                   : const Icon(
//                                       FontAwesomeIcons.bell,
//                                       size: 25,
//                                       color: mythemecolor1,
//                                     ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       notification.title,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         color: mythemecolor,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       notification.body,
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       formatDate(notification.date),
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color.fromARGB(255, 96, 95, 95),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Icon(
//                                 Icons.chevron_right,
//                                 size: 25,
//                                 color: mythemecolor
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 return null; 
//               },
//             ),
//           );
//   }

// }

