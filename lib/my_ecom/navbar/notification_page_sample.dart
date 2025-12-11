import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/notif_maitence.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Notifications>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsFuture = NotifMaintenanceService.getNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _loadNotifications();
    });
    await _notificationsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Notifications>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final notifications = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.blue),
                    title: Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification.body),
                    trailing: Text(
                      formatDate(notification.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    // Format date as per your needs
    return "${date.day}-${date.month}-${date.year}";
  }
}
