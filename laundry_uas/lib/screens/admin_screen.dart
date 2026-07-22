import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/order.dart';
import '../models/order_data.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  static const _purple = Color(0xFF6C63FF);
  static const _statuses = [
    'Menunggu',
    'Dicuci',
    'Dijemur',
    'Selesai',
    'Diantar',
  ];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await refreshOrders();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Order order, String status) async {
    try {
      await orderRepository.updateStatus(order.id, status);
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status ${order.orderCode} diubah ke $status'),
          backgroundColor: _purple,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update status: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  void _logout() {
    currentAppUser = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = orderList
        .where((o) => o.status != 'Selesai' && o.status != 'Diantar')
        .length;
    final done = orderList.where((o) => o.status == 'Selesai').length;
    final paid = orderList.where((o) => o.statusBayar == 'Lunas').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Admin Laundry'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: _purple,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${currentAppUser?.fullName ?? 'Admin'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _AdminStat(label: 'Total', value: '${orderList.length}'),
                      const SizedBox(width: 8),
                      _AdminStat(label: 'Aktif', value: '$active'),
                      const SizedBox(width: 8),
                      _AdminStat(label: 'Lunas', value: '$paid'),
                      const SizedBox(width: 8),
                      _AdminStat(label: 'Selesai', value: '$done'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator(color: _purple)),
              )
            else if (_error != null)
              _ErrorPanel(message: _error!, onRetry: _loadOrders)
            else if (orderList.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    'Belum ada pesanan',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              const Text(
                'Daftar pesanan pelanggan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 10),
              ...orderList.map(
                (order) => _AdminOrderCard(
                  order: order,
                  statuses: _statuses,
                  onStatusChanged: (status) => _updateStatus(order, status),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label;
  final String value;
  const _AdminStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final List<String> statuses;
  final ValueChanged<String> onStatusChanged;

  const _AdminOrderCard({
    required this.order,
    required this.statuses,
    required this.onStatusChanged,
  });

  static const _purple = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderCode}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      order.nama,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _Meta(label: 'User', value: order.customerUsername ?? 'Guest'),
              _Meta(
                label: 'No. HP',
                value: order.customerPhone.isEmpty ? '-' : order.customerPhone,
              ),
              _Meta(label: 'Layanan', value: order.layanan),
              _Meta(label: 'Berat', value: '${order.berat} kg'),
              _Meta(label: 'Bayar', value: order.statusBayar),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: statuses.contains(order.status)
                ? order.status
                : statuses.first,
            decoration: InputDecoration(
              labelText: 'Status pesanan',
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: statuses
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null && value != order.status) {
                onStatusChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String label;
  final String value;
  const _Meta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'Gagal memuat pesanan',
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade400, fontSize: 12),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
