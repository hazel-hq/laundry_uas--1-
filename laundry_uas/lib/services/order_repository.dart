import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/order.dart';

class OrderRepository {
  OrderRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Order>> fetchOrders({AppUser? user}) async {
    var query = _client.from('orders').select('*, order_items(*)');

    if (user != null && !user.isAdmin) {
      query = query.eq('customer_username', user.username);
    }

    final rows = await query.order('ordered_at', ascending: false);

    return rows
        .map((row) => Order.fromSupabase(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Order> createOrder(Order order) async {
    final insertedOrder = await _client
        .from('orders')
        .insert(order.toOrderInsert(username: currentAppUser?.username))
        .select()
        .single();

    final orderId = '${insertedOrder['id']}';

    await _client.from('order_items').insert(order.toItemInsert(orderId));

    return fetchOrderById(orderId);
  }

  Future<Order> fetchOrderById(String id) async {
    final row = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single();

    return Order.fromSupabase(Map<String, dynamic>.from(row));
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);
  }

  Future<void> confirmPayment({
    required Order order,
    required String method,
  }) async {
    await _client.from('payments').insert({
      'order_id': order.id,
      'method': method,
      'status': 'Lunas',
      'amount': order.total,
      'paid_at': DateTime.now().toIso8601String(),
    });
  }
}
