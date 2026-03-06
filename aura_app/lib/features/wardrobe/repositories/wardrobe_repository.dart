import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/supabase_service.dart';
import '../models/wardrobe_item.dart';

class WardrobeRepository {
  bool get _useMock => dotenv.env['USE_MOCK']?.toLowerCase() == 'true';

  Future<List<WardrobeItem>> getItems({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (_useMock) return _mockItems(category: category);

    final session = supabase.auth.currentSession;
    if (session == null) throw const AuthRequiredException();

    var query = supabase
        .from('wardrobe_items')
        .select()
        .eq('user_id', session.user.id)
        .eq('is_active', true);

    if (category != null) {
      query = query.eq('category', category);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List)
        .map((json) => WardrobeItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<WardrobeItem> _mockItems({String? category}) {
    final now = DateTime.now();
    final items = <WardrobeItem>[
      WardrobeItem(
        id: 'mock-1', userId: 'mock', category: 'tops',
        imageUrl: 'https://placehold.co/400x500/E8E0F0/4F46E5/png?text=T-shirt',
        colorHex: '#4F46E5', colorName: 'Indigo',
        subcategory: '티셔츠', styleTags: ['캐주얼'], season: ['spring', 'summer'],
        createdAt: now.subtract(const Duration(days: 1)), updatedAt: now,
      ),
      WardrobeItem(
        id: 'mock-2', userId: 'mock', category: 'bottoms',
        imageUrl: 'https://placehold.co/400x500/E0E8F0/2563EB/png?text=Jeans',
        colorHex: '#2563EB', colorName: 'Blue',
        subcategory: '청바지', styleTags: ['캐주얼'], season: ['spring', 'fall'],
        createdAt: now.subtract(const Duration(days: 2)), updatedAt: now,
      ),
      WardrobeItem(
        id: 'mock-3', userId: 'mock', category: 'outerwear',
        imageUrl: 'https://placehold.co/400x500/F0E8E0/D97706/png?text=Jacket',
        colorHex: '#D97706', colorName: 'Amber',
        subcategory: '자켓', styleTags: ['미니멀'], season: ['fall', 'winter'],
        createdAt: now.subtract(const Duration(days: 3)), updatedAt: now,
      ),
      WardrobeItem(
        id: 'mock-4', userId: 'mock', category: 'tops',
        imageUrl: 'https://placehold.co/400x500/E0F0E8/059669/png?text=Knit',
        colorHex: '#059669', colorName: 'Emerald',
        subcategory: '니트', styleTags: ['미니멀'], season: ['fall', 'winter'],
        createdAt: now.subtract(const Duration(days: 4)), updatedAt: now,
      ),
      WardrobeItem(
        id: 'mock-5', userId: 'mock', category: 'shoes',
        imageUrl: 'https://placehold.co/400x500/F0F0F0/1A1A1A/png?text=Sneakers',
        colorHex: '#1A1A1A', colorName: 'Black',
        subcategory: '스니커즈', styleTags: ['스트릿'], season: ['spring', 'summer', 'fall'],
        createdAt: now.subtract(const Duration(days: 5)), updatedAt: now,
      ),
      WardrobeItem(
        id: 'mock-6', userId: 'mock', category: 'bags',
        imageUrl: 'https://placehold.co/400x500/F0E0E8/BE185D/png?text=Tote',
        colorHex: '#BE185D', colorName: 'Pink',
        subcategory: '토트백', styleTags: ['캐주얼'], season: ['spring', 'summer', 'fall', 'winter'],
        createdAt: now.subtract(const Duration(days: 6)), updatedAt: now,
      ),
    ];

    if (category != null) {
      return items.where((i) => i.category == category).toList();
    }
    return items;
  }

  Future<WardrobeItem> uploadItem({
    required Uint8List imageBytes,
    required String category,
    String? subcategory,
    String? fit,
    String? pattern,
    String? brand,
    List<String>? styleTags,
    List<String>? season,
  }) async {
    final session = supabase.auth.currentSession;
    if (session == null) throw const AuthRequiredException();

    if (_useMock) {
      return _mockUpload(
        userId: session.user.id,
        category: category,
        subcategory: subcategory,
        fit: fit,
        pattern: pattern,
        brand: brand,
        styleTags: styleTags,
        season: season,
      );
    }

    final baseUrl = dotenv.env['SUPABASE_URL']!;
    final url = Uri.parse('$baseUrl/functions/v1/wardrobe-upload');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${session.accessToken}'
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'photo.jpg',
      ))
      ..fields['category'] = category;

    if (subcategory != null) request.fields['subcategory'] = subcategory;
    if (fit != null) request.fields['fit'] = fit;
    if (pattern != null) request.fields['pattern'] = pattern;
    if (brand != null && brand.isNotEmpty) request.fields['brand'] = brand;
    if (styleTags != null && styleTags.isNotEmpty) {
      request.fields['style_tags'] = styleTags.join(',');
    }
    if (season != null && season.isNotEmpty) {
      request.fields['season'] = season.join(',');
    }

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } on Exception catch (e) {
      debugPrint('[WardrobeRepository] Network error: $e');
      throw const NetworkException();
    }

    final body = await streamed.stream.bytesToString();
    final status = streamed.statusCode;

    if (status == 201) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return WardrobeItem.fromJson(json);
    }

    // Error handling
    debugPrint('[WardrobeRepository] HTTP $status: $body');

    Map<String, dynamic>? errJson;
    try {
      errJson = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {}

    final code = errJson?['code'] as String? ?? '';
    switch (code) {
      case 'AUTH_REQUIRED':
        throw const AuthRequiredException();
      case 'WARDROBE_LIMIT_REACHED':
        throw const WardrobeLimitReachedException();
      case 'INVALID_IMAGE':
        throw const InvalidImageException();
      case 'RATE_LIMITED':
        throw const RateLimitedException();
      default:
        final message = errJson?['error'] as String? ??
            '아이템 등록에 실패했습니다. [$status]';
        throw NetworkException(message);
    }
  }

  Future<WardrobeItem> _mockUpload({
    required String userId,
    required String category,
    String? subcategory,
    String? fit,
    String? pattern,
    String? brand,
    List<String>? styleTags,
    List<String>? season,
  }) async {
    debugPrint('[WardrobeRepository] Mock mode: simulating upload...');
    await Future<void>.delayed(const Duration(seconds: 3));
    final now = DateTime.now();
    return WardrobeItem(
      id: const Uuid().v4(),
      userId: userId,
      imageUrl: 'https://placehold.co/400x600/png?text=MOCK',
      category: category,
      subcategory: subcategory,
      colorHex: '#2196F3',
      colorName: 'Blue',
      styleTags: styleTags ?? [],
      fit: fit,
      pattern: pattern,
      brand: brand,
      season: season ?? ['spring', 'summer', 'fall', 'winter'],
      createdAt: now,
      updatedAt: now,
    );
  }
}
