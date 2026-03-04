import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/gradient_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('모든 항목을 입력해주세요.');
      return;
    }

    if (password.length < 6) {
      _showError('비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    if (password != confirm) {
      _showError('비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() => _loading = true);

    try {
      await supabase.auth.signUp(email: email, password: password);
      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('회원가입 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE4F2FC),
      body: GradientBackground(
        child: SizedBox.expand(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: 28,
                    right: 28,
                  ),
                  child: Column(
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 20,
                                  color: AppColors.ter,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Logo
                      Text('Aura', style: AppTypography.loginLogo),
                      const SizedBox(height: 6),
                      Text(
                        'STYLE REIMAGINED',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          color: AppColors.ter,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Form card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.glass,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Email field
                                _GlassTextField(
                                  controller: _emailController,
                                  hintText: '이메일',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),

                                // Password field
                                _GlassTextField(
                                  controller: _passwordController,
                                  hintText: '비밀번호',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 14),

                                // Confirm password field
                                _GlassTextField(
                                  controller: _confirmController,
                                  hintText: '비밀번호 확인',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 24),

                                // Signup button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.ctaButton,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _loading ? null : _signup,
                                        borderRadius: BorderRadius.circular(14),
                                        child: Center(
                                          child: _loading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: AppColors.white,
                                                      ),
                                                )
                                              : Text(
                                                  '회원가입',
                                                  style: GoogleFonts.notoSansKr(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Login link
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: 13,
                                        color: AppColors.ter,
                                      ),
                                      children: [
                                        const TextSpan(text: '이미 계정이 있으신가요? '),
                                        TextSpan(
                                          text: '로그인',
                                          style: GoogleFonts.notoSansKr(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Legal notice
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 11,
                                      color: AppColors.mute,
                                    ),
                                    children: [
                                      const TextSpan(text: '가입 시 '),
                                      TextSpan(
                                        text: '이용약관',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => launchUrl(
                                                Uri.parse(
                                                    AppConstants.termsUrl),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              ),
                                      ),
                                      const TextSpan(text: ' 및 '),
                                      TextSpan(
                                        text: '개인정보처리방침',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => launchUrl(
                                                Uri.parse(
                                                    AppConstants.privacyUrl),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              ),
                                      ),
                                      const TextSpan(text: '에 동의합니다.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Glass-style text field ---

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.notoSansKr(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.notoSansKr(fontSize: 14, color: AppColors.mute),
        filled: true,
        fillColor: const Color(0x33FFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
      ),
    );
  }
}
