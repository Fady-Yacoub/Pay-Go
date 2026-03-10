import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/transaction_provider.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
          'ORDERS HISTORY',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: onSurface,
              fontSize: 16,
              letterSpacing: 1.5
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 🛡️ SafeArea هنا بتحمي الـ List من التداخل مع زراير الموبايل
      body: SafeArea(
        child: Selector<TransactionProvider, List<Transaction>>(
          // 🚀 تحسين: الشاشة مش هتعمل Rebuild إلا لو لستة المعاملات اتغيرت
          selector: (_, provider) => provider.transactions,
          builder: (context, transactions, _) {
            if (transactions.isEmpty) {
              return _buildEmptyState(onSurface);
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 10, 24, MediaQuery.of(context).padding.bottom + 20),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return FadeInAnimation(
                  delay: 50 * index, // سرعة أعلى لتقليل إحساس الـ Lag
                  direction: FadeDirection.bottom,
                  child: _buildTransactionCard(context, tx, isDark, onSurface),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction tx, bool isDark, Color onSurface) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // أيقونة المتجر بلمسة الـ Brand
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${tx.id.substring(tx.id.length - 6).toUpperCase()}", // عرض آخر 6 أرقام بس لشكل أنضف
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: onSurface),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(tx.date),
                      style: GoogleFonts.poppins(color: onSurface.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                'EGP ${tx.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.accent, fontSize: 16),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(thickness: 0.5, height: 1),
          ),

          // عرض المنتجات بشكل "Chips" أو نص منظم
          Text(
            'PURCHASED ITEMS',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.accent),
          ),
          const SizedBox(height: 10),
          Text(
            tx.items.map((i) => i.name).join('  •  '), // فاصل أشيك
            style: GoogleFonts.poppins(color: onSurface.withOpacity(0.6), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          // البادج وعدد العناصر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(tx.isVerified),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '${tx.items.length} Items',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isVerified) {
    final Color statusColor = isVerified ? AppColors.success : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            isVerified ? 'VERIFIED' : 'PENDING EXIT',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color onSurface) {
    return FadeInAnimation(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 100, color: AppColors.accent.withOpacity(0.15)),
            const SizedBox(height: 24),
            Text(
                'No orders yet',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.5))
            ),
            const SizedBox(height: 10),
            Text(
              'Your transaction history will appear here.',
              style: GoogleFonts.poppins(color: onSurface.withOpacity(0.3), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}