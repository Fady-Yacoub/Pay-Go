import 'package:flutter/material.dart';

class AppColors {
  // --- 🔵 الألوان الأساسية (The Identity) ---
  static const Color primary = Color(0xFF1E3A8A); // الكحلي الملكي
  static const Color accent = Color(0xFF42A5F5);  // السماوي النشط
  static const Color secondary = Color(0xFF0EA5E9); // درجة وسيطة للـ Gradients

  // --- ⚫ درجات الـ Dark Mode (Deep & Pure) ---
  static const Color black = Color(0xFF0F0F0F);        // أسود أعمق للفخامة
  static const Color backgroundDark = Color(0xFF121212); // خلفية الشاشات
  static const Color surfaceDark = Color(0xFF1E1E1E);    // لون الكروت والـ Dialogs
  static const Color borderDark = Color(0xFF2D2D2D);     // حدود خفيفة جداً للـ UI

  // --- ⚪ درجات الـ Light Mode (Clean & Crisp) ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);   // كروت الوضع الفاتح
  static const Color greyLight = Color(0xFFF8FAFC);
  static const Color greyMedium = Color(0xFFE2E8F0);
  static const Color textGrey = Color(0xFF64748B);

  // --- 🟢🔴 الحالات (Semantic Colors) ---
  static const Color success = Color(0xFF10B981); // أخضر مريح للعين
  static const Color failed = Color(0xFFEF4444);  // أحمر تحذيري
  static const Color warning = Color(0xFFF59E0B); // للـ Pending Transactions

  // --- ✨ ألوان الـ Performance (الـ Shimmer) ---
  // دي هنستخدمها عشان نعمل لودينج "شيك" وسريع بدل الـ Syncing data التقيلة
  static Color get shimmerBase => Colors.grey.withOpacity(0.05);
  static Color get shimmerHighlight => Colors.grey.withOpacity(0.1);

  // --- 🧪 مساعدات الـ Glassmorphism (للأداء البصري المريح) ---
  static Color glassWhite(double opacity) => white.withOpacity(opacity);
  static Color glassBlack(double opacity) => black.withOpacity(opacity);

  // تدرج لوني بريميوم للـ Buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}