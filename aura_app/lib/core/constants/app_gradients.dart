import 'package:flutter/material.dart';

abstract final class AppGradients {
  /// 일반 화면 배경 (Home, Closet, Match, My)
  static const bgSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8E4F8), // 0%
      Color(0xFFDDE4F8), // 30%
      Color(0xFFD8E8FA), // 55%
      Color(0xFFE4F2FC), // 100%
    ],
    stops: [0.0, 0.30, 0.55, 1.0],
  );

  /// 온보딩 / 스플래시 A 배경
  static const bgOnboard = LinearGradient(
    begin: Alignment(-0.5, -1.0),
    end: Alignment(0.5, 1.0),
    colors: [
      Color(0xFF4F46E5), // 0%
      Color(0xFF6366F1), // 40%
      Color(0xFF7C3AED), // 100%
    ],
    stops: [0.0, 0.40, 1.0],
  );

  /// CTA 버튼 그라디언트
  static const ctaButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
    ],
  );
}
