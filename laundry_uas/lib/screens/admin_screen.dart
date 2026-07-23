import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/order.dart';
import '../models/order_data.dart';
import '../services/order_status_notification_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  static const _purple = Color(0xFF6C63FF);
  static const _darkText = Color(0xFF1A1A2E);
  static const _statuses = [
    'Menunggu',
    'Dicuci',
    'Dijemur',
    'Selesai',
    'Diantar',
  ];

  bool _loading = true;
  String? _error;
  String _filter = 'Semua';

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
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update status: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await orderStatusNotificationService.stop();
    if (!mounted) return;
    currentAppUser = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<Order> get _filteredOrders {
    if (_filter == 'Semua') return orderList;
    return orderList.where((order) => order.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final active = orderList
        .where((o) => o.status != 'Selesai' && o.status != 'Diantar')
        .length;
    final paid = orderList.where((o) => o.statusBayar == 'Lunas').length;
    final revenue = orderList
        .where((o) => o.statusBayar == 'Lunas')
        .fold<double>(0, (sum, order) => sum + order.total);
    final totalDiscount = orderList.fold<double>(
      0,
      (sum, order) => sum + order.discount,
    );
    final filteredOrders = _filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _darkText,
        elevation: 0,
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeaderPanel(
              adminName: currentAppUser?.fullName ?? 'Admin',
              totalOrders: orderList.length,
              activeOrders: active,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _MetricTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Total pesanan',
                  value: '${orderList.length}',
                  color: _purple,
                ),
                _MetricTile(
                  icon: Icons.pending_actions_outlined,
                  label: 'Sedang aktif',
                  value: '$active',
                  color: const Color(0xFFEF8E28),
                ),
                _MetricTile(
                  icon: Icons.local_offer_outlined,
                  label: 'Total diskon',
                  value: _formatCurrency(totalDiscount),
                  color: const Color(0xFF2E7D32),
                ),
                _MetricTile(
                  icon: Icons.payments_outlined,
                  label: 'Pendapatan lunas',
                  value: _formatCurrency(revenue),
                  color: const Color(0xFF1D6FB8),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PaymentSummary(
              paidOrders: paid,
              unpaidOrders: orderList.length - paid,
            ),
            const SizedBox(height: 18),
            _SectionHeader(
              title: 'Pesanan pelanggan',
              subtitle: '${filteredOrders.length} pesanan ditampilkan',
            ),
            const SizedBox(height: 10),
            _StatusFilter(
              selected: _filter,
              statuses: const ['Semua', ..._statuses],
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 70),
                child: Center(child: CircularProgressIndicator(color: _purple)),
              )
            else if (_error != null)
              _ErrorPanel(message: _error!, onRetry: _loadOrders)
            else if (filteredOrders.isEmpty)
              _EmptyPanel(filter: _filter)
            else
              ...filteredOrders.map(
                (order) => _AdminOrderCard(
                  order: order,
                  statuses: _statuses,
                  onStatusChanged: (status) => _updateStatus(order, status),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double value) {
    final text = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }
}

class _HeaderPanel extends StatelessWidget {
  final String adminName;
  final int totalOrders;
  final int activeOrders;

  const _HeaderPanel({
    required this.adminName,
    required this.totalOrders,
    required this.activeOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $adminName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$activeOrders pesanan aktif dari $totalOrders total pesanan',
                  style: const TextStyle(
                    color: Color(0xD9FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final int paidOrders;
  final int unpaidOrders;

  const _PaymentSummary({required this.paidOrders, required this.unpaidOrders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF6C63FF),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$paidOrders lunas, $unpaidOrders belum dibayar',
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final String selected;
  final List<String> statuses;
  final ValueChanged<String> onChanged;

  const _StatusFilter({
    required this.selected,
    required this.statuses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = selected == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onChanged(status),
              selectedColor: const Color(0xFF6C63FF),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade200,
                width: 0.5,
              ),
            ),
          );
        }).toList(),
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
    final phone = order.customerPhone.trim().isEmpty
        ? 'Belum ada nomor'
        : order.customerPhone.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderCode}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: 'Nomor pelanggan',
            value: phone,
            highlight: order.customerPhone.trim().isNotEmpty,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'User',
                  value: order.customerUsername ?? 'Guest',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(label: 'Tanggal', value: order.tanggal),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoPill(label: 'Layanan', value: order.layanan),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(label: 'Berat', value: '${order.berat} kg'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _PriceLine(
                  label: 'Subtotal',
                  value: _AdminScreenState._formatCurrency(order.subtotal),
                ),
                const SizedBox(height: 7),
                _PriceLine(
                  label: 'Diskon bulanan',
                  value: order.hasDiscount
                      ? '-${_AdminScreenState._formatCurrency(order.discount)}'
                      : _AdminScreenState._formatCurrency(0),
                  valueColor: order.hasDiscount
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade500,
                ),
                const Divider(height: 18, thickness: 0.5),
                _PriceLine(
                  label: 'Total tagihan',
                  value: _AdminScreenState._formatCurrency(order.total),
                  isTotal: true,
                ),
                const SizedBox(height: 8),
                _AmountBlock(label: 'Pembayaran', value: order.statusBayar),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: statuses.contains(order.status)
                ? order.status
                : statuses.first,
            decoration: InputDecoration(
              labelText: 'Update status pesanan',
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              prefixIcon: const Icon(
                Icons.sync_alt_outlined,
                size: 19,
                color: _purple,
              ),
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

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFF2E7D32) : Colors.grey.shade500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5E9) : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  final String label;
  final String value;

  const _AmountBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _PriceLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? const Color(0xFF1A1A2E) : Colors.grey.shade600,
              fontSize: isTotal ? 13 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color:
                valueColor ??
                (isTotal ? const Color(0xFF6C63FF) : const Color(0xFF1A1A2E)),
            fontSize: isTotal ? 15 : 12,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Menunggu' => const Color(0xFFEF8E28),
      'Dicuci' => const Color(0xFF1D6FB8),
      'Dijemur' => const Color(0xFFB7791F),
      'Selesai' => const Color(0xFF2E7D32),
      'Diantar' => const Color(0xFF6C63FF),
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String filter;

  const _EmptyPanel({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 46, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            filter == 'Semua'
                ? 'Belum ada pesanan'
                : 'Tidak ada pesanan $filter',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
