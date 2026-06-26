import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/order_data.dart';
import '../theme/app_theme.dart';
import 'order_screen.dart';
import 'tracking_screen.dart';

class TrackingListScreen extends StatefulWidget {
  final Future<void> Function()? onChanged;
  const TrackingListScreen({super.key, this.onChanged});

  @override
  State<TrackingListScreen> createState() => _TrackingListScreenState();
}

class _TrackingListScreenState extends State<TrackingListScreen> {
  static const _purple = AppTheme.purple;
  static const _activeStatuses = ['Menunggu', 'Dicuci', 'Dijemur', 'Diantar'];
  static const _statusFlow = [
    'Menunggu',
    'Dicuci',
    'Dijemur',
    'Selesai',
    'Diantar',
  ];

  bool _loading = true;
  String? _error;

  List<Order> get _activeOrders =>
      orderList.where((o) => _activeStatuses.contains(o.status)).toList();

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
      if (widget.onChanged != null) await widget.onChanged!();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diantar':
        return const Color(0xFF1565C0);
      case 'menunggu':
        return const Color(0xFF888780);
      default:
        return const Color(0xFFE65100);
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'diantar':
        return const Color(0xFFE3F2FD);
      case 'menunggu':
        return const Color(0xFFF1EFE8);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  int _statusIndex(String status) {
    final idx = _statusFlow.indexWhere(
      (s) => s.toLowerCase() == status.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _activeOrders.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: _purple,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: _purple,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pesanan berlangsung',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$activeCount pesanan aktif',
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: _purple)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 48,
                          color: Colors.red.shade200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat pesanan aktif',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadOrders,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_activeOrders.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_laundry_service_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada pesanan yang sedang berlangsung',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderScreen(),
                              ),
                            );
                            await _loadOrders();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Buat pesanan baru'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final order = _activeOrders[i];
                    return _TrackingOrderCard(
                      order: order,
                      statusIndex: _statusIndex(order.status),
                      totalSteps: _statusFlow.length,
                      statusBg: _statusBg(order.status),
                      statusColor: _statusColor(order.status),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackingScreen(order: order),
                          ),
                        );
                        await _loadOrders();
                      },
                    );
                  }, childCount: _activeOrders.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackingOrderCard extends StatelessWidget {
  final Order order;
  final int statusIndex;
  final int totalSteps;
  final Color statusBg;
  final Color statusColor;
  final VoidCallback onTap;

  const _TrackingOrderCard({
    required this.order,
    required this.statusIndex,
    required this.totalSteps,
    required this.statusBg,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (statusIndex + 1) / totalSteps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.grey.shade100, width: 0.5),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.orderCode}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Meta(label: 'Layanan', value: order.layanan),
                    const SizedBox(width: 14),
                    _Meta(label: 'Berat', value: '${order.berat} kg'),
                    const Spacer(),
                    Text(
                      'Langkah ${statusIndex + 1} dari $totalSteps',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEEEDFE),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.purple),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
