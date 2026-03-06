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

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
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
              CategoryStoryRow(
                selected: selectedCategory,
                onChanged: (cat) {
                  ref.read(selectedCategoryProvider.notifier).state = cat;
                  ref.read(wardrobeListProvider.notifier).refresh();
                },
              ),
              const SizedBox(height: 8),

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

          // FAB
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

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final path = await showImageSourceSheet(context);
    if (path != null && context.mounted) {
      context.push('/closet/add', extra: path);
    }
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
