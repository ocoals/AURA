import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/gradient_background.dart';
import '../profile/repositories/profile_repository.dart';
import '../../app/router.dart';

class PhotoOnboardingScreen extends StatefulWidget {
  const PhotoOnboardingScreen({super.key});

  @override
  State<PhotoOnboardingScreen> createState() => _PhotoOnboardingScreenState();
}

class _PhotoOnboardingScreenState extends State<PhotoOnboardingScreen> {
  bool _loading = false;

  Future<void> _onSkip() async {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1AFFFFFF),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: Color(0xD9FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                '사진 한 장이면 AI가 자동으로\n옷을 분석하고 등록해요',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  height: 1.7,
                  color: const Color(0x73FFFFFF),
                ),
              ),
              const Spacer(flex: 4),
              // Skip button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _loading ? null : _onSkip,
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
              const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }
}
