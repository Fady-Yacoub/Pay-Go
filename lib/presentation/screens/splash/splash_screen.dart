import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/presentation/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // 🛡️ Safe Guard: ضبط السيستم بار فوراً لمنع التداخل البصري
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent, // شفاف تماماً
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    final prefs = await SharedPreferences.getInstance();

    // 🚀 تحسين: قراءة سريعة للثيم لتحديد الفيديو المناسب
    bool isDark = prefs.getBool('isDarkMode') ??
        (WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

    final String videoPath = isDark ? 'assets/videos/PAYNGO3.mp4' : 'assets/videos/PAYNGO2.mp4';

    _videoController = VideoPlayerController.asset(videoPath);

    try {
      // 🛡️ تحسين الأداء: تهيئة الفيديو في الخلفية
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _videoController!.setLooping(false);
          _videoController!.play();
        });

        // تشغيل أنيميشن التكست بعد ثانية من الفيديو
        Timer(const Duration(milliseconds: 500), () => _textController.forward());

        // الانتقال بعد انتهاء الفيديو أو 4 ثوانٍ كحد أقصى
        Future.delayed(const Duration(seconds: 4), _navigateToNext);
      }
    } catch (e) {
      debugPrint("❌ Splash Video Error: $e");
      _textController.forward();
      Future.delayed(const Duration(seconds: 2), _navigateToNext);
    }
  }

  void _navigateToNext() {
    if (!mounted) return;

    // 🚀 العودة لوضع الـ Edge-to-Edge قبل الخروج لضمان استقرار الشاشة القادمة
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : Colors.white,
      // 💡 شيلنا الـ SafeArea من هنا عشان الفيديو يفرش الشاشة كلها بشكل Cinematic
      // والـ SafeArea هنستخدمها في الـ Onboarding والـ MainScreen بس.
      body: Stack(
        children: [
          // 1. الفيديو في الخلفية (Center)
          Center(
            child: _isVideoInitialized
                ? FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
                : const SizedBox(),
          ),

          // 2. الكلام واللوجو (Bottom)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'PAY&GO',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A NEW ERA OF SMART RETAIL',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white24 : Colors.black26,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}