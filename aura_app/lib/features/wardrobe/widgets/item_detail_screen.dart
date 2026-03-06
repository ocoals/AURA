import 'package:cached_network_image/cached_network_image.dart';
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
import '../models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';
import 'category_selector.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final WardrobeItem item;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late WardrobeItem _item;
  bool _isEditing = false;
  bool _isSaving = false;

  // Edit state
  WardrobeCategory? _category;
  String? _subcategory;
  WardrobeFit? _fit;
  WardrobePattern? _pattern;
  late TextEditingController _brandController;
  late TextEditingController _tagsController;
  final Set<WardrobeSeason> _seasons = {};

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _brandController = TextEditingController();
    _tagsController = TextEditingController();
    _resetEditState();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _resetEditState() {
    _category = WardrobeCategory.values.cast<WardrobeCategory?>().firstWhere(
          (c) => c!.key == _item.category,
          orElse: () => null,
        );
    _subcategory = _item.subcategory;
    _fit = WardrobeFit.values.cast<WardrobeFit?>().firstWhere(
          (f) => f!.key == _item.fit,
          orElse: () => null,
        );
    _pattern = WardrobePattern.values.cast<WardrobePattern?>().firstWhere(
          (p) => p!.key == _item.pattern,
          orElse: () => null,
        );
    _brandController.text = _item.brand ?? '';
    _tagsController.text = _item.styleTags.join(', ');
    _seasons
      ..clear()
      ..addAll(
        _item.season
            .map((s) => WardrobeSeason.values.cast<WardrobeSeason?>().firstWhere(
                  (ws) => ws!.key == s,
                  orElse: () => null,
                ))
            .whereType<WardrobeSeason>(),
      );
  }

  List<String> get _subcategories =>
      _category != null ? (subcategoryMap[_category] ?? []) : [];

  Future<void> _save() async {
    if (_category == null) return;
    setState(() => _isSaving = true);

    final styleTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      final repo = ref.read(wardrobeRepositoryProvider);
      final updated = await repo.updateItem(
        _item.id,
        category: _category!.key,
        subcategory: _subcategory,
        fit: _fit?.key,
        pattern: _pattern?.key,
        brand: _brandController.text.trim().isNotEmpty
            ? _brandController.text.trim()
            : null,
        styleTags: styleTags,
        season: _seasons.map((s) => s.key).toList(),
      );

      ref.read(wardrobeListProvider.notifier).updateItem(updated);
      setState(() {
        _item = updated;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.glassStrong,
        title: const Text('아이템 삭제'),
        content: const Text('이 아이템을 삭제하시겠습니까?'),
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
      await repo.deleteItem(_item.id);
      ref.read(wardrobeListProvider.notifier).removeItem(_item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String _categoryLabel(String key) {
    for (final cat in WardrobeCategory.values) {
      if (cat.key == key) return cat.label;
    }
    return key;
  }

  String _fitLabel(String? key) {
    if (key == null) return '-';
    for (final f in WardrobeFit.values) {
      if (f.key == key) return f.label;
    }
    return key;
  }

  String _patternLabel(String? key) {
    if (key == null) return '-';
    for (final p in WardrobePattern.values) {
      if (p.key == key) return p.label;
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('아이템 상세', style: AppTypography.sectionTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  _isEditing = false;
                  _resetEditState();
                });
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit_outlined,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) _resetEditState();
                });
              },
            ),
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 22),
                onPressed: _delete,
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                _isEditing ? 120 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  GlassCard(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: _item.imageUrl,
                        height: 320,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, url) => Container(
                          height: 320,
                          color: AppColors.glass,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, url, err) => Container(
                          height: 320,
                          color: AppColors.glass,
                          child: const Icon(Icons.broken_image,
                              color: AppColors.ter, size: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Color (read-only always)
                  if (_item.colorHex != null) ...[
                    _SectionLabel('색상'),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hexToColor(_item.colorHex!),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _item.colorName ?? '',
                            style: AppTypography.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _item.colorHex!,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  // Category
                  _SectionLabel('카테고리'),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    CategorySelector(
                      selected: _category,
                      onChanged: (cat) => setState(() {
                        _category = cat;
                        _subcategory = null;
                      }),
                    )
                  else
                    _ReadOnlyChip(_categoryLabel(_item.category)),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Subcategory
                  if (_isEditing && _subcategories.isNotEmpty) ...[
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
                  ] else if (!_isEditing && _item.subcategory != null) ...[
                    _SectionLabel('세부 카테고리'),
                    const SizedBox(height: 8),
                    _ReadOnlyChip(_item.subcategory!),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  // Fit
                  _SectionLabel('핏'),
                  const SizedBox(height: 8),
                  if (_isEditing)
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
                    )
                  else
                    _ReadOnlyChip(_fitLabel(_item.fit)),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Pattern
                  _SectionLabel('패턴'),
                  const SizedBox(height: 8),
                  if (_isEditing)
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
                    )
                  else
                    _ReadOnlyChip(_patternLabel(_item.pattern)),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Brand
                  _SectionLabel('브랜드'),
                  const SizedBox(height: 8),
                  if (_isEditing)
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
                    )
                  else
                    _ReadOnlyChip(
                        _item.brand?.isNotEmpty == true ? _item.brand! : '-'),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Season
                  _SectionLabel('시즌'),
                  const SizedBox(height: 8),
                  if (_isEditing)
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
                    )
                  else
                    Wrap(
                      spacing: 8,
                      children: _item.season.map((s) {
                        final label = WardrobeSeason.values
                                .cast<WardrobeSeason?>()
                                .firstWhere((ws) => ws!.key == s,
                                    orElse: () => null)
                                ?.label ??
                            s;
                        return _ReadOnlyChip(label);
                      }).toList(),
                    ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Style tags
                  _SectionLabel('스타일 태그'),
                  const SizedBox(height: 8),
                  if (_isEditing)
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
                    )
                  else if (_item.styleTags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _item.styleTags
                          .map((t) => _ReadOnlyChip(t))
                          .toList(),
                    )
                  else
                    _ReadOnlyChip('-'),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Metadata (read-only)
                  _SectionLabel('정보'),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _MetadataRow(
                          label: '착용 횟수',
                          value: '${_item.wearCount}회',
                        ),
                        const Divider(height: 20, color: AppColors.glassBorder),
                        _MetadataRow(
                          label: '등록일',
                          value: _formatDate(_item.createdAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Save CTA (edit mode only)
            if (_isEditing)
              Positioned(
                left: AppSpacing.screenHorizontal,
                right: AppSpacing.screenHorizontal,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                child: GestureDetector(
                  onTap: _isSaving ? null : _save,
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
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '저장하기',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.white),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
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

class _ReadOnlyChip extends StatelessWidget {
  const _ReadOnlyChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 20,
      child: Text(text, style: AppTypography.body),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(value, style: AppTypography.bodyMedium),
      ],
    );
  }
}
