import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/wardrobe_constants.dart';

class CategoryStoryRow extends StatelessWidget {
  const CategoryStoryRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WardrobeCategory? selected;
  final ValueChanged<WardrobeCategory?> onChanged;

  static const _icons = <WardrobeCategory, IconData>{
    WardrobeCategory.tops: Icons.checkroom,
    WardrobeCategory.bottoms: Icons.straighten,
    WardrobeCategory.outerwear: Icons.ac_unit,
    WardrobeCategory.dresses: Icons.dry_cleaning,
    WardrobeCategory.shoes: Icons.do_not_step,
    WardrobeCategory.bags: Icons.shopping_bag,
    WardrobeCategory.accessories: Icons.watch,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: WardrobeCategory.values.length + 1, // +1 for "All"
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          if (index == 0) {
            return _buildItem(
              icon: Icons.grid_view_rounded,
              label: '전체',
              isSelected: selected == null,
              onTap: () => onChanged(null),
            );
          }
          final cat = WardrobeCategory.values[index - 1];
          return _buildItem(
            icon: _icons[cat] ?? Icons.category,
            label: cat.label,
            isSelected: cat == selected,
            onTap: () => onChanged(cat),
          );
        },
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glass,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.ter,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.ter,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
