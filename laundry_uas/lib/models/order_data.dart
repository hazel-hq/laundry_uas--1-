import 'order.dart';
import 'app_user.dart';
import '../services/order_repository.dart';

List<Order> orderList = [];

final orderRepository = OrderRepository();

Future<void> refreshOrders() async {
  orderList = await orderRepository.fetchOrders(user: currentAppUser);
}
