import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/cart_provider.dart';
import 'package:payngo2/core/providers/transaction_provider.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/screens/payment/payment_success_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  int _selectedMethodIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    // 🚀 تحسين الأداء: استخدام Select لجلب القيم المطلوبة فقط ومنع Rebuild الشاشة بالكامل
    final totalAmount = context.select<CartProvider, double>((p) => p.totalWithTax);
    final subtotal = context.select<CartProvider, double>((p) => p.subtotal);
    final tax = context.select<CartProvider, double>((p) => p.taxAmount);
    final count = context.select<CartProvider, int>((p) => p.itemCount);

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.greyLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CHECKOUT',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: onSurface,
              fontSize: 16,
              letterSpacing: 1.5
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Order Summary (Premium Glass Look) ---
                  FadeInAnimation(
                    direction: FadeDirection.top,
                    child: _buildOrderSummary(totalAmount, subtotal, tax, count, isDark, onSurface),
                  ),

                  const SizedBox(height: 35),

                  // --- 2. Payment Methods Title ---
                  FadeInAnimation(
                    delay: 200,
                    direction: FadeDirection.none,
                    child: Text(
                      'Select Payment Method',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildPaymentMethodsList(isDark, onSurface),
                ],
              ),
            ),
          ),

          // --- 3. Bottom Pay Button (🛡️ Protected by SafeArea) ---
          _buildBottomPayArea(context, totalAmount, isDark),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double total, double sub, double tax, int count, bool isDark, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL AMOUNT',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accent, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'EGP ${total.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w900, color: onSurface, letterSpacing: -1),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(thickness: 0.5),
          ),
          _summaryRow('Subtotal', 'EGP ${sub.toStringAsFixed(2)}', onSurface),
          const SizedBox(height: 14),
          _summaryRow('VAT (14%)', 'EGP ${tax.toStringAsFixed(2)}', onSurface),
          const SizedBox(height: 14),
          _summaryRow('Items', '$count Units', onSurface),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color onSurface) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: onSurface, fontSize: 14)),
      ],
    );
  }

  Widget _buildPaymentMethodsList(bool isDark, Color onSurface) {
    final methods = [
      {'icon': FontAwesomeIcons.apple, 'name': 'Apple Pay', 'sub': 'Secure Quick Pay'},
      {'icon': FontAwesomeIcons.ccMastercard, 'name': 'Mastercard', 'sub': '**** 4219'},
      {'icon': FontAwesomeIcons.paypal, 'name': 'PayPal', 'sub': 'abdo@payngo.com'},
    ];

    return Column(
      children: List.generate(methods.length, (index) {
        bool isSelected = _selectedMethodIndex == index;
        return FadeInAnimation(
          delay: 300 + (index * 80),
          direction: FadeDirection.left,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedMethodIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.accent : (isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                      methods[index]['icon'] as IconData,
                      color: isSelected ? AppColors.accent : onSurface.withOpacity(0.4),
                      size: 22
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(methods[index]['name'] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: onSurface)),
                        Text(methods[index]['sub'] as String, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isSelected ? AppColors.accent : Colors.grey.withOpacity(0.3),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomPayArea(BuildContext context, double total, bool isDark) {
    // 🛡️ الحل الجذري لتداخل أزرار الجهاز: استخدام SafeArea مع MediaQuery padding
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: CustomButton(
        text: 'PAY EGP ${total.toStringAsFixed(2)}',
        icon: Icons.lock_outline_rounded,
        onPressed: () => _processPayment(context),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    HapticFeedback.heavyImpact();

    final cart = context.read<CartProvider>();
    final txProvider = context.read<TransactionProvider>();

    // 1. تسجيل المعاملة
    txProvider.addTransaction(
      cart.items.values.toList(),
      cart.totalWithTax,
    );

    // 2. تفريغ السلة
    cart.clearCart();

    // 3. التوجه لصفحة النجاح
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const PaymentSuccessScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
            (route) => route.isFirst,
      );
    }
  }
}