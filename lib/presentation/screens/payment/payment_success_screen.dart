import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/transaction_provider.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {

  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();
  }

  void _shareReceipt(dynamic tx) {
    final String text = '''
🧾 PayNGo - Digital Receipt
--------------------------
Order ID: ${tx.id}
OTP: ${tx.otp}
Total: EGP ${tx.amount.toStringAsFixed(2)}
--------------------------
Show this QR at the exit.
Thank you for shopping! 🚀
''';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    final txProvider = context.read<TransactionProvider>();
    final lastTx = txProvider.transactions.first;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          _buildTopBanner(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.black : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    // الـ QR Code والتعليمات
                    FadeInAnimation(
                      delay: 300,
                      direction: FadeDirection.top,
                      child: _buildExitTicket(lastTx, isDark, onSurface),
                    ),

                    const SizedBox(height: 35),

                    FadeInAnimation(
                      delay: 500,
                      child: _buildInfoCard(lastTx, isDark, onSurface),
                    ),

                    const SizedBox(height: 40),

                    _buildActionButtons(context, lastTx),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const FadeInAnimation(
              direction: FadeDirection.top,
              child: Icon(Icons.check_circle_rounded, size: 90, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              'PAYMENT SUCCESSFUL',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎫 الـ Ticket مع النص الاسترشادي الجديد
  Widget _buildExitTicket(dynamic tx, bool isDark, Color onSurface) {
    return Column(
      children: [
        // 🚀 النص الاسترشادي الجديد
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Present this QR code to the security officer at the exit for a quick verification.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'EXIT PASS',
          style: GoogleFonts.poppins(
              letterSpacing: 8,
              fontWeight: FontWeight.w900,
              color: AppColors.accent.withOpacity(0.3),
              fontSize: 14
          ),
        ),
        const SizedBox(height: 20),

        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                    color: AppColors.accent.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 15)
                )
              ],
            ),
            child: QrImageView(
              data: 'PAYNGO-${tx.id}',
              version: QrVersions.auto,
              size: 190.0,
              foregroundColor: AppColors.black,
              gapless: true,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'VERIFICATION CODE',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
        Text(
          tx.otp,
          style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.accent, letterSpacing: 10),
        ),
      ],
    );
  }

  Widget _buildInfoCard(dynamic tx, bool isDark, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.greyLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
      ),
      child: Column(
        children: [
          _row('Transaction ID', tx.id.substring(tx.id.length - 8).toUpperCase(), onSurface),
          const SizedBox(height: 12),
          _row('Date', DateFormat('dd MMM, hh:mm a').format(tx.date), onSurface),
          const SizedBox(height: 12),
          _row('Items', '${tx.items.length} Units', onSurface),
          const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider(thickness: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL PAID', style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 16)),
              Text('EGP ${tx.amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.accent, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic tx) {
    return Column(
      children: [
        FadeInAnimation(
          delay: 700,
          direction: FadeDirection.bottom,
          child: CustomButton(
            text: 'BACK TO HOME',
            icon: Icons.home_filled,
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            _shareReceipt(tx);
          },
          icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.accent),
          label: Text(
            'SHARE RECEIPT',
            style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}