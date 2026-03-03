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
    _TabItem(
      icon: Icons.center_focus_weak,
      activeIcon: Icons.center_focus_strong,
    ),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  static const double _itemWidth = AppSpacing.tabItemSize;
  static const double _itemSpacing = 12.0;
  static const double _horizontalPadding = 16.0;
  static const int _itemCount = 4;
  static const double _barWidth =
      _itemCount * _itemWidth +
      (_itemCount - 1) * _itemSpacing +
      _horizontalPadding * 2;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 12,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.tabBarRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: _barWidth,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xEBFFFFFF),
                borderRadius: BorderRadius.circular(AppSpacing.tabBarRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Sliding highlight
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: currentIndex * (_itemWidth + _itemSpacing),
                      top: (60 - _itemWidth) / 2,
                      child: Container(
                        width: _itemWidth,
                        height: _itemWidth,
                        decoration: BoxDecoration(
                          color: const Color(0x1A4F46E5),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.tabItemRadius,
                          ),
                        ),
                      ),
                    ),
                    // Icon row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_items.length, (i) {
                        final isActive = i == currentIndex;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : _itemSpacing,
                          ),
                          child: GestureDetector(
                            onTap: () => onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: _itemWidth,
                              height: _itemWidth,
                              child: Icon(
                                isActive
                                    ? _items[i].activeIcon
                                    : _items[i].icon,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.ter,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
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
