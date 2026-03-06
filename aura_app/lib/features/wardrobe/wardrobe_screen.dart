import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'providers/wardrobe_provider.dart';
import 'widgets/category_story_row.dart';
import 'widgets/image_source_sheet.dart';
import 'widgets/wardrobe_grid.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final listAsync = ref.watch(wardrobeListProvider);
    final isMultiSelect = ref.watch(multiSelectModeProvider);
    final selectedIds = ref.watch(selectedItemIdsProvider);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header / Multi-select header
              if (isMultiSelect)
                _MultiSelectHeader(
                  selectedCount: selectedIds.length,
                  totalCount: listAsync.valueOrNull?.length ?? 0,
                  onClose: () {
                    ref.read(multiSelectModeProvider.notifier).state = false;
                    ref.read(selectedItemIdsProvider.notifier).state = {};
                  },
                  onSelectAll: () {
                    final items = listAsync.valueOrNull ?? [];
                    if (selectedIds.length == items.length) {
                      ref.read(selectedItemIdsProvider.notifier).state = {};
                    } else {
                      ref.read(selectedItemIdsProvider.notifier).state =
                          items.map((i) => i.id).toSet();
                    }
                  },
                  onDelete: () => _bulkDelete(context, ref, selectedIds),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.headerHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Closet', style: AppTypography.pageTitle),
                      const SizedBox(height: 4),
                      listAsync.when(
                        data: (items) => Text(
                          '${items.length}벌의 옷이 있어요',
                          style: AppTypography.subtitle,
                        ),
                        loading: () => Text(
                          '불러오는 중...',
                          style: AppTypography.subtitle,
                        ),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Category story row
              if (!isMultiSelect)
                CategoryStoryRow(
                  selected: selectedCategory,
                  onChanged: (cat) {
                    ref.read(selectedCategoryProvider.notifier).state = cat;
                    ref.read(wardrobeListProvider.notifier).refresh();
                  },
                ),
              if (!isMultiSelect) const SizedBox(height: 8),

              // Content
              Expanded(
                child: listAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return _EmptyState(
                        onAdd: () => _showImageSourceSheet(context),
                      );
                    }
                    final notifier = ref.read(wardrobeListProvider.notifier);
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => notifier.refresh(),
                      child: WardrobeGrid(
                        items: items,
                        onLoadMore: () => notifier.loadMore(),
                        hasMore: notifier.hasMore,
                        isLoadingMore: notifier.isLoadingMore,
                        isMultiSelectMode: isMultiSelect,
                        selectedIds: selectedIds,
                        onItemTap: (item) {
                          if (isMultiSelect) {
                            _toggleSelection(ref, item.id, selectedIds);
                          } else {
                            context.push('/closet/detail', extra: item);
                          }
                        },
                        onItemLongPress: (item) {
                          if (!isMultiSelect) {
                            ref.read(multiSelectModeProvider.notifier).state =
                                true;
                            ref.read(selectedItemIdsProvider.notifier).state = {
                              item.id
                            };
                          }
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      '목록을 불러올 수 없습니다',
                      style: AppTypography.body.copyWith(color: AppColors.ter),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // FAB (hidden in multi-select mode)
          if (!isMultiSelect)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 88,
              right: 18,
              child: GestureDetector(
                onTap: () => _showImageSourceSheet(context),
                child: Container(
                  width: AppSpacing.fabSize,
                  height: AppSpacing.fabSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleSelection(WidgetRef ref, String itemId, Set<String> current) {
    final updated = Set<String>.from(current);
    if (updated.contains(itemId)) {
      updated.remove(itemId);
      if (updated.isEmpty) {
        ref.read(multiSelectModeProvider.notifier).state = false;
      }
    } else {
      updated.add(itemId);
    }
    ref.read(selectedItemIdsProvider.notifier).state = updated;
  }

  Future<void> _bulkDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    if (ids.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.glassStrong,
        title: const Text('아이템 삭제'),
        content: Text('${ids.length}개의 아이템을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text('삭제', style: TextStyle(color: Colors.red[300])),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(wardrobeRepositoryProvider);
      await repo.deleteItems(ids.toList());
      ref.read(wardrobeListProvider.notifier).removeItems(ids.toList());
      ref.read(multiSelectModeProvider.notifier).state = false;
      ref.read(selectedItemIdsProvider.notifier).state = {};
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ids.length}개 아이템이 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final path = await showImageSourceSheet(context);
    if (path != null && context.mounted) {
      context.push('/closet/add', extra: path);
    }
  }
}

class _MultiSelectHeader extends StatelessWidget {
  const _MultiSelectHeader({
    required this.selectedCount,
    required this.totalCount,
    required this.onClose,
    required this.onSelectAll,
    required this.onDelete,
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.headerHorizontal,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            '$selectedCount개 선택',
            style: AppTypography.sectionTitle,
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSelectAll,
            child: Text(
              selectedCount == totalCount ? '전체 해제' : '전체 선택',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: selectedCount > 0 ? onDelete : null,
            child: Icon(
              Icons.delete_outline,
              size: 24,
              color: selectedCount > 0 ? Colors.red[300] : AppColors.mute,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom, size: 64, color: AppColors.mute),
          const SizedBox(height: 16),
          Text(
            '아직 옷장이 비어있어요',
            style: AppTypography.body.copyWith(color: AppColors.ter),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAdd,
            child: Text(
              '첫 번째 옷 등록하기',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
