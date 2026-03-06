import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/wardrobe_constants.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WardrobeCategory? selected;
  final ValueChanged<WardrobeCategory> onChanged;

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
        itemCount: WardrobeCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final cat = WardrobeCategory.values[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glass,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.glassBorder,
                      width: isSelected ? 2 : 0.5,
                    ),
                  ),
                  child: Icon(
                    _icons[cat],
                    size: 24,
                    color: isSelected ? AppColors.primary : AppColors.ter,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat.label,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.ter,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
