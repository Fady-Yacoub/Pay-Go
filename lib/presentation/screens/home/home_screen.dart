import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/cart_provider.dart';
import 'package:payngo2/core/providers/auth_provider.dart';
import 'package:payngo2/presentation/screens/qr_scan/qr_scan_screen.dart';
import 'package:payngo2/presentation/screens/profile/profile_screen.dart'; // 🚀 للذهاب للبروفايل
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/screens/other%20screens/fav_screen.dart';
import 'package:payngo2/presentation/screens/cart/shopping_cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(onSurface),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F0F0F), AppColors.black]
                : [const Color(0xFFF8F9FA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                // --- 1. Header (Welcome + User Avatar) ---
                Selector<AuthProvider, AuthProvider>(
                  selector: (_, provider) => provider,
                  builder: (context, auth, _) {
                    return FadeInAnimation(
                      delay: 100,
                      direction: FadeDirection.top,
                      child: _buildHeader(context, auth, onSurface, isDark),
                    );
                  },
                ),

                const SizedBox(height: 35),

                // --- 2. Quick Stats (Cart & Wishlist) ---
                FadeInAnimation(
                  delay: 300,
                  direction: FadeDirection.right,
                  child: const _QuickStatsRow(),
                ),

                const SizedBox(height: 50),

                // --- 3. The Animated Scan Center ---
                const FadeInAnimation(
                  delay: 500,
                  direction: FadeDirection.bottom,
                  child: _ScanSection(),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color onSurface) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            'STORE #4219 - 6TH OCT',
            style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w800,
                letterSpacing: 2, color: onSurface.withOpacity(0.4)
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  // 🎨 الـ Header المطور بصورة المستخدم
  Widget _buildHeader(BuildContext context, AuthProvider auth, Color onSurface, bool isDark) {
    final user = auth.user;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: GoogleFonts.poppins(fontSize: 14, color: onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
            ),
            Text(
              '${auth.userFirstName} 👋',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 30, color: onSurface, letterSpacing: -0.5),
            ),
          ],
        ),

        // 🚀 الأفاتار بستايل البروفايل (Clickable)
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.greyLight,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Icon(Icons.person_rounded, size: 28, color: AppColors.accent.withOpacity(0.5))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// --- 📊 ويدجت الإحصائيات (عزل الـ Rebuilds) ---
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // كارت السلة (مراقب للـ CartProvider)
        Consumer<CartProvider>(
          builder: (context, cart, _) => _buildStatCard(
            context, 'My Cart', '${cart.itemCount} Items',
            Icons.shopping_bag_outlined, isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCartScreen())),
          ),
        ),
        const SizedBox(width: 16),
        // كارت المفضلات
        Consumer<CartProvider>(
          builder: (context, cart, _) => _buildStatCard(
            context, 'Wishlist', '${cart.favoriteItems.length} Saved',
            Icons.favorite_rounded, isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, bool isDark, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w600)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 📸 ويدجت الـ Scan (Isolated Animation) ---
class _ScanSection extends StatelessWidget {
  const _ScanSection();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    return Column(
      children: [
        Center(
          child: RepaintBoundary(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.12),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulseCircle(200 * value, AppColors.accent.withOpacity(0.05)),
                    _buildPulseCircle(165 * value, AppColors.accent.withOpacity(0.08)),
                    child!,
                  ],
                );
              },
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScanScreen())),
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 45),
                      const SizedBox(height: 8),
                      Text('SCAN', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 45),
        Text('Ready to shop?', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: onSurface)),
        const SizedBox(height: 10),
        Text(
          'Point your camera at any product barcode\nto add it to your digital cart instantly.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: onSurface.withOpacity(0.4), fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildPulseCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}