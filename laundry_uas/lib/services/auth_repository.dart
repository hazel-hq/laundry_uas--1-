import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AppUser?> signIn({
    required String email,
    required String username,
    required String password,
  }) async {
    final row = await _client
        .from('app_users')
        .select()
        .eq('email', email.trim().toLowerCase())
        .eq('username', username.trim())
        .eq('password', password)
        .maybeSingle();

    if (row == null) return null;
    return AppUser.fromSupabase(Map<String, dynamic>.from(row));
  }

  Future<AppUser> signUpCustomer({
    required String email,
    required String fullName,
    required String username,
    required String password,
  }) async {
    final row = await _client
        .from('app_users')
        .insert({
          'email': email.trim().toLowerCase(),
          'full_name': fullName.trim(),
          'username': username.trim(),
          'password': password,
          'role': 'customer',
        })
        .select()
        .single();

    return AppUser.fromSupabase(Map<String, dynamic>.from(row));
  }
}
