import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../profile/repositories/profile_repository.dart';

enum AppAuthStatus {
  unknown,
  unauthenticated,
  onboardingPending,
  ready,
}

final authStateProvider =
    StreamProvider<AuthState>((ref) => supabase.auth.onAuthStateChange);

final currentUserProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

/// Listenable that notifies GoRouter when auth state changes.
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;
  final ProfileRepository _profileRepo = ProfileRepository();

  AppAuthStatus _status = AppAuthStatus.unknown;
  AppAuthStatus get status => _status;

  bool _initialized = false;
  bool _suppressAuthEvents = false;

  void suppressAuthEvents() => _suppressAuthEvents = true;
  void resumeAuthEvents() => _suppressAuthEvents = false;

  AuthNotifier() {
    _sub = supabase.auth.onAuthStateChange.listen((authState) {
      _onAuthEvent(authState);
    });
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final session = supabase.auth.currentSession;
    if (session != null) {
      await _resolveStatus(session.user.id);
    } else {
      _status = AppAuthStatus.unauthenticated;
      notifyListeners();
    }
    _initialized = true;
  }

  Future<void> _onAuthEvent(AuthState authState) async {
    if (!_initialized) return;
    if (_suppressAuthEvents) return;
    final session = authState.session;

    if (session == null) {
      _status = AppAuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    await _resolveStatus(session.user.id);
  }

  Future<void> _resolveStatus(String userId) async {
    try {
      final profile = await _profileRepo.ensureProfile(userId);
      _status = profile.onboardingCompleted
          ? AppAuthStatus.ready
          : AppAuthStatus.onboardingPending;
    } catch (_) {
      // Fallback to ready to avoid blocking users
      _status = AppAuthStatus.ready;
    }
    notifyListeners();
  }

  /// Called after onboarding completion to re-evaluate status.
  Future<void> refresh() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _status = AppAuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await _resolveStatus(user.id);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
