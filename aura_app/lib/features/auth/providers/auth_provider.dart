import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

final authStateProvider =
    StreamProvider<AuthState>((ref) => supabase.auth.onAuthStateChange);

final currentUserProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

/// Listenable that notifies GoRouter when auth state changes.
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  AuthNotifier() {
    _sub = supabase.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
