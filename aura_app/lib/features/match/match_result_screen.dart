import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/glass_card.dart';
import 'models/match_result.dart';
import 'widgets/deeplink_bottom_sheet.dart';

class MatchResultScreen extends ConsumerWidget {
  const MatchResultScreen({super.key, required this.result});

  final MatchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('결과'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8E0F0), Color(0xFFF5F0FF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            children: [
              const SizedBox(height: 8),
              _ScoreSection(score: result.overallScore),
              const SizedBox(height: AppSpacing.sectionGap),
              if (result.matchedItems.isNotEmpty) ...[
                Text('매칭 아이템', style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.sectionGapSmall),
                ...result.matchedItems.map(_MatchedTile.new),
                const SizedBox(height: AppSpacing.sectionGap),
              ],
              if (result.gapItems.isNotEmpty) ...[
                Text('부족한 아이템', style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.sectionGapSmall),
                ...result.gapItems.map(
                  (gap) => _GapTile(gap, onFind: () {
                    showDeeplinkSheet(context, gap);
                  }),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreSection extends StatelessWidget {
  const _ScoreSection({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text('매칭 점수', style: AppTypography.subtitle),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(1),
            style: AppTypography.matchScore,
          ),
        ],
      ),
    );
  }
}

class _MatchedTile extends StatelessWidget {
  const _MatchedTile(this.item);
  final MatchedItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.wardrobeItem.subcategory ?? item.wardrobeItem.category,
                    style: AppTypography.bodyMedium,
                  ),
                  if (item.matchReasons.isNotEmpty)
                    Text(
                      item.matchReasons.first,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              '${item.score.toStringAsFixed(0)}점',
              style: AppTypography.sectionTitle.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GapTile extends StatelessWidget {
  const _GapTile(this.gap, {required this.onFind});
  final GapItem gap;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gap.description, style: AppTypography.bodyMedium),
                  Text(gap.category, style: AppTypography.caption),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFind,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '찾기',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
