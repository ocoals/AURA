import '../../../core/services/supabase_service.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  Future<Profile?> fetchProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Profile.fromJson(response);
  }

  Future<Profile> ensureProfile(String userId) async {
    final existing = await fetchProfile(userId);
    if (existing != null) return existing;

    final now = DateTime.now().toIso8601String();
    await supabase.from('profiles').upsert({
      'id': userId,
      'onboarding_completed': false,
      'created_at': now,
      'updated_at': now,
    });

    final profile = await fetchProfile(userId);
    return profile!;
  }

  Future<void> updateOnboardingCompleted(String userId) async {
    await supabase.from('profiles').update({
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> updateProfile(
      String userId, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    await supabase.from('profiles').update(data).eq('id', userId);
  }
}
