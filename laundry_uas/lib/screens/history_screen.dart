import 'package:flutter/material.dart';
import '../models/order_data.dart';
import 'order_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final Future<void> Function()? onChanged;
  const HistoryScreen({super.key, this.onChanged});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Semua';
  final _filters = ['Semua', 'Proses', 'Selesai', 'Diantar'];
  bool _loading = true;
  String? _error;

  static const _purple = Color(0xFF6C63FF);

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
      case 'selesai':
        return const Color(0xFF2E7D32);
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
      case 'selesai':
        return const Color(0xFFE8F5E9);
      case 'diantar':
        return const Color(0xFFE3F2FD);
      case 'menunggu':
        return const Color(0xFFF1EFE8);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  List get _filtered {
    if (_filter == 'Semua') return orderList;
    if (_filter == 'Proses') {
      return orderList
          .where(
            (o) =>
                o.status.toLowerCase() != 'selesai' &&
                o.status.toLowerCase() != 'diantar',
          )
          .toList();
    }
    return orderList
        .where((o) => o.status.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selesai = orderList
        .where((o) => o.status.toLowerCase() == 'selesai')
        .length;
    final proses = orderList
        .where(
          (o) =>
              o.status.toLowerCase() != 'selesai' &&
              o.status.toLowerCase() != 'diantar',
        )
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // App bar
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
                    'Riwayat pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$proses pesanan aktif',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Summary
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      _SummaryCard(
                        label: 'Total',
                        value: '${orderList.length}',
                        color: const Color(0xFF1a1a2e),
                      ),
                      const SizedBox(width: 8),
                      _SummaryCard(
                        label: 'Selesai',
                        value: '$selesai',
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      _SummaryCard(
                        label: 'Proses',
                        value: '$proses',
                        color: const Color(0xFFE65100),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _filters.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final active = _filter == _filters[i];
                      return GestureDetector(
                        onTap: () => setState(() => _filter = _filters[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: active ? _purple : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? _purple : Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontSize: 12,
                              color: active ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // List atau empty state
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
                        'Gagal memuat data Supabase',
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
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada pesanan',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final order = _filtered[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade100,
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris atas: ID + badge status
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
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1a1a2e),
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
                                  color: _statusBg(order.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _statusColor(order.status),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 18, thickness: 0.5),

                          Row(
                            children: [
                              _MetaItem(label: 'Layanan', value: order.layanan),
                              const SizedBox(width: 16),
                              _MetaItem(
                                label: 'Berat',
                                value: '${order.berat} kg',
                              ),
                              const SizedBox(width: 16),
                              _MetaItem(label: 'Tanggal', value: order.tanggal),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${order.total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: _purple,
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailScreen(order: order),
                                    ),
                                  );
                                  await _loadOrders();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _purple,
                                  side: const BorderSide(
                                    color: _purple,
                                    width: 0.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Lihat detail',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _filtered.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label, value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1a1a2e),
          ),
        ),
      ],
    );
  }
}
