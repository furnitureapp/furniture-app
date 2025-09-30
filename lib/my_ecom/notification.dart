import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );

    createNotificationChannel();
  }

  static Future<void> selectNotification(NotificationResponse response) async {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      final page = data['page'];
      final productId = data['productId'];
      final orderId = data['orderId'];
      handleNotificationTap(
          page: page,
          productId: productId,
          orderId: orderId,
          );
    }
  }

  static Future<void> showLocalNotification(
    String title,
    String body,
    String payload,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'grocery_app_updates',
      'Grocery App Updates',
      channelDescription: 'Notifications for updates and special offers',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    print('Showing notification with ID: $notificationId');

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'grocery_app_updates',
      'Grocery App Updates',
      description: 'Notifications for updates and special offers',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> handleForegroundMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Foreground notification received: ${message.messageId}");

      if (message.notification != null) {
        final data = message.data;
        final page = data['page'];
        final productId = data['productId'];
        final orderId = data['orderId'];
        showLocalNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No Body',
          jsonEncode({
            'page': page,
            'productId': productId,
            'orderId': orderId,
          }),
        );
      }
    });
  }

  static Future<void> handleBackgroundMessages() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('Notification clicked in background: ${message.messageId}');

      final data = message.data;
      final page = data['page'];
      final productId = data['productId'];
      final orderId = data['orderId'];

      handleNotificationTap(
        page: page,
        productId: productId,
        orderId: orderId,
      );
    });
  }

  static Future<void> initializeFCM() async {
    if (_initialized) return;
    _initialized = true;

    print('Initializing FCM');
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    print("FCM Token: $token");

    handleForegroundMessages();
    handleBackgroundMessages();
  }

  static void handleNotificationTap({
    String? page,
    String? productId,
    String? orderId,
  }) {
    print(
        "Notification tapped with page: $page, productId: $productId, orderId: $orderId ");
        
    print("Received notification payload: ${jsonEncode({
          'page': page,
          'productId': productId,
          'orderId': orderId,
        })}");

    if (orderId != null &&
        orderId.isNotEmpty 
      
        ) {
      print(
          "Navigating to OrderDetailsScreen with orderId: $orderId");
   
//       navigatorKey.currentState?.pushReplacementNamed(
//   '/order-details',
  
//   arguments: {'orderId': orderId},
// );
navigatorKey.currentState?.pushNamedAndRemoveUntil(
  '/myhome',
  (Route<dynamic> route) => false,
);

Future.delayed(Duration(milliseconds: 100), () {
  navigatorKey.currentState?.pushNamed(
    '/order-details',
    arguments: {'orderId': orderId},
  );
});


    } else if (page == '/homeoffer') {
      print("Navigating to OfferPage...");
      navigatorKey.currentState?.pushNamed(
        '/homeoffer',
      );
    } else if (productId != null && productId.isNotEmpty) {
      print("Navigating to ProductDetailPage...");
      navigatorKey.currentState?.pushNamed(
        '/productdetailpagep',
        arguments: productId,
      );
    } else if (page != null && page.isNotEmpty) {
      print("Navigating to page: $page...");
      navigatorKey.currentState?.pushNamed(page);
    } else {
      print("No valid action provided in the notification payload");
    }
  }


  static Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
  }
}










 // print("Notification tapped with page: $page, productId: $productId, orderId: $orderId ");
    //   if (orderId != null && orderId.isNotEmpty) {
    //   print("Navigating to OrderDetailsScreen with orderId: $orderId...");
    //   navigatorKey.currentState?.pushNamed(
    //     '/order-details',
    //     arguments: orderId,
    //   );
    // }