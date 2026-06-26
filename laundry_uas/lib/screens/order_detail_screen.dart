import 'package:flutter/material.dart';
import '../models/order.dart';
import 'tracking_screen.dart';
import 'payment_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  static const _purple = Color(0xFF6C63FF);

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

  final _allStatus = const [
    'Menunggu',
    'Dicuci',
    'Dijemur',
    'Selesai',
    'Diantar',
  ];

  int _statusIndex(String status) {
    final idx = _allStatus.indexWhere(
      (s) => s.toLowerCase() == status.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _statusIndex(order.status);
    final isCompleted = order.status.toLowerCase() == 'selesai';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Detail pesanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey.shade200, height: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#LDR-${order.id.length >= 6 ? order.id.substring(order.id.length - 6) : order.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg(order.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.tanggal,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info pesanan
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Info pesanan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(label: 'Layanan', value: order.layanan),
                  _InfoRow(label: 'Berat', value: '${order.berat} kg'),
                  _InfoRow(
                    label: 'Harga satuan',
                    value:
                        'Rp ${(order.total / order.berat).toStringAsFixed(0)}/kg',
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rp ${order.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tombol lacak pesanan
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackingScreen(order: order),
                    ),
                  ),
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text(
                    'Lacak pesanan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E7D32),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF2E7D32),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pesanan selesai',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Timeline status
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status pesanan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_allStatus.length, (i) {
                    final done = i <= currentIdx;
                    final isCurrent = i == currentIdx;
                    final isLast = i == _allStatus.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done ? _purple : Colors.grey.shade200,
                                border: Border.all(
                                  color: done ? _purple : Colors.grey.shade300,
                                  width: 0.5,
                                ),
                              ),
                              child: done
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 36,
                                color: i < currentIdx
                                    ? _purple
                                    : Colors.grey.shade200,
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _allStatus[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: done
                                      ? const Color(0xFF1a1a2e)
                                      : Colors.grey.shade400,
                                ),
                              ),
                              if (isCurrent)
                                Text(
                                  'Sedang diproses',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              SizedBox(height: isLast ? 0 : 20),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Pembayaran
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(label: 'Metode', value: 'QRIS / COD'),
                  _InfoRow(label: 'Status', value: order.statusBayar),
                  if (order.statusBayar == 'Belum dibayar') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(order: order),
                          ),
                        ),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text(
                          'Bayar sekarang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Sudah lunas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1a1a2e),
            ),
          ),
        ],
      ),
    );
  }
}
