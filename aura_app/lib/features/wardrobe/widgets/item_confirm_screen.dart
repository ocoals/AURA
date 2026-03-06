import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../models/wardrobe_constants.dart';
import '../providers/wardrobe_provider.dart';
import 'category_selector.dart';

class ItemConfirmScreen extends ConsumerStatefulWidget {
  const ItemConfirmScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<ItemConfirmScreen> createState() => _ItemConfirmScreenState();
}

class _ItemConfirmScreenState extends ConsumerState<ItemConfirmScreen> {
  WardrobeCategory? _category;
  String? _subcategory;
  WardrobeFit? _fit;
  WardrobePattern? _pattern;
  final _brandController = TextEditingController();
  final _tagsController = TextEditingController();
  final Set<WardrobeSeason> _seasons = Set.from(WardrobeSeason.values);

  @override
  void dispose() {
    _brandController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> get _subcategories =>
      _category != null ? (subcategoryMap[_category] ?? []) : [];

  Future<void> _save() async {
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }

    final imageBytes = await File(widget.imagePath).readAsBytes();
    final styleTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    await ref.read(wardrobeUploadProvider.notifier).upload(
          imageBytes: imageBytes,
          category: _category!.key,
          subcategory: _subcategory,
          fit: _fit?.key,
          pattern: _pattern?.key,
          brand: _brandController.text.trim(),
          styleTags: styleTags.isNotEmpty ? styleTags : null,
          season: _seasons.map((s) => s.key).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(wardrobeUploadProvider);

    ref.listen(wardrobeUploadProvider, (prev, next) {
      if (next.hasValue && next.value != null) {
        ref.read(wardrobeListProvider.notifier).addItem(next.value!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이템이 등록되었습니다!')),
        );
        context.pop();
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('아이템 등록', style: AppTypography.sectionTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview
                  GlassCard(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(widget.imagePath),
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Category
                  _SectionLabel('카테고리 *'),
                  const SizedBox(height: 8),
                  CategorySelector(
                    selected: _category,
                    onChanged: (cat) => setState(() {
                      _category = cat;
                      _subcategory = null;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Subcategory
                  if (_subcategories.isNotEmpty) ...[
                    _SectionLabel('세부 카테고리'),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _subcategory,
                          hint: Text('선택', style: AppTypography.body),
                          dropdownColor: AppColors.glassStrong,
                          items: _subcategories
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _subcategory = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  // Fit
                  _SectionLabel('핏'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: WardrobeFit.values.map((f) {
                      return ChoiceChip(
                        label: Text(f.label),
                        selected: _fit == f,
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        onSelected: (sel) =>
                            setState(() => _fit = sel ? f : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Pattern
                  _SectionLabel('패턴'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: WardrobePattern.values.map((p) {
                      return ChoiceChip(
                        label: Text(p.label),
                        selected: _pattern == p,
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        onSelected: (sel) =>
                            setState(() => _pattern = sel ? p : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Brand
                  _SectionLabel('브랜드'),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        hintText: '브랜드명 입력 (선택)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Season
                  _SectionLabel('시즌'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: WardrobeSeason.values.map((s) {
                      final isSelected = _seasons.contains(s);
                      return FilterChip(
                        label: Text(s.label),
                        selected: isSelected,
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _seasons.add(s);
                            } else {
                              _seasons.remove(s);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Style tags
                  _SectionLabel('스타일 태그'),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: '캐주얼, 미니멀, 스트릿 (콤마 구분)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CTA button
            Positioned(
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: GestureDetector(
                onTap: uploadState.isLoading ? null : _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppGradients.ctaButton,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '저장하기',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (uploadState.isLoading) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.sectionTitle);
  }
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  int _step = 0;

  static const _messages = [
    '이미지 업로드 중...',
    '배경 제거 중...',
    '색상 분석 중...',
  ];

  @override
  void initState() {
    super.initState();
    _advanceStep();
  }

  void _advanceStep() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_step < _messages.length - 1) {
        setState(() => _step++);
        if (_step < _messages.length - 1) {
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            setState(() => _step++);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: GlassCard(
        strong: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _messages[_step],
                key: ValueKey(_step),
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
