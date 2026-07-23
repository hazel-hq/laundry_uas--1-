import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../models/order_data.dart';
import 'history_screen.dart';
import 'order_screen.dart';
import 'profil_screen.dart';
import 'tracking_list_screen.dart';
import 'login_required_dialog.dart';
import 'notification_sheet.dart';
import '../services/in_app_notification_service.dart';

// ============================================================
// DESIGN TOKENS
// Sistem token kecil supaya radius, warna, dan spacing konsisten
// di seluruh Home screen. Tidak mengubah business logic apa pun.
// ============================================================
class _T {
  // Warna
  static const purple = Color(0xFF6C63FF);
  static const purpleDark = Color(0xFF5A52E0);
  static const purpleContainer = Color(0xFFEEEDFE);
  static const bg = Color(0xFFF5F6FA);
  static const ink = Color(0xFF1A1A2E);

  // Radius
  static const rXl = 28.0; // header card
  static const rLg = 20.0; // card besar (promo, cta, order list)
  static const rMd = 16.0; // service card, tips card
  static const rSm = 12.0; // icon container
  static const rPill = 999.0; // badge/status/pill

  // Spacing (grid 4pt)
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;

  // Shadow ala MD3 elevation level 1-2 (lembut, tidak berat)
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowPurple = [
    BoxShadow(
      color: purple.withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_tab),
          child: switch (_tab) {
            0 => _HomeTab(
              loading: _loading,
              error: _error,
              onRefresh: _loadOrders,
              onViewAll: () => setState(() => _tab = 1),
            ),
            1 => HistoryScreen(onChanged: _loadOrders),
            2 => TrackingListScreen(onChanged: _loadOrders),
            3 => const ProfileScreen(),
            _ => const SizedBox(),
          },
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          backgroundColor: Colors.white,
          indicatorColor: _T.purpleContainer,
          elevation: 0,
          height: 66,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? _T.purple : Colors.grey.shade500,
            );
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: _T.purple),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: _T.purple),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map, color: _T.purple),
              label: 'Tracking',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: _T.purple),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onViewAll;

  const _HomeTab({
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onViewAll,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = currentAppUser;
    final isGuest = user == null;

    final userName = isGuest ? 'Guest' : user.username;

    final aktif = isGuest
        ? 0
        : orderList
              .where((o) => o.status != 'Selesai' && o.status != 'Diantar')
              .length;
    return SafeArea(
      child: RefreshIndicator(
        color: _T.purple,
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(_T.s16, _T.s16, _T.s16, _T.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                greeting: _greeting(),
                userName: userName,
                loading: loading,
                totalOrders: isGuest ? 0 : orderList.length,
                activeOrders: aktif,
              ),
              if (error != null) ...[
                const SizedBox(height: _T.s12),
                _ErrorBox(message: error!, onRetry: onRefresh),
              ],
              const SizedBox(height: _T.s16),
              const _MonthlySubscriptionBanner(),
              const SizedBox(height: _T.s20),
              _OrderCta(onRefresh: onRefresh),
              const SizedBox(height: _T.s24),
              const _SectionTitle('Layanan kami'),
              const SizedBox(height: _T.s12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: _T.s12,
                mainAxisSpacing: _T.s12,
                childAspectRatio: 2.5,
                children: const [
                  _ServiceCard(
                    icon: Icons.water_drop_outlined,
                    label: 'Cuci',
                    price: 'Rp 5.000/kg',
                    color: Color(0xFF185FA5),
                  ),
                  _ServiceCard(
                    icon: Icons.iron_outlined,
                    label: 'Setrika',
                    price: 'Rp 4.000/kg',
                    color: Color(0xFF3B6D11),
                  ),
                  _ServiceCard(
                    icon: Icons.bolt_outlined,
                    label: 'Ekspres',
                    price: 'Rp 8.000/kg',
                    color: Color(0xFF993C1D),
                  ),
                  _ServiceCard(
                    icon: Icons.dry_cleaning_outlined,
                    label: 'Cuci+Setrika',
                    price: 'Rp 8.500/kg',
                    color: Color(0xFF993556),
                  ),
                ],
              ),
              const SizedBox(height: _T.s24),
              if (!isGuest && orderList.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle('Pesanan Terbaru'),
                    TextButton(
                      onPressed: onViewAll,
                      style: TextButton.styleFrom(
                        foregroundColor: _T.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _T.s8),
                ...orderList.reversed
                    .take(2)
                    .map((order) => _LatestOrderCard(order: order)),
                const SizedBox(height: _T.s8),
              ],
              const _TipsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Judul section dengan style konsisten (dulu ditulis ulang di 2 tempat berbeda)
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _T.ink,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Widget dekoratif gelembung laundry transparan bergradien di latar belakang kartu
class _BubbleDecoration extends StatelessWidget {
  final double borderRadius;
  const _BubbleDecoration({this.borderRadius = _T.rXl});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Gelembung kanan atas
            Positioned(
              right: -25,
              top: -25,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Gelembung kanan bawah
            Positioned(
              right: 65,
              bottom: -35,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            // Gelembung kiri bawah
            Positioned(
              left: -18,
              bottom: -18,
              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            // Gelembung kecil atas
            Positioned(
              left: 140,
              top: -12,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String greeting;
  final String userName;
  final bool loading;
  final int totalOrders;
  final int activeOrders;

  const _HeaderCard({
    required this.greeting,
    required this.userName,
    required this.loading,
    required this.totalOrders,
    required this.activeOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_T.purple, _T.purpleDark],
        ),
        borderRadius: BorderRadius.circular(_T.rXl),
        boxShadow: _T.shadowPurple,
      ),
      child: Stack(
        children: [
          const _BubbleDecoration(borderRadius: _T.rXl),
          Padding(
            padding: const EdgeInsets.all(_T.s20),
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
                            greeting,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _T.s4),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: _T.s12),
                    const _NotificationButton(),
                  ],
                ),
                const SizedBox(height: _T.s20),
                if (loading)
                  Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: _T.s8),
                      Text(
                        'Memuat pesanan...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      _StatPill(
                        label: '$totalOrders pesanan',
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(width: _T.s8),
                      _StatPill(
                        label: '$activeOrders aktif',
                        icon: Icons.local_laundry_service_outlined,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: inAppNotificationService,
      builder: (context, _) {
        final unreadCount = inAppNotificationService.unreadCount;

        return IconButton(
          onPressed: () {
            inAppNotificationService.markAllAsRead();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const NotificationSheet(),
            );
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            fixedSize: const Size(42, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_T.rSm),
            ),
          ),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4757),
                      shape: BoxShape.circle,
                      border: Border.all(color: _T.purple, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlySubscriptionBanner extends StatelessWidget {
  const _MonthlySubscriptionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_T.s12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF8F1),
        borderRadius: BorderRadius.circular(_T.rMd),
        boxShadow: _T.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFCFEED8),
              borderRadius: BorderRadius.circular(_T.rSm),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFF207A3D),
              size: 20,
            ),
          ),
          const SizedBox(width: _T.s12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langganan Bulanan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Diskon otomatis 10% setelah 5 pesanan bulan ini',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF39734A)),
                ),
              ],
            ),
          ),
          const SizedBox(width: _T.s8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E9B4E),
              borderRadius: BorderRadius.circular(_T.rPill),
            ),
            child: const Text(
              'Otomatis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCta extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _OrderCta({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_T.rLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(_T.rLg),
        onTap: () async {
          if (currentAppUser == null) {
            await showLoginRequiredDialog(context);
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderScreen()),
          );

          await onRefresh();
        },
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _T.purple,
            borderRadius: BorderRadius.circular(_T.rLg),
            boxShadow: _T.shadowPurple,
          ),
          child: Stack(
            children: [
              const _BubbleDecoration(borderRadius: _T.rLg),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Pesanan Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Cuci, setrika, atau ekspres',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(_T.rSm),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestOrderCard extends StatelessWidget {
  final Order order;
  const _LatestOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDone = order.status == 'Selesai';
    final statusBg = isDone ? const Color(0xFFE3F2D6) : const Color(0xFFFFF1D6);
    final statusFg = isDone ? const Color(0xFF2E5A0E) : const Color(0xFF854F0B);

    return Container(
      margin: const EdgeInsets.only(bottom: _T.s8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_T.rMd),
        boxShadow: _T.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _T.purpleContainer,
              borderRadius: BorderRadius.circular(_T.rSm),
            ),
            child: const Icon(
              Icons.local_laundry_service_outlined,
              color: _T.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: _T.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _T.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.layanan} · ${order.berat} kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  order.tanggal,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(width: _T.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _T.purple,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(_T.rPill),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _T.purpleContainer,
        borderRadius: BorderRadius.circular(_T.rMd),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: _T.purple, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pesanan ekspres selesai dalam 4 jam. Cocok untuk kebutuhan mendesak!',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF4A419E),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(_T.rMd),
        border: Border.all(color: Colors.red.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gagal memuat data Supabase',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(fontSize: 11.5, color: Colors.red.shade400),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: _T.s8),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_T.rSm),
                ),
              ),
              child: const Text('Coba lagi', style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(_T.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final Color color;

  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_T.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_T.rMd),
        boxShadow: _T.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(_T.rSm),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: _T.s12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _T.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
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
