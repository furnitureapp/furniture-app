import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/notif_maitence.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  final Set<String> _readNotifications = {};

  int get unreadCount => _unreadCount;

  Future<void> loadInitialUnreadCount() async {
    final notifications =
        await NotifMaintenanceService.getNotifications();

    _readNotifications.clear();

    for (final n in notifications) {
      if (n.isRead) {
        _readNotifications.add(n.id);
      }
    }

    _unreadCount =
        notifications.where((n) => !n.isRead).length;

    notifyListeners();
  }

  void markAsRead(String id) {
    if (!_readNotifications.contains(id)) {
      _readNotifications.add(id);
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      notifyListeners();
    }
  }

  bool isRead(String id) => _readNotifications.contains(id);
}
