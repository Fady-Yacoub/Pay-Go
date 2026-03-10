import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payngo2/core/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double fontSize;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.fontSize = 16,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديد لون النص بناءً على حالة الزرار والثيم
    final Color effectiveTextColor = isOutlined
        ? (textColor ?? (isDark ? Colors.white : AppColors.accent))
        : (textColor ?? Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isOutlined
            ? _buildOutlinedButton(effectiveTextColor, isDark)
            : _buildElevatedButton(backgroundColor ?? AppColors.accent, effectiveTextColor, isDark),
      ),
    );
  }

  // 🔵 الزرار المملوء (بـ Gradient أو لون سادة)
  Widget _buildElevatedButton(Color bgColor, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: (useGradient && !isOutlined && !isLoading)
            ? AppColors.primaryGradient
            : null,
        boxShadow: [
          if (!isOutlined && !isLoading && !isDark)
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          HapticFeedback.lightImpact(); // اهتزاز خفيف للـ Feedback
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: (useGradient && !isOutlined) ? Colors.transparent : bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _buildButtonContent(textColor),
      ),
    );
  }

  // ⚪ الزرار الـ Outlined (للمهمات الثانوية مثل Cancel أو Guest)
  Widget _buildOutlinedButton(Color textColor, bool isDark) {
    return OutlinedButton(
      onPressed: isLoading ? null : () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(
            color: isDark ? Colors.white24 : AppColors.accent.withOpacity(0.5),
            width: 1.5
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  // ✨ محتوى الزرار (الأيقونة + النص) مع حماية الـ Overflow
  Widget _buildButtonContent(Color color) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
        key: const ValueKey('loading'),
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      )
          : Row(
        key: const ValueKey('text'),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // يمنع الـ Row من التمدد الزائد
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 4, color: color),
            const SizedBox(width: 8),
          ],
          // 🛡️ التعديل السحري: Flexible + FittedBox
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown, // بيصغر النص "فقط" لو المساحة ضاقت
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}