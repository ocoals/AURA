import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/supabase_service.dart';
import '../models/match_result.dart';

class MatchRepository {
  bool get _useMock => dotenv.env['USE_MOCK']?.toLowerCase() == 'true';

  Future<MatchResult> analyzeReference({
    required Uint8List imageBytes,
  }) async {
    if (_useMock) return _mockAnalyze();

    final session = supabase.auth.currentSession;
    if (session == null) throw const AuthRequiredException();

    final baseUrl = dotenv.env['SUPABASE_URL']!;
    final url = Uri.parse('$baseUrl/functions/v1/recreate-analyze');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${session.accessToken}'
      ..files.add(http.MultipartFile.fromBytes(
        'reference_image',
        imageBytes,
        filename: 'reference.jpg',
      ));

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } on Exception catch (e) {
      debugPrint('[MatchRepository] Network error: $e');
      throw const NetworkException();
    }

    final body = await streamed.stream.bytesToString();
    final status = streamed.statusCode;

    if (status == 201) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return MatchResult.fromJson(json);
    }

    debugPrint('[MatchRepository] HTTP $status: $body');

    Map<String, dynamic>? errJson;
    try {
      errJson = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {}

    final code = errJson?['code'] as String? ?? '';
    switch (code) {
      case 'AUTH_REQUIRED':
        throw const AuthRequiredException();
      case 'RECREATION_LIMIT_REACHED':
        throw const RecreationLimitReachedException();
      case 'NO_FASHION_ITEMS':
        throw const NoFashionItemsException();
      case 'AI_TIMEOUT':
        throw const AiTimeoutException();
      case 'AI_ERROR':
        throw const AiErrorException();
      case 'INVALID_IMAGE':
        throw const InvalidImageException();
      case 'RATE_LIMITED':
        throw const RateLimitedException();
      default:
        final message =
            errJson?['error'] as String? ?? '분석에 실패했습니다. [$status]';
        throw NetworkException(message);
    }
  }

  Future<MatchResult> _mockAnalyze() async {
    debugPrint('[MatchRepository] Mock mode: simulating analyze...');
    await Future<void>.delayed(const Duration(seconds: 2));

    return MatchResult(
      id: const Uuid().v4(),
      overallScore: 72.5,
      referenceAnalysis: const ReferenceAnalysis(
        items: [
          AnalyzedItem(
            index: 0,
            category: 'tops',
            subcategory: '티셔츠',
            color: AnalyzedItemColor(hex: '#1A1A1A', name: '블랙'),
            style: ['캐주얼'],
            fit: 'regular',
          ),
          AnalyzedItem(
            index: 1,
            category: 'bottoms',
            subcategory: '청바지',
            color: AnalyzedItemColor(hex: '#2563EB', name: '블루'),
            style: ['캐주얼'],
            fit: 'slim',
          ),
          AnalyzedItem(
            index: 2,
            category: 'shoes',
            subcategory: '로퍼',
            color: AnalyzedItemColor(hex: '#8B4513', name: '브라운'),
            style: ['클래식'],
            fit: null,
          ),
        ],
        overallStyle: 'casual chic',
        occasion: 'daily',
      ),
      matchedItems: const [
        MatchedItem(
          refIndex: 0,
          wardrobeItem: MatchedWardrobeItem(
            id: 'mock-1',
            category: 'tops',
            subcategory: '티셔츠',
            colorHex: '#1A1A1A',
            colorName: '블랙',
            styleTags: ['캐주얼'],
            fit: 'regular',
          ),
          score: 95.0,
          breakdown: ScoreBreakdown(
            category: 40,
            color: 30,
            style: 20,
            bonus: 5,
          ),
          matchReasons: ['같은 티셔츠 소분류', '동일한 블랙 컬러', '캐주얼 스타일 일치'],
        ),
        MatchedItem(
          refIndex: 1,
          wardrobeItem: MatchedWardrobeItem(
            id: 'mock-2',
            category: 'bottoms',
            subcategory: '청바지',
            colorHex: '#2563EB',
            colorName: '블루',
            styleTags: ['캐주얼'],
            fit: 'slim',
          ),
          score: 85.0,
          breakdown: ScoreBreakdown(
            category: 40,
            color: 25,
            style: 15,
            bonus: 5,
          ),
          matchReasons: ['같은 청바지 소분류', '유사한 블루 톤'],
        ),
      ],
      gapItems: const [
        GapItem(
          refIndex: 2,
          category: 'shoes',
          description: '브라운 로퍼',
          searchKeywords: '브라운 로퍼 클래식',
          deeplinks: Deeplinks(
            musinsa: 'https://www.musinsa.com/search/goods?keyword=%EB%B8%8C%EB%9D%BC%EC%9A%B4+%EB%A1%9C%ED%8D%BC',
            ably: 'https://m.a-bly.com/search?keyword=%EB%B8%8C%EB%9D%BC%EC%9A%B4+%EB%A1%9C%ED%8D%BC',
            zigzag: 'https://zigzag.kr/search?keyword=%EB%B8%8C%EB%9D%BC%EC%9A%B4+%EB%A1%9C%ED%8D%BC',
          ),
        ),
      ],
    );
  }
}
