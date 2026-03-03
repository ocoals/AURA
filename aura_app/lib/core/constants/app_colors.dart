import 'dart:ui';

abstract final class AppColors {
  // Primary (Brand)
  static const primary = Color(0xFF4F46E5);
  static const indigo = Color(0xFF6366F1);
  static const violet = Color(0xFF7C3AED);

  // Neutral (Text / Background)
  static const ink = Color(0xFF1A1A1A);
  static const sec = Color(0xFF555555);
  static const ter = Color(0xFF999999);
  static const mute = Color(0xFFC0C0C0);
  static const white = Color(0xFFFFFFFF);

  // Glass
  static const glass = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const glassStrong = Color(0xD1FFFFFF); // rgba(255,255,255,0.82)
  static const glassBorder = Color(0x73FFFFFF); // rgba(255,255,255,0.45)

  // Semantic
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Social Login
  static const kakaoYellow = Color(0xFFFEE500);
  static const kakaoText = Color(0xFF1A1A1A);
  static const appleBlack = Color(0xFF000000);
}
