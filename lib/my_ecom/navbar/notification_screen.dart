import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/notif_maitence.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Notifications>> _notificationHistory;
  Map<String, bool> _readStatus = {};
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
    _loadReadStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getStringList('readNotifications') ?? [];
    setState(() {
      _readStatus = {for (var id in savedStatus) id: true};
    });
  }

  Future<void> _saveReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds =
        _readStatus.keys.where((id) => _readStatus[id] == true).toList();
    await prefs.setStringList('readNotifications', readIds);
  }

  void handleNotificationTap(String? page, String? productId,
      String notificationId, String? orderId, String? deliveryId) {
    setState(() {
      _readStatus[notificationId] = true;
    });
    _saveReadStatus();

    if (productId != null && productId.isNotEmpty) {
      Navigator.pushNamed(context, '/productdetailpagep', arguments: productId);
    } else if (orderId != null && orderId.isNotEmpty) {
      Navigator.pushNamed(context, '/order-details',
          arguments: {'orderId': orderId, 'deliveryId': deliveryId});
    } else if (page == '/homeoffer') {
      Navigator.pushNamed(context, '/homeoffer');
    } else if (page != null && page.isNotEmpty) {
      Navigator.pushNamed(context, page);
    } else {
      print("No valid page or productId found in the notification.");
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                  mythemecolor1,
               mythemecolor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
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
      body: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                isTablet ? 'assets/images/theme.png' : 'assets/images/theme.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            _isLoggedIn
                ? FutureBuilder<List<Notifications>>(
                    future: _notificationHistory,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: AnimationPage1());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return _buildEmptyNotifications(isTablet);
                      } else {
                        return _buildNotificationList(snapshot.data!, isTablet);
                      }
                    },
                  )
                : _buildLoginPrompt(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications(bool isTablet) {
    return
     
        Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 20),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 30 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 228, 215, 226),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/notif.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                if (!isTablet) const SizedBox(height: 5),
                Text(
                  "Hey Keep Shopping!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Your notifications will appear here!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BottomNavBar()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTablet ? Colors.white : mythemecolor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 30,
                      vertical: isTablet ? 14 : 12,
                    ),
                    textStyle: TextStyle(
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor:
                        isTablet ? mythemecolor : Colors.white,
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

  Widget _buildNotificationList(
      List<Notifications> notifications, bool isTablet) {
    return isTablet
        ? RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _notificationHistory = NotifMaintenanceService.getNotifications();
              });
            },
            color: const Color.fromARGB(255, 13, 75, 15),
            backgroundColor: const Color.fromARGB(255, 245, 240, 242),
            displacement: 40,
            strokeWidth: 2.5,
            child: Center(
              child: Card(
                shadowColor: const Color.fromARGB(255, 34, 105, 37),
                elevation: 5,
                margin: const EdgeInsets.all(50),
                child: Container(
                  width: MediaQuery.of(context).size.width - 50,
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isRead = _readStatus[notification.id] ?? false;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            handleNotificationTap(
                              notification.page,
                              notification.productId,
                              notification.id,
                              notification.orderId,
                              notification.deliveryId,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                isRead
                                    ? Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Icon(
                                            FontAwesomeIcons.check,
                                            size: 25,
                                            color: Colors.white),
                                      )
                                    : const Icon(FontAwesomeIcons.bell,
                                        size: 35, color: Colors.blue),
                                const SizedBox(width: 30),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color:
                                                Color.fromARGB(255, 7, 71, 9),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        notification.body,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatDate(notification.date),
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    size: 30,
                                    color: Color.fromARGB(255, 2, 57, 4)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _notificationHistory = NotifMaintenanceService.getNotifications();
              });
            },
            color: const Color.fromARGB(255, 13, 75, 15),
            backgroundColor: const Color.fromARGB(255, 245, 240, 242),
            displacement: 40,
            strokeWidth: 2.5,
            child: ListView.builder(
              itemCount: notifications.length + 1,
              itemBuilder: (context, index) {
                if (index < notifications.length) {
                  final notification = notifications[index];
                  final isRead = _readStatus[notification.id] ?? false;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          handleNotificationTap(
                            notification.page,
                            notification.productId,
                            notification.id,
                            notification.orderId,
                            notification.deliveryId,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              isRead
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Icon(FontAwesomeIcons.check,
                                          size: 15, color: Colors.white),
                                    )
                                  : const Icon(FontAwesomeIcons.bell,
                                      size: 25, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 10, 78, 12),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      notification.body,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDate(notification.date),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 96, 95, 95)),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 25,
                                  color: Color.fromARGB(255, 2, 57, 4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BottomNavBar()),
                          (route) => false,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                               mythemecolor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isTablet ? 12 : 10),
                          ),
                        ),
                        child: Text(
                          "Return to Shop!",
                          style: TextStyle(
                            color:  mythemecolor1,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          );
  }

  Widget _buildLoginPrompt(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 20),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 30 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 228, 215, 226),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/notif.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                if (!isTablet) const SizedBox(height: 5),
                Text(
                  "You are not logged in!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Your notifications will appear here!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('redirectRoute', '/notification');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTablet ? Colors.white : mythemecolor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 30,
                      vertical: isTablet ? 14 : 12,
                    ),
                    textStyle: TextStyle(
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor:
                        isTablet ? mythemecolor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Go To Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


