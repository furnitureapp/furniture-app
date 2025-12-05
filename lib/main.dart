import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/login_provider.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/user_profile.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_screen.dart';
import 'package:furniture_ecom_app/my_ecom/categories.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/favorites.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/notification_screen.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/privacy_contents/privacy_policy.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/privacy_contents/terms_conditions.dart';
import 'package:furniture_ecom_app/my_ecom/notfound.dart';
import 'package:furniture_ecom_app/my_ecom/notification.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_detail.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_list.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';
import 'package:furniture_ecom_app/my_splash_screen.dart';

import 'package:provider/provider.dart';
import 'my_ecom/offer/offer_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;

  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await NotificationHandler.initializeNotifications();
  await NotificationHandler.initializeFCM();
  await NotificationHandler.requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishlistManager()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  if (message.notification != null) {
    debugPrint('Notification Title: ${message.notification?.title}');
    debugPrint('Notification Body: ${message.notification?.body}');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setOrientationBasedOnDevice();
    });
  }

  void _setOrientationBasedOnDevice() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;

      if (screenWidth >= 600) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreenMY(),
      routes: {
        '/homeoffer': (context) => const OfferPage(),
        '/category': (context) => const CategoriesScreen(),
        '/product/:productId': (context) => const ProductDetailPagep(),
        '/cart': (context) => const CartScreen(),
        '/wishlist': (context) => const FavoritesPage(),
        '/login': (context) => const LoginScreen(),
        '/myhome': (context) => const BottomNavBar(),
        '/profile': (context) => const ProfileScreen(),
        '/myorders': (context) => const OrderListPage(),
        '/notification': (context) => const NotificationScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/terms-and-conditions': (context) => const TermsPage(),
        '/order-details': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            final orderId = args['orderId'] as String?;
            if (orderId != null) {
              return OrderDetailsScreen(orderId: orderId);
            }
          }
          return const Scaffold(body: Center(child: Text("Invalid Order ID")));
        },
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => NotFoundPage());
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order-details') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('orderId')) {
            final orderId = args['orderId'] as String;
            debugPrint(orderId);
            return MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: orderId),
            );
          } else {
            return MaterialPageRoute(builder: (context) => const ErrorPage());
          }
        }

        if (settings.name == '/productdetailpagep') {
          final productId = settings.arguments as String;
          debugPrint(
            "Navigating to ProductDetailPage with productId: $productId",
          );
          return MaterialPageRoute(
            builder: (context) => ProductDetailPagep(productId: productId),
          );
        }

        return null;
      },
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Error: Order ID is missing or invalid.')),
    );
  }
}
