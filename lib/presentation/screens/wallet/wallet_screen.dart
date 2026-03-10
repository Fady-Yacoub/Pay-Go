import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 للهابتك فيدباك
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/transaction_provider.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _selectedMethod = 'Mastercard';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.greyLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'MY WALLET',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: onSurface,
              fontSize: 16,
              letterSpacing: 2
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. الكارت الملكي (Animated & Glassmorphic)
            SliverToBoxAdapter(
              child: FadeInAnimation(
                direction: FadeDirection.top,
                child: _buildPremiumCard(isDark),
              ),
            ),

            // 2. عنوان طرق الدفع
            _buildSectionHeader('Payment Methods', onSurface),

            // 3. قائمة طرق الدفع
            SliverToBoxAdapter(
              child: FadeInAnimation(
                delay: 200,
                direction: FadeDirection.none,
                child: _buildPaymentMethods(isDark),
              ),
            ),

            // 4. عنوان المعاملات الحديثة
            _buildSectionHeader('Recent Transactions', onSurface),

            // 5. قائمة المعاملات الحقيقية (محسنة بالأداء)
            _buildTransactionList(isDark, onSurface),

            // مساحة أمان تحت عشان الـ Floating Bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // --- 🎨 الكارت البريميوم الجديد ---
  Widget _buildPremiumCard(bool isDark) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        double total = provider.transactions.fold(0, (sum, item) => sum + item.amount);

        return Container(
          height: 210,
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: AppColors.primaryGradient, // 🚀 التدرج الموحد بتاعنا
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Stack(
            children: [
              // دوائر جمالية خلفية
              Positioned(
                top: -20, right: -20,
                child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.contactless_outlined, color: Colors.white, size: 28),
                        Text('PLATINUM USER', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Balance', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(
                          'EGP ${total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('**** **** **** 4219', style: GoogleFonts.poppins(color: Colors.white, letterSpacing: 3, fontSize: 14, fontWeight: FontWeight.w600)),
                        const FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 30),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _methodTile(FontAwesomeIcons.ccMastercard, 'Mastercard', '**** 4242', const Color(0xFFEB001B), isDark),
          const SizedBox(height: 12),
          _methodTile(FontAwesomeIcons.applePay, 'Apple Pay', 'Default Wallet', isDark ? Colors.white : Colors.black, isDark),
        ],
      ),
    );
  }

  Widget _methodTile(IconData icon, String title, String sub, Color iconColor, bool isDark) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMethod = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent, width: 2),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: FaIcon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(sub, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(bool isDark, Color onSurface) {
    return Selector<TransactionProvider, List>(
      // 🚀 تحسين الأداء: الشاشة مش هتعمل Rebuild إلا لو لستة المعاملات اتغيرت فعلياً
      selector: (_, provider) => provider.transactions,
      builder: (context, transactions, _) {
        if (transactions.isEmpty) return _buildEmptyState(onSurface);

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final tx = transactions[index];
                return FadeInAnimation(
                  delay: 50 * index,
                  direction: FadeDirection.left,
                  child: _transactionTile(tx, isDark, onSurface),
                );
              },
              childCount: transactions.length,
            ),
          ),
        );
      },
    );
  }

  Widget _transactionTile(dynamic tx, bool isDark, Color onSurface) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🛡️ Safe Guard لاستخدام min بشكل صحيح
                Text('Order #${tx.id.substring(0, min(tx.id.length as int, 6))}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(DateFormat('dd MMM, hh:mm a').format(tx.date),
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('EGP ${tx.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.failed, fontSize: 14)),
              const SizedBox(height: 6),
              _statusBadge(tx.isVerified),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: verified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        verified ? 'VERIFIED' : 'PAID',
        style: GoogleFonts.poppins(color: verified ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(Icons.receipt_long_rounded, size: 70, color: color.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text('No Transactions Yet', style: GoogleFonts.poppins(color: color.withOpacity(0.3))),
            ],
          ),
        ),
      ),
    );
  }
}