import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() => _loading = true);

    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('로그인 중 오류가 발생했습니다.');
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
                                const SizedBox(height: 24),

                                // Login button
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
                                        onTap: _loading ? null : _login,
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
                                                  '로그인',
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

                                // Signup link
                                GestureDetector(
                                  onTap: () => context.push('/signup'),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: 13,
                                        color: AppColors.ter,
                                      ),
                                      children: [
                                        const TextSpan(text: '계정이 없으신가요? '),
                                        TextSpan(
                                          text: '회원가입',
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
