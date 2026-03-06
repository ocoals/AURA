import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/wardrobe_constants.dart';
import '../models/wardrobe_item.dart';

class WardrobeGrid extends StatefulWidget {
  const WardrobeGrid({
    super.key,
    required this.items,
    required this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onItemTap,
    this.onItemLongPress,
    this.isMultiSelectMode = false,
    this.selectedIds = const {},
  });

  final List<WardrobeItem> items;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final void Function(WardrobeItem)? onItemTap;
  final void Function(WardrobeItem)? onItemLongPress;
  final bool isMultiSelectMode;
  final Set<String> selectedIds;

  @override
  State<WardrobeGrid> createState() => _WardrobeGridState();
}

class _WardrobeGridState extends State<WardrobeGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= maxScroll - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.headerHorizontal,
        0,
        AppSpacing.headerHorizontal,
        120,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.ter,
                ),
              ),
            ),
          );
        }
        final item = widget.items[index];
        return _ItemCard(
          item: item,
          isSelected: widget.selectedIds.contains(item.id),
          isMultiSelectMode: widget.isMultiSelectMode,
          onTap: () => widget.onItemTap?.call(item),
          onLongPress: () => widget.onItemLongPress?.call(item),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onTap,
    this.onLongPress,
  });

  final WardrobeItem item;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  String get _categoryLabel {
    for (final cat in WardrobeCategory.values) {
      if (cat.key == item.category) return cat.label;
    }
    return item.category;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2.5)
              : null,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(6),
          borderRadius: AppSpacing.cardRadiusSmall,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, url) => Container(
                          color: AppColors.glass,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.ter,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, url, err) => Container(
                          color: AppColors.glass,
                          child: const Icon(Icons.broken_image,
                              color: AppColors.ter),
                        ),
                      ),
                    ),
                    if (isMultiSelectMode)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black38,
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: AppColors.white, size: 16)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    if (item.colorHex != null) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hexToColor(item.colorHex!),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        _categoryLabel,
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
