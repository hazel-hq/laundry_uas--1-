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
<<<<<<< HEAD
=======
  static const _green = Color(0xFF2E7D32);
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2

  final _statusOptions = const [
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

  @override
  void initState() {
    super.initState();
    _currentIdx = _statusIndex(widget.order.status);
  }

  int _statusIndex(String status) {
    final idx = _statusOptions.indexWhere(
      (s) => s.label.toLowerCase() == status.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  Future<void> _updateStatus(int idx) async {
    final nextStatus = _statusOptions[idx].label;
<<<<<<< HEAD
    setState(() => _saving = true);
=======
    setState(() {
      _saving = true;
      _savingIdx = idx;
    });
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2

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
<<<<<<< HEAD
    final current = _statusOptions[_currentIdx];
    final bool isAdmin = currentAppUser?.isAdmin ?? false;
=======
    final tracking = _trackingInfo(widget.order.status);
    final isAdmin = currentAppUser?.isAdmin ?? false;
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey.shade200, height: 0.5),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 52,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: _TrackingHeroCard(
                          serviceName: widget.order.layanan,
                          statusText: tracking.statusText,
                          progress: tracking.progress,
                          progressLabel: tracking.progressLabel,
                          estimateText: tracking.estimateText,
                          icon: tracking.icon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: _TimelineCard(steps: tracking.steps),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: isAdmin
                            ? _AdminStatusPanel(
                                saving: _saving,
                                savingIdx: _savingIdx,
                                currentIdx: _currentIdx,
                                statusOptions: _statusOptions,
                                onStatusTap: _updateStatus,
                              )
                            : const _TrackingInfoBanner(),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: const _TrackingInfoBanner(),
                        ),
                      ),
                    ],
<<<<<<< HEAD
                  ),
                  const SizedBox(height: 14),
                  Text(
                    current.desc,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIdx + 1) / _statusOptions.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Langkah ${_currentIdx + 1} dari ${_statusOptions.length}',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 11,
                    ),
                  ),
                ],
=======
                  ],
                ),
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2
              ),
            );
          },
        ),
      ),
    );
  }

  _TrackingInfo _trackingInfo(String status) {
    switch (status.toLowerCase()) {
      case 'dicuci':
        return _TrackingInfo(
          statusText: 'Sedang dicuci',
          progress: 0.45,
          estimateText: 'Hari ini',
          icon: Icons.local_laundry_service_outlined,
          steps: const [
            _TimelineStep('Pesanan dibuat', _TimelineState.done),
            _TimelineStep('Laundry menerima pesanan', _TimelineState.done),
            _TimelineStep('Sedang dicuci', _TimelineState.active),
            _TimelineStep('Sedang diproses', _TimelineState.pending),
            _TimelineStep('Siap diantar', _TimelineState.pending),
            _TimelineStep('Selesai', _TimelineState.pending),
          ],
        );
      case 'dijemur':
        return _TrackingInfo(
          statusText: 'Sedang dikeringkan',
          progress: 0.65,
          estimateText: 'Hari ini',
          icon: Icons.wb_sunny_outlined,
          steps: const [
            _TimelineStep('Pesanan dibuat', _TimelineState.done),
            _TimelineStep('Laundry menerima pesanan', _TimelineState.done),
            _TimelineStep('Sedang dicuci', _TimelineState.done),
            _TimelineStep('Sedang diproses', _TimelineState.active),
            _TimelineStep('Siap diantar', _TimelineState.pending),
            _TimelineStep('Selesai', _TimelineState.pending),
          ],
        );
      case 'diantar':
        return _TrackingInfo(
          statusText: 'Pesanan sedang diantar',
          progress: 1,
          estimateText: 'Hari ini',
          icon: Icons.delivery_dining_outlined,
          steps: const [
            _TimelineStep('Pesanan dibuat', _TimelineState.done),
            _TimelineStep('Laundry menerima pesanan', _TimelineState.done),
            _TimelineStep('Sedang dicuci', _TimelineState.done),
            _TimelineStep('Sedang diproses', _TimelineState.done),
            _TimelineStep('Siap diantar', _TimelineState.done),
            _TimelineStep('Selesai', _TimelineState.done),
          ],
        );
      case 'selesai':
        return _TrackingInfo(
          statusText: 'Selesai',
          progress: 1,
          estimateText: 'Selesai',
          icon: Icons.verified_rounded,
          steps: const [
            _TimelineStep('Pesanan dibuat', _TimelineState.done),
            _TimelineStep('Laundry menerima pesanan', _TimelineState.done),
            _TimelineStep('Sedang dicuci', _TimelineState.done),
            _TimelineStep('Sedang diproses', _TimelineState.done),
            _TimelineStep('Siap diantar', _TimelineState.done),
            _TimelineStep('Selesai', _TimelineState.done),
          ],
        );
      case 'menunggu':
      default:
        return _TrackingInfo(
          statusText: 'Laundry menerima pesanan',
          progress: 0.2,
          estimateText: 'Hari ini',
          icon: Icons.inventory_2_outlined,
          steps: const [
            _TimelineStep('Pesanan dibuat', _TimelineState.done),
            _TimelineStep('Laundry menerima pesanan', _TimelineState.active),
            _TimelineStep('Sedang dicuci', _TimelineState.pending),
            _TimelineStep('Sedang diproses', _TimelineState.pending),
            _TimelineStep('Siap diantar', _TimelineState.pending),
            _TimelineStep('Selesai', _TimelineState.pending),
          ],
        );
    }
  }
}

