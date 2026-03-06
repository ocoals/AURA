class WardrobeItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String? originalImageUrl;
  final String category;
  final String? subcategory;
  final String? colorHex;
  final String? colorName;
  final Map<String, dynamic>? colorHsl;
  final List<String> styleTags;
  final String? fit;
  final String? pattern;
  final String? brand;
  final List<String> season;
  final int wearCount;
  final DateTime? lastWornAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WardrobeItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.originalImageUrl,
    required this.category,
    this.subcategory,
    this.colorHex,
    this.colorName,
    this.colorHsl,
    this.styleTags = const [],
    this.fit,
    this.pattern,
    this.brand,
    this.season = const ['spring', 'summer', 'fall', 'winter'],
    this.wearCount = 0,
    this.lastWornAt,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      originalImageUrl: json['original_image_url'] as String?,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      colorHex: json['color_hex'] as String?,
      colorName: json['color_name'] as String?,
      colorHsl: json['color_hsl'] as Map<String, dynamic>?,
      styleTags: (json['style_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      brand: json['brand'] as String?,
      season: (json['season'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['spring', 'summer', 'fall', 'winter'],
      wearCount: json['wear_count'] as int? ?? 0,
      lastWornAt: json['last_worn_at'] != null
          ? DateTime.parse(json['last_worn_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'original_image_url': originalImageUrl,
      'category': category,
      'subcategory': subcategory,
      'color_hex': colorHex,
      'color_name': colorName,
      'color_hsl': colorHsl,
      'style_tags': styleTags,
      'fit': fit,
      'pattern': pattern,
      'brand': brand,
      'season': season,
      'wear_count': wearCount,
      'last_worn_at': lastWornAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WardrobeItem copyWith({
    String? imageUrl,
    String? originalImageUrl,
    String? category,
    String? subcategory,
    String? colorHex,
    String? colorName,
    Map<String, dynamic>? colorHsl,
    List<String>? styleTags,
    String? fit,
    String? pattern,
    String? brand,
    List<String>? season,
    int? wearCount,
    DateTime? lastWornAt,
    bool? isActive,
  }) {
    return WardrobeItem(
      id: id,
      userId: userId,
      imageUrl: imageUrl ?? this.imageUrl,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      colorHex: colorHex ?? this.colorHex,
      colorName: colorName ?? this.colorName,
      colorHsl: colorHsl ?? this.colorHsl,
      styleTags: styleTags ?? this.styleTags,
      fit: fit ?? this.fit,
      pattern: pattern ?? this.pattern,
      brand: brand ?? this.brand,
      season: season ?? this.season,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
