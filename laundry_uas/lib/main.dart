import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SupabaseConfig.isConfigured
          ? const LoginScreen()
          : const _SupabaseConfigScreen(),
    );
  }
}

class _SupabaseConfigScreen extends StatelessWidget {
  const _SupabaseConfigScreen();

  static const _purple = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Supabase belum dikonfigurasi.\n\nIsi SUPABASE_URL dan SUPABASE_ANON_KEY saat menjalankan aplikasi, atau ubah nilainya di lib/supabase_config.dart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _purple,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
