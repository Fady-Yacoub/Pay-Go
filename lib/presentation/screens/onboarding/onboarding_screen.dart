import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 للهابتك فيدباك
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/auth_wrapper.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart'; // 🚀 زرارنا المطور
import 'package:payngo2/presentation/widgets/fade_in_animation.dart'; // 🚀 أنيميشننا المطور

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/onboarding_scan.png',
      'title': 'Scan Items Instantly',
      'subtitle': 'SMART SCANNING',
      'description': 'Simply point your camera at the clothing tag to add it to your digital cart in real-time.',
    },
    {
      'image': 'assets/images/onboarding_pay.png',
      'title': 'Secure Digital Payment',
      'subtitle': 'CASHLESS EXPERIENCE',
      'description': 'Checkout securely using your preferred method. No more long queues or waiting for change.',
    },
    {
      'image': 'assets/images/onboarding_go.png',
      'title': 'Fast Exit Pass',
      'subtitle': 'SMART VERIFICATION',
      'description': 'Show your secure QR code to the officer to verify your purchase and exit the store in seconds.',
    },
  ];

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      HapticFeedback.mediumImpact(); // اهتزاز خفيف عند البداية
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const AuthWrapper(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : Colors.white,
      // 🛡️ الحل لتداخل شريط الموبايل: SafeArea تحيط بالمحتوى التفاعلي فقط
      body: Stack(
        children: [
          // خلفية جمالية (Blobs)
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: AppColors.accent.withOpacity(isDark ? 0.05 : 0.03),
            ),
          ),

          Column(
            children: [
              // 1. Skip Button (Top Area)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FadeInAnimation(
                      direction: FadeDirection.right,
                      child: TextButton(
                        onPressed: () => _finishOnboarding(context),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : AppColors.greyLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. PageView (Content)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    return _OnboardingSlide(data: _onboardingData[index], isDark: isDark);
                  },
                ),
              ),

              // 3. Bottom Controls (Indicators & Button)
              Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, bottomPadding > 0 ? bottomPadding : 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pill Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppColors.accent : AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 🚀 استخدام الـ CustomButton المطور لحل الـ Lag وشكل التداخل
                    CustomButton(
                      text: _currentPage == _onboardingData.length - 1 ? 'GET STARTED' : 'CONTINUE',
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuart,
                          );
                        } else {
                          _finishOnboarding(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final Map<String, String> data;
  final bool isDark;

  const _OnboardingSlide({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        // 🚀 أنيميشن الصور
        FadeInAnimation(
          direction: FadeDirection.none,
          initialScale: 0.8,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Image.asset(data['image']!, fit: BoxFit.contain),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                data['subtitle']!,
                style: GoogleFonts.poppins(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data['title']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data['description']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}