class _TrackingInfoBanner extends StatelessWidget {
  const _TrackingInfoBanner();

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

<<<<<<< HEAD
            // Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                children: List.generate(_statusOptions.length, (i) {
                  final done = i <= _currentIdx;
                  final isCurrent = i == _currentIdx;
                  final isLast = i == _statusOptions.length - 1;

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
                                        ? _purple
                                        : const Color(0xFFEEEDFE))
                                  : Colors.grey.shade100,
                              border: Border.all(
                                color: done ? _purple : Colors.grey.shade300,
                                width: isCurrent ? 2 : 0.5,
                              ),
                            ),
                            child: Center(
                              child: done
                                  ? Icon(
                                      isCurrent
                                          ? _statusOptions[i].icon
                                          : Icons.check,
                                      size: 14,
                                      color: isCurrent ? Colors.white : _purple,
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
                                _statusOptions[i].label,
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
                                _statusOptions[i].desc,
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
                              color: _purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
=======
class _TrackingHeroCard extends StatelessWidget {
  final String serviceName;
  final String statusText;
  final double progress;
  final String progressLabel;
  final String estimateText;
  final IconData icon;

  const _TrackingHeroCard({
    required this.serviceName,
    required this.statusText,
    required this.progress,
    required this.progressLabel,
    required this.estimateText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: _TrackingScreenState._purple, size: 38),
          ),
          const SizedBox(height: 20),
          Text(
            serviceName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _TrackingScreenState._darkText,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _TrackingScreenState._purple,
                fontSize: 13,
                fontWeight: FontWeight.w600,
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2
              ),
            ),
          ),
          const SizedBox(height: 26),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE7E3F3),
                  valueColor: const AlwaysStoppedAnimation(
                    _TrackingScreenState._purple,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progressLabel,
              style: const TextStyle(
                color: _TrackingScreenState._purple,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEDFE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  color: _TrackingScreenState._purple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimasi selesai',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estimateText,
                        style: const TextStyle(
                          color: _TrackingScreenState._darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _TimelineCard extends StatelessWidget {
  final List<_TimelineStep> steps;
  const _TimelineCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Status',
            style: TextStyle(
              color: _TrackingScreenState._darkText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _TimelineItem(step: step, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;
  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = step.state == _TimelineState.done;
    final isActive = step.state == _TimelineState.active;
    final isWaiting = step.state == _TimelineState.waiting;
    final color = isDone
        ? _TrackingScreenState._green
        : isActive
        ? _TrackingScreenState._purple
        : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFFE8F5E9)
                    : isActive
                    ? const Color(0xFFEEEDFE)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isActive ? color : Colors.grey.shade300,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: isActive
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _TrackingScreenState._purple,
                        ),
                      )
                    : Icon(
                        isDone
                            ? Icons.check_rounded
                            : isWaiting
                            ? Icons.hourglass_empty_rounded
                            : Icons.circle_outlined,
                        size: isDone ? 18 : 15,
                        color: color,
                      ),
              ),
            ),
            if (!isLast)
              Container(
<<<<<<< HEAD
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100, width: 0.5),
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
                      children: List.generate(_statusOptions.length, (i) {
                        final isActive = i == _currentIdx;
                        return GestureDetector(
                          onTap: _saving ? null : () => _updateStatus(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _purple
                                  : const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(10),
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
                                Icon(
                                  _statusOptions[i].icon,
                                  size: 14,
                                  color: isActive ? Colors.white : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _statusOptions[i].label,
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
                        );
                      }),
                    ),
                  ],
                ),
=======
                width: 2,
                height: 32,
                color: isDone ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 22),
            child: Text(
              step.label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminStatusPanel extends StatelessWidget {
  final bool saving;
  final int? savingIdx;
  final int currentIdx;
  final List<_StatusStep> statusOptions;
  final ValueChanged<int> onStatusTap;

  const _AdminStatusPanel({
    required this.saving,
    required this.savingIdx,
    required this.currentIdx,
    required this.statusOptions,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            children: List.generate(statusOptions.length, (i) {
              final isActive = i == currentIdx;
              final isSavingThis = saving && savingIdx == i;
              return GestureDetector(
                onTap: saving ? null : () => onStatusTap(i),
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
                      if (isSavingThis)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isActive ? Colors.white : Colors.grey,
                          ),
                        )
                      else
                        Icon(
                          statusOptions[i].icon,
                          size: 14,
                          color: isActive ? Colors.white : Colors.grey,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        statusOptions[i].label,
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
        ],
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
  final String label;
  final String value;

<<<<<<< HEAD
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
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
=======
class _TrackingInfo {
  final String statusText;
  final double progress;
  final String estimateText;
  final IconData icon;
  final List<_TimelineStep> steps;

  const _TrackingInfo({
    required this.statusText,
    required this.progress,
    required this.estimateText,
    required this.icon,
    required this.steps,
  });

  String get progressLabel => '${(progress * 100).round()}% selesai';
}

enum _TimelineState { done, active, waiting, pending }
>>>>>>> 0b32811590d068be413f2eda2fb4dda638e650d2
