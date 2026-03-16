import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_result.dart';
import '../repositories/match_repository.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final matchAnalyzeProvider =
    AutoDisposeAsyncNotifierProvider<MatchAnalyzeNotifier, MatchResult?>(
  MatchAnalyzeNotifier.new,
);

class MatchAnalyzeNotifier extends AutoDisposeAsyncNotifier<MatchResult?> {
  @override
  Future<MatchResult?> build() async => null;

  Future<void> analyze({required Uint8List imageBytes}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(matchRepositoryProvider);
      return repo.analyzeReference(imageBytes: imageBytes);
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final selectedGapItemProvider = StateProvider<GapItem?>((ref) => null);
