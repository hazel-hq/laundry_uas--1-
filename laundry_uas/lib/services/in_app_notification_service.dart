import 'package:flutter/material.dart';

class AppNotificationItem {
  final String id;
  final String orderId;
  final String orderCode;
  final String title;
  final String message;
  final String status;
  final DateTime timestamp;
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.orderId,
    required this.orderCode,
    required this.title,
    required this.message,
    required this.status,
    required this.timestamp,
    this.isRead = false,
  });
}

class InAppNotificationService extends ChangeNotifier {
  static final InAppNotificationService _instance =
      InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  final List<AppNotificationItem> _notifications = [];

  List<AppNotificationItem> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification({
    required String orderId,
    required String orderCode,
    required String title,
    required String message,
    required String status,
  }) {
    // Hindari duplikasi jika notifikasi order dengan status sama sudah di paling atas
    if (_notifications.isNotEmpty &&
        _notifications.first.orderId == orderId &&
        _notifications.first.status == status) {
      return;
    }

    final item = AppNotificationItem(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      orderCode: orderCode,
      title: title,
      message: message,
      status: status,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, item);
    notifyListeners();
  }

  void markAllAsRead() {
    for (var item in _notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

final inAppNotificationService = InAppNotificationService();
