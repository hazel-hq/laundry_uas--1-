import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../models/order_data.dart';
import '../theme/app_theme.dart';

class TrackingScreen extends StatefulWidget {
  final Order order;
  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const _purple = AppTheme.purple;

  final _allStatus = const [
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

  int _currentIdx = 0;
  bool _saving = false;
  int? _savingIdx;

  @override
  void initState() {
    super.initState();
    _currentIdx = _statusIndex(widget.order.status);
  }

  int _statusIndex(String status) {
    final idx = _allStatus.indexWhere(
      (s) => s.label.toLowerCase() == status.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  Future<void> _updateStatus(int idx) async {
    final nextStatus = _allStatus[idx].label;
    HapticFeedback.lightImpact();
    setState(() {
      _saving = true;
      _savingIdx = idx;
    });

    try {
      await orderRepository.updateStatus(widget.order.id, nextStatus);
      await refreshOrders();

      final i = orderList.indexWhere((o) => o.id == widget.order.id);
      if (i != -1) orderList[i].status = nextStatus;

      if (!mounted) return;
      setState(() {
        _currentIdx = idx;
        widget.order.status = nextStatus;
        _saving = false;
        _savingIdx = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Status diubah ke "$nextStatus"')),
            ],
          ),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _savingIdx = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _allStatus[_currentIdx];
    final bool isAdmin = currentAppUser?.isAdmin ?? false;
    final remainingStep = (_allStatus.length - 1 - _currentIdx).clamp(0, 4);
    final estimateText = remainingStep == 0
        ? 'Estimasi selesai: siap diambil'
        : 'Estimasi selesai: ${remainingStep * 2} jam lagi';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Tracking pesanan',
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
            // Status sekarang
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.purple, AppTheme.purpleDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: AppTheme.softShadow,
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
                        child: Icon(
                          current.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status saat ini',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12,
                            ),
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
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    current.desc,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    estimateText,
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: (_currentIdx + 1) / _allStatus.length),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Langkah ${_currentIdx + 1} dari ${_allStatus.length}',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info ringkas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      label: 'Pelanggan',
                      value: widget.order.nama,
                    ),
                  ),
                  Container(
                    width: 0.5,
                    height: 36,
                    color: Colors.grey.shade200,
                  ),
                  Expanded(
                    child: _MiniInfo(
                      label: 'Layanan',
                      value: widget.order.layanan,
                    ),
                  ),
                  Container(
                    width: 0.5,
                    height: 36,
                    color: Colors.grey.shade200,
                  ),
                  Expanded(
                    child: _MiniInfo(
                      label: 'Berat',
                      value: '${widget.order.berat} kg',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Riwayat status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: List.generate(_allStatus.length, (i) {
                  final done = i <= _currentIdx;
                  final isCurrent = i == _currentIdx;
                  final isLast = i == _allStatus.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(end: isCurrent ? 1 : 0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            builder: (context, pulse, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? (isCurrent
                                            ? _purple
                                            : const Color(0xFFEEEDFE))
                                      : Colors.grey.shade100,
                                  border: Border.all(
                                    color: done
                                        ? _purple
                                        : Colors.grey.shade300,
                                    width: isCurrent ? 2 : 0.5,
                                  ),
                                  boxShadow: isCurrent
                                      ? [
                                          BoxShadow(
                                            color: _purple.withValues(
                                              alpha: 0.18 + (pulse * 0.12),
                                            ),
                                            blurRadius: 12 + (pulse * 6),
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: done
                                      ? Icon(
                                          isCurrent
                                              ? _allStatus[i].icon
                                              : Icons.check,
                                          size: 14,
                                          color: isCurrent
                                              ? Colors.white
                                              : _purple,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              decoration: BoxDecoration(
                                color: i < _currentIdx
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
                          padding: EdgeInsets.only(
                            top: 4,
                            bottom: isLast ? 0 : 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _allStatus[i].label,
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
                              const SizedBox(height: 2),
                              Text(
                                _allStatus[i].desc,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: done
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                i <= _currentIdx
                                    ? (i == 0
                                          ? widget.order.tanggal
                                          : 'Diperbarui oleh admin')
                                    : 'Menunggu pembaruan',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: done
                                      ? Colors.grey.shade400
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
                              color: _purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            if (!isAdmin) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: const Color(0xFF6C63FF),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF6C63FF),
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
              ),
              const SizedBox(height: 20),
            ],

            // Panel update status (admin only)
            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: Colors.grey.shade100, width: 0.5),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAEEDA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 13,
                                color: Color(0xFF854F0B),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF854F0B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Update status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_allStatus.length, (i) {
                        final isActive = i == _currentIdx;
                        return GestureDetector(
                          onTap: _saving ? null : () => _updateStatus(i),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: _saving && _savingIdx != i ? 0.45 : 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? _purple
                                    : const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                                border: Border.all(
                                  color: isActive
                                      ? _purple
                                      : Colors.grey.shade200,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_savingIdx == i)
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              isActive ? Colors.white : _purple,
                                            ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      _allStatus[i].icon,
                                      size: 14,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _allStatus[i].label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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

class _StatusStep {
  final String label, desc;
  final IconData icon;
  const _StatusStep({
    required this.label,
    required this.desc,
    required this.icon,
  });
}

class _MiniInfo extends StatelessWidget {
  final String label, value;
  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1a1a2e),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
