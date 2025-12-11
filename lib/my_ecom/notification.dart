import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // -------------------------------------------------------------
  // INITIALIZE LOCAL NOTIFICATIONS
  // -------------------------------------------------------------
  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );

    await createNotificationChannel();
  }

  // -------------------------------------------------------------
  // LOCAL NOTIFICATION TAP HANDLER
  // -------------------------------------------------------------
  static Future<void> selectNotification(NotificationResponse response) async {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      handleNotificationTap(
        page: data['page'],
        productId: data['productId'],
        orderId: data['orderId'],
      );
    }
  }

  // -------------------------------------------------------------
  // SHOW LOCAL NOTIFICATION (FOREGROUND)
  // -------------------------------------------------------------
  static Future<void> showLocalNotification(
    String title,
    String body,
    String payload,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'furniture_app_notifications', // SAME CHANNEL ID
          'Furniture Hub Notifications',
          channelDescription: 'Notifications for order updates and offers',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // -------------------------------------------------------------
  // CREATE ANDROID NOTIFICATION CHANNEL
  // -------------------------------------------------------------
  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'furniture_app_notifications', // NEW CHANNEL ID
      'Furniture Hub Notifications', // NAME
      description: 'Notifications for order updates and offers',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // -------------------------------------------------------------
  // BACKGROUND TAP (APP IN BACKGROUND)
  // -------------------------------------------------------------
  static Future<void> _onBackgroundTap(RemoteMessage message) async {
    print("Tapped notification (background): ${message.messageId}");

    final data = message.data;

    handleNotificationTap(
      page: data['page'],
      productId: data['productId'],
      orderId: data['orderId'],
    );
  }

  // -------------------------------------------------------------
  // INITIALIZE FCM + REGISTER ALL LISTENERS
  // -------------------------------------------------------------
  static Future<void> initializeFCM() async {
    if (_initialized) return;
    _initialized = true;

    print('Initializing FCM');

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission();

    // FCM Token
    String? token = await messaging.getToken();
    print("FCM Token for notification: $token");

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // User taps notification when app is in BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen(_onBackgroundTap);

    // HANDLED IN main.dart (required by Firebase)
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    print("FCM Handlers Registered");
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
  print("Foreground FCM received: ${message.messageId}");

  final notification = message.notification;
  final data = message.data;

  String title = notification?.title ?? data['title'] ?? 'Notification';
  String body = notification?.body ?? data['body'] ?? '';

  // Always show local notification in foreground — even for data-only messages
  await showLocalNotification(
    title,
    body,
    jsonEncode({
      'page': data['page'],
      'productId': data['productId'],
      'orderId': data['orderId'],
    }),
  );
}


  // -------------------------------------------------------------
  // UNIVERSAL TAP HANDLER (local + firebase)
  // -------------------------------------------------------------
  static void handleNotificationTap({
    String? page,
    String? productId,
    String? orderId,
  }) {
    print(
      "Notification tapped -> page:$page productId:$productId orderId:$orderId",
    );

    // ---- ORDER: Highest Priority ----
    if (orderId != null && orderId.isNotEmpty) {
      print("Navigating to OrderDetailsScreen: $orderId");

      // Reset to home (clean stack)
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/myhome',
        (Route<dynamic> route) => false,
      );

      Future.delayed(const Duration(milliseconds: 150), () {
        navigatorKey.currentState?.pushNamed(
          '/order-details',
          arguments: {'orderId': orderId},
        );
      });
      return;
    }

    // ---- OFFER PAGE ----
    if (page == '/homeoffer') {
      navigatorKey.currentState?.pushNamed('/homeoffer');
      return;
    }

    // ---- PRODUCT DETAIL ----
    if (productId != null && productId.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(
        '/productdetailpagep',
        arguments: productId,
      );
      return;
    }

    // ---- GENERIC PAGE ----
    if (page != null && page.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(page);
      return;
    }

    print("⚠ No valid navigation target in notification payload.");
  }

  // -------------------------------------------------------------
  // REQUEST PERMISSION
  // -------------------------------------------------------------
  static Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
  }
}





// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class NotificationHandler {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   static bool _initialized = false;

//   static Future<void> initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: selectNotification,
//     );

//     createNotificationChannel();
//   }

//   static Future<void> selectNotification(NotificationResponse response) async {
//     if (response.payload != null) {
//       final data = jsonDecode(response.payload!);
//       final page = data['page'];
//       final productId = data['productId'];
//       final orderId = data['orderId'];
//       handleNotificationTap(
//           page: page,
//           productId: productId,
//           orderId: orderId,
//           );
//     }
//   }

//   static Future<void> showLocalNotification(
//     String title,
//     String body,
//     String payload,
//   ) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'grocery_app_updates',
//       'Grocery App Updates',
//       channelDescription: 'Notifications for updates and special offers',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//       icon: '@drawable/ic_notification',
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     print('Showing notification with ID: $notificationId');

//     await flutterLocalNotificationsPlugin.show(
//       notificationId,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: payload,
//     );
//   }

//   static Future<void> createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'grocery_app_updates',
//       'Grocery App Updates',
//       description: 'Notifications for updates and special offers',
//       importance: Importance.max,
//     );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   static Future<void> handleForegroundMessages() async {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print("Foreground notification received: ${message.messageId}");

//       if (message.notification != null) {
//         final data = message.data;
//         final page = data['page'];
//         final productId = data['productId'];
//         final orderId = data['orderId'];
//         showLocalNotification(
//           message.notification!.title ?? 'No Title',
//           message.notification!.body ?? 'No Body',
//           jsonEncode({
//             'page': page,
//             'productId': productId,
//             'orderId': orderId,
//           }),
//         );
//       }
//     });
//   }

//   static Future<void> handleBackgroundMessages() async {
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       print('Notification clicked in background: ${message.messageId}');

//       final data = message.data;
//       final page = data['page'];
//       final productId = data['productId'];
//       final orderId = data['orderId'];

//       handleNotificationTap(
//         page: page,
//         productId: productId,
//         orderId: orderId,
//       );
//     });
//   }

//   static Future<void> initializeFCM() async {
//     if (_initialized) return;
//     _initialized = true;

//     print('Initializing FCM');
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     await messaging.requestPermission();

//     String? token = await messaging.getToken();
//     print("FCM Token: $token");

//     handleForegroundMessages();
//     handleBackgroundMessages();
//   }

//   static void handleNotificationTap({
//     String? page,
//     String? productId,
//     String? orderId,
//   }) {
//     print(
//         "Notification tapped with page: $page, productId: $productId, orderId: $orderId ");
        
//     print("Received notification payload: ${jsonEncode({
//           'page': page,
//           'productId': productId,
//           'orderId': orderId,
//         })}");

//     if (orderId != null &&
//         orderId.isNotEmpty 
      
//         ) {
//       print(
//           "Navigating to OrderDetailsScreen with orderId: $orderId");
   
// //       navigatorKey.currentState?.pushReplacementNamed(
// //   '/order-details',
  
// //   arguments: {'orderId': orderId},
// // );
// navigatorKey.currentState?.pushNamedAndRemoveUntil(
//   '/myhome',
//   (Route<dynamic> route) => false,
// );

// Future.delayed(Duration(milliseconds: 100), () {
//   navigatorKey.currentState?.pushNamed(
//     '/order-details',
//     arguments: {'orderId': orderId},
//   );
// });


//     } else if (page == '/homeoffer') {
//       print("Navigating to OfferPage...");
//       navigatorKey.currentState?.pushNamed(
//         '/homeoffer',
//       );
//     } else if (productId != null && productId.isNotEmpty) {
//       print("Navigating to ProductDetailPage...");
//       navigatorKey.currentState?.pushNamed(
//         '/productdetailpagep',
//         arguments: productId,
//       );
//     } else if (page != null && page.isNotEmpty) {
//       print("Navigating to page: $page...");
//       navigatorKey.currentState?.pushNamed(page);
//     } else {
//       print("No valid action provided in the notification payload");
//     }
//   }


//   static Future<void> requestNotificationPermission() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     await messaging.requestPermission();
//   }
// }


