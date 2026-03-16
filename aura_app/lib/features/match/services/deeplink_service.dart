import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/match_result.dart';

enum ShoppingPlatform {
  musinsa('무신사'),
  ably('에이블리'),
  zigzag('지그재그');

  const ShoppingPlatform(this.label);
  final String label;
}

abstract final class DeeplinkService {
  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('[DeeplinkService] Invalid URL: $url');
      return false;
    }

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    debugPrint('[DeeplinkService] Cannot launch URL: $url');
    return false;
  }

  static Future<bool> openDeeplink(
    Deeplinks deeplinks,
    ShoppingPlatform platform,
  ) {
    final url = switch (platform) {
      ShoppingPlatform.musinsa => deeplinks.musinsa,
      ShoppingPlatform.ably => deeplinks.ably,
      ShoppingPlatform.zigzag => deeplinks.zigzag,
    };
    return openUrl(url);
  }
}
