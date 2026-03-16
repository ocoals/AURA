class Deeplinks {
  const Deeplinks({
    required this.musinsa,
    required this.ably,
    required this.zigzag,
  });

  final String musinsa;
  final String ably;
  final String zigzag;

  factory Deeplinks.fromJson(Map<String, dynamic> json) => Deeplinks(
        musinsa: json['musinsa'] as String,
        ably: json['ably'] as String,
        zigzag: json['zigzag'] as String,
      );

  Map<String, dynamic> toJson() => {
        'musinsa': musinsa,
        'ably': ably,
        'zigzag': zigzag,
      };
}

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.category,
    required this.color,
    required this.style,
    required this.bonus,
  });

  final double category;
  final double color;
  final double style;
  final double bonus;

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) =>
      ScoreBreakdown(
        category: (json['category'] as num).toDouble(),
        color: (json['color'] as num).toDouble(),
        style: (json['style'] as num).toDouble(),
        bonus: (json['bonus'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'color': color,
        'style': style,
        'bonus': bonus,
      };
}

class AnalyzedItemColor {
  const AnalyzedItemColor({
    required this.hex,
    required this.name,
    this.hsl,
  });

  final String hex;
  final String name;
  final Map<String, num>? hsl;

  factory AnalyzedItemColor.fromJson(Map<String, dynamic> json) =>
      AnalyzedItemColor(
        hex: json['hex'] as String,
        name: json['name'] as String,
        hsl: json['hsl'] != null
            ? Map<String, num>.from(json['hsl'] as Map)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'hex': hex,
        'name': name,
        if (hsl != null) 'hsl': hsl,
      };
}

class AnalyzedItem {
  const AnalyzedItem({
    required this.index,
    required this.category,
    this.subcategory,
    required this.color,
    this.style,
    this.fit,
    this.pattern,
    this.material,
  });

  final int index;
  final String category;
  final String? subcategory;
  final AnalyzedItemColor color;
  final List<String>? style;
  final String? fit;
  final String? pattern;
  final String? material;

  factory AnalyzedItem.fromJson(Map<String, dynamic> json) => AnalyzedItem(
        index: json['index'] as int,
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        color:
            AnalyzedItemColor.fromJson(json['color'] as Map<String, dynamic>),
        style: (json['style'] as List?)?.cast<String>(),
        fit: json['fit'] as String?,
        pattern: json['pattern'] as String?,
        material: json['material'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        'color': color.toJson(),
        if (style != null) 'style': style,
        if (fit != null) 'fit': fit,
        if (pattern != null) 'pattern': pattern,
        if (material != null) 'material': material,
      };
}

class MatchedWardrobeItem {
  const MatchedWardrobeItem({
    required this.id,
    required this.category,
    this.subcategory,
    required this.colorHex,
    required this.colorName,
    this.styleTags = const [],
    this.fit,
    this.pattern,
  });

  final String id;
  final String category;
  final String? subcategory;
  final String colorHex;
  final String colorName;
  final List<String> styleTags;
  final String? fit;
  final String? pattern;

  factory MatchedWardrobeItem.fromJson(Map<String, dynamic> json) =>
      MatchedWardrobeItem(
        id: json['id'] as String,
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        colorHex: json['color_hex'] as String,
        colorName: json['color_name'] as String,
        styleTags: (json['style_tags'] as List?)?.cast<String>() ?? const [],
        fit: json['fit'] as String?,
        pattern: json['pattern'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        'color_hex': colorHex,
        'color_name': colorName,
        'style_tags': styleTags,
        if (fit != null) 'fit': fit,
        if (pattern != null) 'pattern': pattern,
      };
}

class MatchedItem {
  const MatchedItem({
    required this.refIndex,
    required this.wardrobeItem,
    required this.score,
    required this.breakdown,
    this.matchReasons = const [],
  });

  final int refIndex;
  final MatchedWardrobeItem wardrobeItem;
  final double score;
  final ScoreBreakdown breakdown;
  final List<String> matchReasons;

  factory MatchedItem.fromJson(Map<String, dynamic> json) => MatchedItem(
        refIndex: json['ref_index'] as int,
        wardrobeItem: MatchedWardrobeItem.fromJson(
            json['wardrobe_item'] as Map<String, dynamic>),
        score: (json['score'] as num).toDouble(),
        breakdown: ScoreBreakdown.fromJson(
            json['breakdown'] as Map<String, dynamic>),
        matchReasons:
            (json['match_reasons'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'ref_index': refIndex,
        'wardrobe_item': wardrobeItem.toJson(),
        'score': score,
        'breakdown': breakdown.toJson(),
        'match_reasons': matchReasons,
      };
}

class GapItem {
  const GapItem({
    required this.refIndex,
    required this.category,
    required this.description,
    required this.searchKeywords,
    required this.deeplinks,
  });

  final int refIndex;
  final String category;
  final String description;
  final String searchKeywords;
  final Deeplinks deeplinks;

  factory GapItem.fromJson(Map<String, dynamic> json) => GapItem(
        refIndex: json['ref_index'] as int,
        category: json['category'] as String,
        description: json['description'] as String,
        searchKeywords: json['search_keywords'] as String,
        deeplinks:
            Deeplinks.fromJson(json['deeplinks'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'ref_index': refIndex,
        'category': category,
        'description': description,
        'search_keywords': searchKeywords,
        'deeplinks': deeplinks.toJson(),
      };
}

class ReferenceAnalysis {
  const ReferenceAnalysis({
    required this.items,
    this.overallStyle,
    this.occasion,
  });

  final List<AnalyzedItem> items;
  final String? overallStyle;
  final String? occasion;

  factory ReferenceAnalysis.fromJson(Map<String, dynamic> json) =>
      ReferenceAnalysis(
        items: (json['items'] as List)
            .map((e) => AnalyzedItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        overallStyle: json['overall_style'] as String?,
        occasion: json['occasion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        if (overallStyle != null) 'overall_style': overallStyle,
        if (occasion != null) 'occasion': occasion,
      };
}

class MatchResult {
  const MatchResult({
    required this.id,
    required this.overallScore,
    required this.referenceAnalysis,
    required this.matchedItems,
    required this.gapItems,
  });

  final String id;
  final double overallScore;
  final ReferenceAnalysis referenceAnalysis;
  final List<MatchedItem> matchedItems;
  final List<GapItem> gapItems;

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        id: json['id'] as String,
        overallScore: (json['overall_score'] as num).toDouble(),
        referenceAnalysis: ReferenceAnalysis.fromJson(
            json['reference_analysis'] as Map<String, dynamic>),
        matchedItems: (json['matched_items'] as List)
            .map((e) => MatchedItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        gapItems: (json['gap_items'] as List)
            .map((e) => GapItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'overall_score': overallScore,
        'reference_analysis': referenceAnalysis.toJson(),
        'matched_items': matchedItems.map((e) => e.toJson()).toList(),
        'gap_items': gapItems.map((e) => e.toJson()).toList(),
      };
}
