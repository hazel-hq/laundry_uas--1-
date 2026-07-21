import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

Future<void> showLoginRequiredDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF6C63FF)),
            SizedBox(width: 8),
            Text("Login Diperlukan"),
          ],
        ),
        content: const Text(
          "Silakan login terlebih dahulu untuk mengakses fitur ini.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      );
    },
  );
}
