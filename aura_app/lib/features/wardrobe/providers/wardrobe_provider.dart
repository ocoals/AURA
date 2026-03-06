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
  static const _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<WardrobeItem>> build() => _fetchFirst();

  Future<List<WardrobeItem>> _fetchFirst() async {
    _hasMore = true;
    _isLoadingMore = false;
    final category = ref.read(selectedCategoryProvider);
    final repo = ref.read(wardrobeRepositoryProvider);
    final items = await repo.getItems(category: category?.key, limit: _pageSize);
    _hasMore = items.length >= _pageSize;
    return items;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final current = state.valueOrNull ?? [];
    _isLoadingMore = true;
    state = AsyncData(current); // trigger rebuild to show loading

    final category = ref.read(selectedCategoryProvider);
    final repo = ref.read(wardrobeRepositoryProvider);
    final more = await repo.getItems(
      category: category?.key,
      limit: _pageSize,
      offset: current.length,
    );

    _hasMore = more.length >= _pageSize;
    _isLoadingMore = false;
    state = AsyncData([...current, ...more]);
  }

  void addItem(WardrobeItem item) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([item, ...current]);
  }

  void updateItem(WardrobeItem updated) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final item in current)
        if (item.id == updated.id) updated else item,
    ]);
  }

  void removeItem(String itemId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((i) => i.id != itemId).toList());
  }

  void removeItems(List<String> ids) {
    final current = state.valueOrNull ?? [];
    final idSet = ids.toSet();
    state = AsyncData(current.where((i) => !idSet.contains(i.id)).toList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchFirst);
  }
}

// --- Multi-select ---

final multiSelectModeProvider = StateProvider<bool>((ref) => false);
final selectedItemIdsProvider = StateProvider<Set<String>>((ref) => {});

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
