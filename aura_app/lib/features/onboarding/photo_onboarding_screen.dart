import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/gradient_background.dart';
import '../profile/repositories/profile_repository.dart';

enum _OnboardingStep { prompt, success, complete }

class PhotoOnboardingScreen extends StatefulWidget {
  const PhotoOnboardingScreen({super.key});

  @override
  State<PhotoOnboardingScreen> createState() => _PhotoOnboardingScreenState();
}

class _PhotoOnboardingScreenState extends State<PhotoOnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.prompt;
  int _registeredCount = 0;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null || !mounted) return;

    final result = await context.push<bool>(
      '/closet/add',
      extra: {'imagePath': picked.path, 'isOnboarding': true},
    );

    if (!mounted) return;
    if (result == true) {
      _registeredCount++;
      if (_registeredCount >= 3) {
        setState(() => _step = _OnboardingStep.complete);
      } else {
        setState(() => _step = _OnboardingStep.success);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _loading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await ProfileRepository().updateOnboardingCompleted(userId);
      await authNotifier.refresh();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return GradientBackground(
      gradient: AppGradients.bgOnboard,
      child: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildStep(),
                  ),
                ),
              ),
              if (_step == _OnboardingStep.prompt)
                Positioned(
                  top: 8,
                  right: 24,
                  child: TextButton(
                    onPressed: _loading ? null : _completeOnboarding,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0x66FFFFFF),
                            ),
                          )
                        : Text(
                            '건너뛰기',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0x99FFFFFF),
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

  Widget _buildStep() {
    switch (_step) {
      case _OnboardingStep.prompt:
        return _PromptStep(
          key: const ValueKey('prompt'),
          onPickImage: _pickImage,
        );
      case _OnboardingStep.success:
        return _SuccessStep(
          key: const ValueKey('success'),
          count: _registeredCount,
          onPickImage: _pickImage,
          onFinish: _completeOnboarding,
          loading: _loading,
        );
      case _OnboardingStep.complete:
        return _CompleteStep(
          key: const ValueKey('complete'),
          onStart: _completeOnboarding,
          loading: _loading,
        );
    }
  }
}

// --- Step 1: Prompt ---

class _PromptStep extends StatelessWidget {
  const _PromptStep({
    super.key,
    required this.onPickImage,
  });

  final Future<void> Function(ImageSource source) onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        const _ConcentricIcon(icon: Icons.camera_alt_outlined),
        const SizedBox(height: 40),
        Text(
          '첫 번째 옷을\n등록해볼까요?',
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
          '지금 입고 있는 옷이나\n갤러리에서 골라보세요',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            height: 1.7,
            color: const Color(0x73FFFFFF),
          ),
        ),
        const Spacer(flex: 4),
        // CTA buttons
        Row(
          children: [
            Expanded(
              child: _GlassButton(
                label: '사진 찍기',
                icon: Icons.camera_alt,
                onTap: () => onPickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassButton(
                label: '갤러리에서 선택',
                icon: Icons.photo_library,
                onTap: () => onPickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 52),
      ],
    );
  }
}

// --- Step 2: Success ---

class _SuccessStep extends StatefulWidget {
  const _SuccessStep({
    super.key,
    required this.count,
    required this.onPickImage,
    required this.onFinish,
    required this.loading,
  });

  final int count;
  final Future<void> Function(ImageSource source) onPickImage;
  final VoidCallback onFinish;
  final bool loading;

  @override
  State<_SuccessStep> createState() => _SuccessStepState();
}

class _SuccessStepState extends State<_SuccessStep> {
  bool _showPicker = false;

  @override
  void didUpdateWidget(covariant _SuccessStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _showPicker = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.count == 1
        ? '잘했어요!\n첫 아이템이 생겼어요'
        : '${widget.count}번째 아이템\n등록 완료!';

    return Column(
      children: [
        const Spacer(flex: 3),
        const _ConcentricIcon(icon: Icons.check_rounded),
        const SizedBox(height: 40),
        Text(
          title,
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
          '${widget.count}벌 등록 완료',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '3벌 이상 등록하면 재현이 더 정확해져요',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            height: 1.7,
            color: const Color(0x73FFFFFF),
          ),
        ),
        const Spacer(flex: 4),
        // CTA buttons with animated toggle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showPicker
              ? Row(
                  key: const ValueKey('picker'),
                  children: [
                    Expanded(
                      child: _GlassButton(
                        label: '사진 찍기',
                        icon: Icons.camera_alt,
                        onTap: () => widget.onPickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassButton(
                        label: '갤러리에서 선택',
                        icon: Icons.photo_library,
                        onTap: () => widget.onPickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('actions'),
                  children: [
                    Expanded(
                      child: _GlassButton(
                        label: '하나 더 등록하기',
                        icon: Icons.add,
                        onTap: () => setState(() => _showPicker = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassButton(
                        label: '일단 둘러볼게요',
                        icon: Icons.arrow_forward,
                        onTap: widget.loading ? null : widget.onFinish,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 52),
      ],
    );
  }
}

// --- Step 3: Complete ---

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({
    super.key,
    required this.onStart,
    required this.loading,
  });

  final VoidCallback onStart;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        const _ConcentricIcon(icon: Icons.star_rounded),
        const SizedBox(height: 40),
        Text(
          '옷장 준비 완료!',
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
          '이제 인플 코디를\n내 옷장으로 따라입어보세요',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            height: 1.7,
            color: const Color(0x73FFFFFF),
          ),
        ),
        const Spacer(flex: 4),
        // Gradient CTA button
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: loading ? null : onStart,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.ctaButton,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '시작하기',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 52),
      ],
    );
  }
}

// --- Shared widgets ---

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

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.glassStrong,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
