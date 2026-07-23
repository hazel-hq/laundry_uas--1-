import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'order_repository.dart';

/// Menampilkan notifikasi lokal ketika status order milik pelanggan berubah.
///
/// Update dipantau melalui Supabase Realtime selama aplikasi tersambung.
class OrderStatusNotificationService {
  OrderStatusNotificationService();

  static const _channelId = 'order_tracking_updates';
  static const _channelName = 'Update status pesanan';

  final _notifications = FlutterLocalNotificationsPlugin();
  final _knownStatuses = <String, String>{};
  RealtimeChannel? _channel;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    );
    await _notifications.initialize(settings);

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> startForUser(AppUser user) async {
    await stop();
    if (user.isAdmin) return;

    final orders = await OrderRepository().fetchOrders(user: user);
    _knownStatuses.addEntries(
      orders.map((order) => MapEntry(order.id, order.status)),
    );

    _channel = Supabase.instance.client
        .channel('order-status-${user.username}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_username',
            value: user.username,
          ),
          callback: (payload) => _handleOrderUpdate(payload),
        )
        .subscribe();
  }

  Future<void> stop() async {
    final channel = _channel;
    _channel = null;
    _knownStatuses.clear();
    if (channel != null) {
      await Supabase.instance.client.removeChannel(channel);
    }
  }

  Future<void> _handleOrderUpdate(PostgresChangePayload payload) async {
    final orderId = '${payload.newRecord['id'] ?? ''}';
    final orderCode = '${payload.newRecord['order_code'] ?? orderId}';
    final status = '${payload.newRecord['status'] ?? ''}';
    if (orderId.isEmpty || status.isEmpty) return;

    final previousStatus = _knownStatuses[orderId];
    _knownStatuses[orderId] = status;
    if (previousStatus == null || previousStatus == status) return;

    await _notifications.show(
      orderId.hashCode & 0x7fffffff,
      'Status pesanan diperbarui',
      'Pesanan $orderCode kini berstatus $status.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Notifikasi perubahan status tracking pesanan laundry',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

final orderStatusNotificationService = OrderStatusNotificationService();
