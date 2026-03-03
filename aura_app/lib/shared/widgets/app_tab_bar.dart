import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    _TabItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view),
    _TabItem(icon: Icons.crop_free, activeIcon: Icons.crop_free),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.tabBarRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xEBFFFFFF), // rgba(255,255,255,0.92)
              borderRadius: BorderRadius.circular(AppSpacing.tabBarRadius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000), // rgba(0,0,0,0.08)
                  blurRadius: 20,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (i) {
                final isActive = i == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: AppSpacing.tabItemSize,
                    height: AppSpacing.tabItemSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0x1A4F46E5) // rgba(79,70,229,0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.tabItemRadius,
                        ),
                      ),
                      child: Icon(
                        isActive ? _items[i].activeIcon : _items[i].icon,
                        color: isActive ? AppColors.primary : AppColors.ter,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.icon, required this.activeIcon});
  final IconData icon;
  final IconData activeIcon;
}
