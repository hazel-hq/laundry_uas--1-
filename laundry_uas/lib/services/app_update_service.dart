import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  static const String appPackageName = 'com.ti24a4.freshlaundry';

  /// Memeriksa ketersediaan pembaruan dari Google Play Store secara otomatis
  Future<void> checkForPlayStoreUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          // Melakukan pembaruan langsung (Immediate Update)
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Melakukan pembaruan di latar belakang (Flexible Update)
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        } else {
          // Menampilkan dialog kustom jika Google Play UI tidak muncul
          if (context.mounted) {
            _showUpdateDialog(context);
          }
        }
      }
    } catch (e) {
      debugPrint('Pengecekan update Google Play: $e');
    }
  }

  /// Membuka halaman aplikasi di Google Play Store
  Future<void> openPlayStore() async {
    final playStoreUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=$appPackageName',
    );
    final marketUrl = Uri.parse('market://details?id=$appPackageName');

    try {
      if (await canLaunchUrl(marketUrl)) {
        await launchUrl(marketUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(playStoreUrl)) {
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Gagal membuka Play Store: $e');
    }
  }

  /// Dialog pembaruan interaktif jika update tersedia
  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.system_update_sharp,
                color: Color(0xFF6C63FF),
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'Update Tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          content: const Text(
            'Versi baru aplikasi FreshLaundry telah tersedia di Google Play Store dengan fitur dan perbaikan terbaru.',
            style: TextStyle(fontSize: 13.5, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Nanti Saja',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openPlayStore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Update Sekarang'),
            ),
          ],
        );
      },
    );
  }
}
