import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wardrobe_constants.dart';
import '../models/wardrobe_item.dart';
import '../repositories/wardrobe_repository.dart';

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository();
});

// --- List ---

final selectedCategoryProvider = StateProvider<WardrobeCategory?>((ref) => null);

final wardrobeListProvider =
    AsyncNotifierProvider<WardrobeListNotifier, List<WardrobeItem>>(
  WardrobeListNotifier.new,
);

class WardrobeListNotifier extends AsyncNotifier<List<WardrobeItem>> {
  @override
  Future<List<WardrobeItem>> build() => fetchItems();

  Future<List<WardrobeItem>> fetchItems() async {
    final category = ref.read(selectedCategoryProvider);
    final repo = ref.read(wardrobeRepositoryProvider);
    return repo.getItems(category: category?.key);
  }

  void addItem(WardrobeItem item) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([item, ...current]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchItems);
  }
}

// --- Upload ---

final wardrobeUploadProvider =
    AutoDisposeAsyncNotifierProvider<WardrobeUploadNotifier, WardrobeItem?>(
  WardrobeUploadNotifier.new,
);

class WardrobeUploadNotifier extends AutoDisposeAsyncNotifier<WardrobeItem?> {
  @override
  Future<WardrobeItem?> build() async => null;

  Future<void> upload({
    required Uint8List imageBytes,
    required String category,
    String? subcategory,
    String? fit,
    String? pattern,
    String? brand,
    List<String>? styleTags,
    List<String>? season,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(wardrobeRepositoryProvider);
      return repo.uploadItem(
        imageBytes: imageBytes,
        category: category,
        subcategory: subcategory,
        fit: fit,
        pattern: pattern,
        brand: brand,
        styleTags: styleTags,
        season: season,
      );
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}
