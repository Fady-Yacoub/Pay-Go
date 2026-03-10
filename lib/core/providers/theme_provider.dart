import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payngo2/core/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false; // 🛡️ Safe Guard: لمنع الـ Flicker أول ما الأبلكيشن يفتح

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  // فحص ذكي للـ Dark Mode
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme(bool isOn) async {
    // 🚀 تحسين: لو الثيم هو هو، متبعنش إشارة تحديث عشان نوفر رامات
    if ((isOn && _themeMode == ThemeMode.dark) || (!isOn && _themeMode == ThemeMode.light)) return;

    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _updateSystemUI(isOn);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isOn);
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('isDarkMode')) {
        final bool isDarkSaved = prefs.getBool('isDarkMode') ?? false;
        _themeMode = isDarkSaved ? ThemeMode.dark : ThemeMode.light;
        _updateSystemUI(isDarkSaved);
      }
    } catch (e) {
      debugPrint("Theme Load Error: $e");
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // 🎨 تعديل "السر" لحل تداخل الـ Bottom Bar
  void _updateSystemUI(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,

        // 🚀 الحل: بنخليه شفاف تماماً عشان الـ SafeArea في الـ MainScreen هي اللي تتحكم
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}