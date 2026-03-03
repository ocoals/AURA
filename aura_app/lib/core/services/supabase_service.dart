import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트 접근 헬퍼.
final supabase = Supabase.instance.client;

/// Edge Function 헬스체크.
Future<Map<String, dynamic>> checkHealth() async {
  final response = await supabase.functions.invoke('health');
  return response.data as Map<String, dynamic>;
}
