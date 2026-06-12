import 'package:flutter_test/flutter_test.dart';

import 'package:laundry_app/supabase_config.dart';

void main() {
  test('Supabase configuration is filled', () {
    expect(SupabaseConfig.isConfigured, isTrue);
    expect(SupabaseConfig.url, 'https://qikapsvunnhnyvqvckxl.supabase.co');
  });
}
