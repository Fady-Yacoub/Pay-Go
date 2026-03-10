import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payngo2/core/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Iterable<String>? autofillHints; // 🚀 ميزة الحفظ التلقائي (UX)

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 تحديد الألوان باستخدام السيستم الجديد (AppColors)
    final Color fillCol = isDark ? AppColors.surfaceDark : AppColors.white;
    final Color textCol = isDark ? Colors.white : AppColors.black;
    final Color hintCol = isDark ? Colors.white30 : AppColors.textGrey.withOpacity(0.6);

    return Container(
      // 🛡️ Safe Guard: إضافة ظل خفيف جداً بدل الحدود التقيلة لتقليل الـ Lag
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        cursorColor: AppColors.accent, // 🚀 لون المؤشر براند
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: textCol,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: hintCol,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.accent.withOpacity(0.7), size: 20)
              : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          filled: true,
          fillColor: fillCol,

          // --- 🛠️ Borders (نسخة الـ Modern Fintech) ---
          border: _buildBorder(isDark ? AppColors.borderDark : AppColors.greyMedium),
          enabledBorder: _buildBorder(isDark ? AppColors.borderDark : AppColors.greyMedium),

          // عند الوقوف على الحقل (Focus)
          focusedBorder: _buildBorder(AppColors.accent, width: 1.5),

          // عند الخطأ
          errorBorder: _buildBorder(AppColors.failed.withOpacity(0.5)),
          focusedErrorBorder: _buildBorder(AppColors.failed, width: 1.5),

          errorStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.failed),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), // زيادة الـ Radius للفخامة
      borderSide: BorderSide(color: color, width: width),
    );
  }
}