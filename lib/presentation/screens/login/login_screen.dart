import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 للهابتك فيدباك
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/auth_provider.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart'; // 🚀 استخدام الزرار المطور

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    // 🚀 نراقب الـ Provider عشان نعرف حالة التحميل (isLoading)
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // --- 1. Branding (اللوجو بشكل أنضف) ---
              FadeInAnimation(
                direction: FadeDirection.top,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'assets/images/logo_2.jpg',
                          fit: BoxFit.cover,
                          // 🚀 تحسين: لو الصورة لسه بتحمل من الـ Cache
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            return wasSynchronouslyLoaded ? child : AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(seconds: 1),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'PayNGo',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      'THE FUTURE OF SELF-CHECKOUT',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: onSurface.withOpacity(0.5),
                        letterSpacing: 4, // مسافات واسعة جداً بتدي شكل Branded
                      ),
                    )
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // --- 2. Action Buttons (استخدام الـ CustomButton المطور) ---
              FadeInAnimation(
                delay: 400,
                direction: FadeDirection.bottom,
                child: Column(
                  children: [
                    // 🔵 زرار جوجل (بريميوم بـ Gradient)
                    CustomButton(
                      text: 'Continue with Google',
                      icon: FontAwesomeIcons.google,
                      isLoading: authProvider.isLoading, // 🛡️ منع الضغط المتكرر
                      onPressed: () => _handleLogin(context, () => authProvider.signInWithGoogle()),
                    ),

                    const SizedBox(height: 16),

                    // 👤 زرار الضيف (Outlined لشكل أرقى)
                    CustomButton(
                      text: 'Continue as Guest',
                      icon: Icons.person_search_rounded,
                      isOutlined: true,
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleLogin(context, () => authProvider.signInAnonymously()),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // سياسة الخصوصية
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'By continuing, you agree to our Terms of Service',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: onSurface.withOpacity(0.25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛡️ Safe Guard: دالة لمعالجة الـ Errors ومنع الـ Lag
  void _handleLogin(BuildContext context, Future<void> Function() loginAction) async {
    HapticFeedback.mediumImpact(); // اهتزاز عند الضغط
    try {
      await loginAction();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Failed: ${e.toString()}"),
            backgroundColor: AppColors.failed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}