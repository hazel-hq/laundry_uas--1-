import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_repository.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _authRepository = AuthRepository();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static const _purple = Color(0xFF6C63FF);

  Future<void> _register() async {
    final email = _email.text.trim();

    if (email.isEmpty ||
        _name.text.trim().isEmpty ||
        _username.text.trim().isEmpty ||
        _password.text.length < 6) {
      setState(
        () => _error =
            'Email, nama, username, dan password minimal 6 karakter wajib diisi',
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Format email belum valid');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _authRepository.signUpCustomer(
        email: email,
        fullName: _name.text,
        username: _username.text,
        password: _password.text,
      );

      currentAppUser = user;
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal daftar. Email atau username mungkin sudah dipakai.';
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Daftar pelanggan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat akun pelanggan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 18),
              _buildField(
                controller: _email,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _name,
                label: 'Nama lengkap',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _username,
                label: 'Username',
                icon: Icons.person_outline,
                autofillHints: const [AutofillHints.username],
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscure,
                autofillHints: const [AutofillHints.newPassword],
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_loading ? 'Mendaftarkan...' : 'Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _purple, width: 1),
        ),
      ),
    );
  }
}
