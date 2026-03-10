import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/theme_provider.dart';
import 'package:payngo2/core/providers/auth_provider.dart';
import 'package:payngo2/presentation/screens/login/login_screen.dart';
import 'package:payngo2/presentation/screens/wallet/wallet_screen.dart';
import 'package:payngo2/presentation/screens/other%20screens/fav_screen.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  void _handleThemeChange(BuildContext context, bool value) {
    HapticFeedback.mediumImpact();
    context.read<ThemeProvider>().toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    // 🚀 نراقب الـ AuthProvider هنا في الـ Build Method
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.greyLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PROFILE',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              color: onSurface,
              fontSize: 16,
              letterSpacing: 2
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                children: [
                  // 1. بروفايل هيدر (تم تمرير الـ authProvider كـ Parameter)
                  FadeInAnimation(
                    direction: FadeDirection.top,
                    child: _buildProfileHeader(authProvider, isDark, onSurface),
                  ),

                  const SizedBox(height: 40),

                  // 2. قائمة الخيارات
                  _buildOptionsList(context, isDark),

                  const SizedBox(height: 40),

                  // 3. زرار تسجيل الخروج
                  FadeInAnimation(
                    delay: 500,
                    direction: FadeDirection.bottom,
                    child: CustomButton(
                      text: "LOG OUT",
                      icon: Icons.logout_rounded,
                      backgroundColor: AppColors.failed.withOpacity(0.1),
                      textColor: AppColors.failed,
                      useGradient: false,
                      isLoading: _isLoggingOut,
                      onPressed: () => _handleLogout(authProvider),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          if (_isLoggingOut)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),
        ],
      ),
    );
  }

  // 🛠️ تم تعديل الدالة لتستقبل الـ AuthProvider كاملاً
  Widget _buildProfileHeader(AuthProvider authProvider, bool isDark, Color onSurface) {
    final user = authProvider.user; // استخراج بيانات المستخدم من الـ Provider

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person_rounded, size: 60, color: AppColors.accent.withOpacity(0.5))
                    : null,
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          authProvider.userFirstName, // ✅ الآن سيعمل بدون Errors
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: onSurface),
        ),
        Text(
          user?.email ?? 'PayNGo User',
          style: GoogleFonts.poppins(color: onSurface.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildOptionsList(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildOptionItem(
          delay: 100,
          icon: Icons.favorite_rounded,
          title: 'My Wishlist',
          isDark: isDark,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
        ),
        _buildOptionItem(
          delay: 200,
          icon: Icons.account_balance_wallet_rounded,
          title: 'Wallet & Payments',
          isDark: isDark,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
        ),
        _buildOptionItem(
          delay: 300,
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          title: 'Dark Mode',
          isDark: isDark,
          trailing: Switch.adaptive(
            value: isDark,
            activeColor: AppColors.accent,
            onChanged: (v) => _handleThemeChange(context, v),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required int delay,
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return FadeInAnimation(
      delay: delay,
      direction: FadeDirection.left,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : AppColors.black)),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _handleLogout(AuthProvider auth) async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoggingOut = true);

    await auth.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}