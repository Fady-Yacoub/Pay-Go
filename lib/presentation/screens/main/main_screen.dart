import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/presentation/screens/cart/shopping_cart_screen.dart';
import 'package:payngo2/presentation/screens/home/home_screen.dart';
import 'package:payngo2/presentation/screens/profile/profile_screen.dart';
import 'package:payngo2/presentation/screens/wallet/wallet_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WalletScreen(),
    const ShoppingCartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // 🛡️ Safe Guard: يمنع الخروج المباشر
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        extendBody: true, // 🟢 مهم عشان الـ App يفرش تحت الـ Nav Bar
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        // 🛡️ الحل الجذري لتداخل زراير الجهاز: SafeArea حول الـ Nav Bar فقط
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: _buildModernNavBar(isDark),
        ),
      ),
    );
  }

  void _handleBackPress() {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    } else {
      _showExitDialog();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Exit Pay&Go?"),
        content: const Text("Are you sure you want to close the app?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text("Exit", style: TextStyle(color: AppColors.failed)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavBar(bool isDark) {
    // 🚀 تحسين الأداء: عزل الـ Bar في RepaintBoundary
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10), // تقليل الـ bottom لأن الـ SafeArea بيقوم بالواجب
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Home", isDark),
            _buildNavItem(1, Icons.account_balance_wallet_rounded, "Wallet", isDark),
            _buildNavItem(2, Icons.shopping_basket_rounded, "Cart", isDark),
            _buildNavItem(3, Icons.person_rounded, "Profile", isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.selectionClick(); // 🚀 رد فعل اهتزازي بريميوم
          setState(() => _selectedIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack, // حركة "سوستة" خفيفة
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : (isDark ? Colors.white30 : Colors.grey[400]),
              size: isSelected ? 26 : 24,
            ),
            // 🚀 تصحيح الـ Error اللي كان عندك: استخدام .only(top: 4) بشكل سليم
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}