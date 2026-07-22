import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/order.dart';
import '../models/order_data.dart';

class TrackingScreen extends StatefulWidget {
  final Order order;

  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const _purple = Color(0xFF6C63FF);
  static const _darkText = Color(0xFF1A1A2E);

  static const _statusOptions = [
    _StatusStep(
      label: 'Menunggu',
      desc: 'Pesanan diterima, menunggu diproses',
      icon: Icons.inbox_outlined,
    ),
    _StatusStep(
      label: 'Dicuci',
      desc: 'Pakaian sedang dicuci',
      icon: Icons.water_drop_outlined,
    ),
    _StatusStep(
      label: 'Dijemur',
      desc: 'Pakaian sedang dijemur / dikeringkan',
      icon: Icons.wb_sunny_outlined,
    ),
    _StatusStep(
      label: 'Selesai',
      desc: 'Pakaian siap diambil',
      icon: Icons.check_circle_outline,
    ),
    _StatusStep(
      label: 'Diantar',
      desc: 'Pesanan sedang diantar ke kost',
      icon: Icons.delivery_dining_outlined,
    ),
  ];

  late int _currentIdx;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentIdx = _statusIndex(widget.order.status);
  }

  int _statusIndex(String status) {
    final idx = _statusOptions.indexWhere(
      (item) => item.label.toLowerCase() == status.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  Future<void> _updateStatus(int idx) async {
    final nextStatus = _statusOptions[idx].label;
    setState(() => _saving = true);

    try {
      await orderRepository.updateStatus(widget.order.id, nextStatus);
      await refreshOrders();

      final i = orderList.indexWhere((order) => order.id == widget.order.id);
      if (i != -1) orderList[i].status = nextStatus;

      if (!mounted) return;
      setState(() {
        _currentIdx = idx;
        widget.order.status = nextStatus;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diubah ke "$nextStatus"'),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _statusOptions[_currentIdx];
    final bool isAdmin = currentAppUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Tracking pesanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CurrentStatusCard(
                current: current,
                currentIdx: _currentIdx,
                totalStatus: _statusOptions.length,
              ),
              const SizedBox(height: 12),
              _OrderInfoCard(order: widget.order),
              const SizedBox(height: 20),
              const Text(
                'Riwayat status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _TimelineCard(
                statuses: _statusOptions,
                currentIdx: _currentIdx,
              ),
              const SizedBox(height: 20),
              if (!isAdmin) ...[
                _CustomerInfoBanner(),
                const SizedBox(height: 20),
              ],
              if (isAdmin)
                _AdminStatusPanel(
                  statuses: _statusOptions,
                  currentIdx: _currentIdx,
                  saving: _saving,
                  onSelect: _updateStatus,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  final _StatusStep current;
  final int currentIdx;
  final int totalStatus;

  const _CurrentStatusCard({
    required this.current,
    required this.currentIdx,
    required this.totalStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _TrackingScreenState._purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(current.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status saat ini',
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      current.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            current.desc,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentIdx + 1) / totalStatus,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Langkah ${currentIdx + 1} dari $totalStatus',
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final Order order;

  const _OrderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(child: _MiniInfo(label: 'Pelanggan', value: order.nama)),
          _DividerLine(),
          Expanded(child: _MiniInfo(label: 'Layanan', value: order.layanan)),
          _DividerLine(),
          Expanded(child: _MiniInfo(label: 'Berat', value: '${order.berat} kg')),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<_StatusStep> statuses;
  final int currentIdx;

  const _TimelineCard({required this.statuses, required this.currentIdx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        children: List.generate(statuses.length, (i) {
          final done = i <= currentIdx;
          final isCurrent = i == currentIdx;
          final isLast = i == statuses.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? (isCurrent
                                ? _TrackingScreenState._purple
                                : const Color(0xFFEEEDFE))
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: done
                            ? _TrackingScreenState._purple
                            : Colors.grey.shade300,
                        width: isCurrent ? 2 : 0.5,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? Icon(
                              isCurrent ? statuses[i].icon : Icons.check,
                              size: 14,
                              color: isCurrent
                                  ? Colors.white
                                  : _TrackingScreenState._purple,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      decoration: BoxDecoration(
                        color: i < currentIdx
                            ? const Color(0xFFEEEDFE)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statuses[i].label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: done
                              ? _TrackingScreenState._darkText
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statuses[i].desc,
                        style: TextStyle(
                          fontSize: 11,
                          color: done
                              ? Colors.grey.shade500
                              : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Sekarang',
                    style: TextStyle(
                      fontSize: 10,
                      color: _TrackingScreenState._purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _CustomerInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _TrackingScreenState._purple, width: 0.5),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _TrackingScreenState._purple,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Status pesanan diperbarui oleh admin laundry.',
              style: TextStyle(
                color: Color(0xFF3C3489),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatusPanel extends StatelessWidget {
  final List<_StatusStep> statuses;
  final int currentIdx;
  final bool saving;
  final ValueChanged<int> onSelect;

  const _AdminStatusPanel({
    required this.statuses,
    required this.currentIdx,
    required this.saving,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 18,
                color: Color(0xFF854F0B),
              ),
              SizedBox(width: 8),
              Text(
                'Update status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(statuses.length, (i) {
              final isActive = i == currentIdx;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: saving ? null : () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _TrackingScreenState._purple
                        : const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? _TrackingScreenState._purple
                          : Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statuses[i].icon,
                        size: 14,
                        color: isActive ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statuses[i].label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (saving) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 36, color: Colors.grey.shade200);
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: _TrackingScreenState._darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusStep {
  final String label;
  final String desc;
  final IconData icon;

  const _StatusStep({
    required this.label,
    required this.desc,
    required this.icon,
  });
}
