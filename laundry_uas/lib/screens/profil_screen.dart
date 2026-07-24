import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/order_status_notification_service.dart';
import 'login_screen.dart';
import 'faq_screen.dart';

// ============================================================
// DESIGN TOKENS — konsisten dengan Home (ungu, radius, shadow)
// ============================================================
class _PT {
  static const purple = Color(0xFF6C63FF);
  static const purpleDark = Color(0xFF5A52E0);
  static const purpleContainer = Color(0xFFEEEDFE);
  static const bg = Color(0xFFF5F6FA);
  static const ink = Color(0xFF1A1A2E);

  static const rLg = 20.0;
  static const rMd = 16.0;
  static const rSm = 12.0;
  static const rPill = 999.0;

  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;

  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentAppUser;
    final isGuest = user == null;

    final userName = isGuest ? 'Pengguna' : user.fullName;

    return Scaffold(
      backgroundColor: _PT.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 88,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: _PT.purple,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(_PT.rLg),
              ),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Profil Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _ProfileHeaderCard(userName: userName, isGuest: isGuest),

                  if (isGuest) ...[
                    const SizedBox(height: _PT.s12),
                    _GuestPromptCard(
                      onRegister: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: _PT.s16),
                  _SectionLabel('Akun'),
                  const SizedBox(height: _PT.s8),
                  _SectionCard(
                    children: [
                      _MenuTile(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profil',
                        onTap: () => _comingSoon(context),
                      ),
                      const _MenuDivider(),
                      _MenuTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Riwayat Pesanan',
                        onTap: () {},
                      ),
                      const _MenuDivider(),
                      _MenuTile(
                        icon: Icons.map_outlined,
                        label: 'Tracking',
                        onTap: () => _comingSoon(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: _PT.s20),
                  _SectionLabel('Pusat Bantuan'),
                  const SizedBox(height: _PT.s8),
                  _SectionCard(
                    children: [
                      _MenuTile(
                        icon: Icons.quiz_outlined,
                        label: 'FAQ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FaqScreen(),
                            ),
                          );
                        },
                      ),
                      const _MenuDivider(),
                      _MenuTile(
                        icon: Icons.support_agent_outlined,
                        label: 'Hubungi Kami',
                        onTap: () => _showContactUs(context),
                      ),
                      const _MenuDivider(),
                      _MenuTile(
                        icon: Icons.info_outline,
                        label: 'Tentang Aplikasi',
                        onTap: () => _showAbout(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: _PT.s20),
                  _SectionLabel('Pengaturan'),
                  const SizedBox(height: _PT.s8),
                  _SectionCard(
                    children: [
                      _MenuTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        onTap: () => _comingSoon(context),
                      ),
                      const _MenuDivider(),
                      _MenuTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Kebijakan Privasi',
                        onTap: () => _comingSoon(context),
                      ),
                      const _MenuDivider(),
                      _MenuTile(
                        icon: Icons.description_outlined,
                        label: 'Syarat & Ketentuan',
                        onTap: () => _comingSoon(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: _PT.s20),
                  _SectionLabel('Info Laundry'),
                  const SizedBox(height: _PT.s8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(_PT.s16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_PT.rMd),
                      boxShadow: _PT.shadowSoft,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat',
                          value: 'Jl. Kost Mahasiswa No. 1',
                        ),
                        SizedBox(height: _PT.s16),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          label: 'WhatsApp',
                          value: '0857 2515 8604',
                        ),
                        SizedBox(height: _PT.s16),
                        _InfoTile(
                          icon: Icons.access_time_outlined,
                          label: 'Jam Operasional',
                          value: 'Senin - Sabtu, 09.00 - 18.00',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: _PT.s24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogout(context),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade500,
                        side: BorderSide(
                          color: Colors.red.shade200,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_PT.rSm),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: _PT.s12),
                  Text(
                    'FreshLaundry v1.0.0',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini akan segera hadir')),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_PT.rLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_PT.rSm),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_PT.rSm),
                  child: Image.asset(
                    'assets/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'FreshLaundry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Versi 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 10),
              Text(
                'Aplikasi laundry kiloan khusus mahasiswa kost. '
                'Mudah, cepat, dan terjangkau.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _DialogPrimaryButton(
                label: 'Tutup',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_PT.rLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _PT.purpleContainer,
                      borderRadius: BorderRadius.circular(_PT.rSm),
                    ),
                    child: const Icon(
                      Icons.support_agent_outlined,
                      color: _PT.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hubungi Kami',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _InfoTile(
                icon: Icons.phone_outlined,
                label: 'WhatsApp',
                value: '0857 2515 8604',
              ),
              const SizedBox(height: 14),
              const _InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Alamat',
                value: 'Jl. Kost Mahasiswa No. 1',
              ),
              const SizedBox(height: 20),
              _DialogPrimaryButton(
                label: 'Tutup',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_PT.rLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, color: Colors.red.shade400, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                'Keluar dari aplikasi?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu akan kembali ke halaman login.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_PT.rSm),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await orderStatusNotificationService.stop();
                        if (!context.mounted) return;
                        currentAppUser = null;

                        Navigator.pop(context);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_PT.rSm),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class _ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final bool isGuest;
  const _ProfileHeaderCard({required this.userName, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_PT.s20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_PT.rLg),
        boxShadow: _PT.shadowSoft,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_PT.purple, _PT.purpleDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: _PT.purple.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  color: _PT.purpleContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 36, color: _PT.purple),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _PT.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isGuest ? Colors.grey.shade100 : _PT.purpleContainer,
              borderRadius: BorderRadius.circular(_PT.rPill),
            ),
            child: Text(
              isGuest ? 'Guest' : 'Member',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isGuest ? Colors.grey.shade600 : _PT.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestPromptCard extends StatelessWidget {
  final VoidCallback onRegister;
  const _GuestPromptCard({required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_PT.s16),
      decoration: BoxDecoration(
        color: _PT.purpleContainer,
        borderRadius: BorderRadius.circular(_PT.rMd),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_PT.rSm),
            ),
            child: const Icon(Icons.lock_outline, color: _PT.purple, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Masuk untuk menyimpan pesanan dan mengakses semua fitur.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF4A419E),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: _PT.purple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_PT.rPill),
                ),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_PT.rMd),
        boxShadow: _PT.shadowSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _PT.purpleContainer,
                borderRadius: BorderRadius.circular(_PT.rSm),
              ),
              child: Icon(icon, size: 19, color: _PT.purple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _PT.ink,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: Colors.grey.shade100,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _PT.purpleContainer,
            borderRadius: BorderRadius.circular(_PT.rSm),
          ),
          child: Icon(icon, size: 17, color: _PT.purple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _PT.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DialogPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _PT.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_PT.rSm),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
