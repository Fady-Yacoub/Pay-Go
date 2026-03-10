import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payngo2/core/providers/auth_provider.dart';
import 'package:payngo2/presentation/screens/main/main_screen.dart';
import 'package:payngo2/presentation/screens/login/login_screen.dart';
import 'package:payngo2/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:payngo2/presentation/screens/splash/splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  // فحص هل اليوزر شاف الـ Onboarding قبل كده؟
  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showOnboarding = !(prefs.getBool('hasSeenOnboarding') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 1. لو لسه Firebase بيفتح أو بنقرأ الـ SharedPreferences
    if (!authProvider.isInitialized || _showOnboarding == null) {
      return const SplashScreen(); // يفضل في السبلش لحد ما الداتا تجهز
    }

    // 2. لو يوزر جديد خالص، يروح للـ Onboarding
    if (_showOnboarding!) {
      return const OnboardingScreen();
    }

    // 3. لو مسجل دخول (يوزر أو ضيف) يروح للـ Main
    if (authProvider.isAuthenticated || authProvider.isGuest) {
      return const MainScreen();
    }

    // 4. غير كده يروح للوجين
    return const LoginScreen();
  }
}