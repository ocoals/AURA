import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final currentProfileProvider =
    AsyncNotifierProvider<CurrentProfileNotifier, Profile?>(
  CurrentProfileNotifier.new,
);

class CurrentProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.session?.user;
    if (user == null) return null;

    final repo = ref.read(profileRepositoryProvider);
    return repo.ensureProfile(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final onboardingCompletedProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).valueOrNull;
  return profile?.onboardingCompleted ?? false;
});
