import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // Lobster styles
  static TextStyle splashLogo = const TextStyle(
    fontFamily: 'Lobster',
    fontSize: 72,
    color: AppColors.white,
  );

  static TextStyle loginLogo = const TextStyle(
    fontFamily: 'Lobster',
    fontSize: 56,
    color: AppColors.primary,
  );

  static TextStyle pageTitle = const TextStyle(
    fontFamily: 'Lobster',
    fontSize: 32,
    color: AppColors.ink,
  );

  static TextStyle matchScore = const TextStyle(
    fontFamily: 'Lobster',
    fontSize: 64,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  // Noto Sans KR styles (via Google Fonts)
  static TextStyle get onboardingHeading => GoogleFonts.notoSansKr(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle get statNumber => GoogleFonts.notoSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get sectionTitle => GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get body => GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get caption => GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.ter,
      );

  static TextStyle get subtitle => GoogleFonts.notoSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.sec,
      );
}
