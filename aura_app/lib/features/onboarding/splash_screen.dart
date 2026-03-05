import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/gradient_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark status bar icons for light background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Navigate to home after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });

    return GradientBackground(
      gradient: AppGradients.bgSoft,
      child: Center(
        child: Text(
          'AURA',
          style: AppTypography.splashLogo.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
