import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/gradient_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

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
