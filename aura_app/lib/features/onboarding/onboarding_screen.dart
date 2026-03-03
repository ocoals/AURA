import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../shared/widgets/gradient_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.checkroom,
      title: '인플루언서 코디,\n내 옷장으로 따라입기',
      subtitle: '인스타에서 본 코디를 새 옷 없이\n이미 가진 옷으로 재현하세요',
      cta: '다음',
    ),
    _SlideData(
      icon: Icons.camera_alt,
      title: '사진 한 장이면 끝,\n30초 옷장 등록',
      subtitle: 'AI가 배경을 제거하고\n색상과 카테고리를 자동 분석해요',
      cta: '다음',
    ),
    _SlideData(
      icon: Icons.document_scanner,
      title: 'AI 코디 매칭으로\n나만의 스타일 완성',
      subtitle: '원하는 코디 사진만 올리면\n내 옷장에서 최적 조합을 찾아줘요',
      cta: '시작하기',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  void _onBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final topPadding = MediaQuery.of(context).padding.top;

    return GradientBackground(
      gradient: AppGradients.bgOnboard,
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: SizedBox.expand(
          child: Column(
            children: [
              // Top bar: back + skip
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding + 8,
                  left: 24,
                  right: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (slides 2, 3 only)
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _onBack,
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: Color(0xB3FFFFFF),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 32),
                    // Skip button
                    GestureDetector(
                      onTap: _onSkip,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        child: Text(
                          '건너뛰기',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            color: const Color(0x66FFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _SlidePage(data: _slides[i]),
                ),
              ),

              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.white
                          : const Color(0x40FFFFFF),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CTA button
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 52,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.glassStrong,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onNext,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  _slides[_currentPage].cta,
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Private data class ---

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
}

// --- Slide page ---

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.data});

  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          const Spacer(flex: 3),
          _ConcentricIcon(icon: data.icon),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: -0.3,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              height: 1.7,
              color: const Color(0x73FFFFFF),
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

// --- Concentric circles icon ---

class _ConcentricIcon extends StatelessWidget {
  const _ConcentricIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x0FFFFFFF),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x0FFFFFFF),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 44,
              color: const Color(0xD9FFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}
