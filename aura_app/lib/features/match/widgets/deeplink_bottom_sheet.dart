import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/match_result.dart';
import '../services/deeplink_service.dart';

Future<void> showDeeplinkSheet(BuildContext context, GapItem gapItem) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeeplinkSheet(gapItem: gapItem),
  );
}

class _DeeplinkSheet extends StatelessWidget {
  const _DeeplinkSheet({required this.gapItem});

  final GapItem gapItem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        child: GlassCard(
          strong: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gapItem.description, style: AppTypography.sectionTitle),
              const SizedBox(height: 4),
              Text('어디서 찾아볼까요?', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: _PlatformOption(
                      platform: ShoppingPlatform.musinsa,
                      brandColor: const Color(0xFF1A1A1A),
                      url: gapItem.deeplinks.musinsa,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlatformOption(
                      platform: ShoppingPlatform.ably,
                      brandColor: const Color(0xFFFF6B6B),
                      url: gapItem.deeplinks.ably,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlatformOption(
                      platform: ShoppingPlatform.zigzag,
                      brandColor: const Color(0xFF7C3AED),
                      url: gapItem.deeplinks.zigzag,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformOption extends StatelessWidget {
  const _PlatformOption({
    required this.platform,
    required this.brandColor,
    required this.url,
  });

  final ShoppingPlatform platform;
  final Color brandColor;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        DeeplinkService.openUrl(url);
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(platform.label, style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}
