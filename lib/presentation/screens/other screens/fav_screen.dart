import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 للهابتك فيدباك
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/cart_provider.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
          'My Wishlist',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            color: onSurface,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 🚀 استخدام Selector لضمان عدم حدوث Lag عند إضافة منتجات للسلة من شاشات تانية
      body: Selector<CartProvider, List<CartItem>>(
        selector: (_, provider) => provider.favoriteItems,
        builder: (context, favItems, _) {
          if (favItems.isEmpty) return _buildEmptyState(onSurface, isDark);

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 10, 24, MediaQuery.of(context).padding.bottom + 20),
            itemCount: favItems.length,
            itemBuilder: (context, index) {
              final product = favItems[index];
              return FadeInAnimation(
                delay: 50 * index, // سرعة أعلى للأداء البصري
                direction: FadeDirection.bottom,
                child: _buildFavoriteItem(context, product, isDark, onSurface),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color onSurface, bool isDark) {
    return FadeInAnimation(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 100, color: AppColors.accent.withOpacity(0.15)),
            const SizedBox(height: 24),
            Text(
              'Your wishlist is empty',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: onSurface),
            ),
            const SizedBox(height: 10),
            Text(
              'Save items you love to shop later!',
              style: GoogleFonts.poppins(color: onSurface.withOpacity(0.4), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, CartItem product, bool isDark, Color onSurface) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          // 🖼️ صورة المنتج مع لودينج ناعم
          _buildImage(product.image, isDark),

          const SizedBox(width: 16),

          // 📝 التفاصيل والتحكم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: onSurface),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        cart.toggleFavorite(product.id, product.name, product.price, product.image);
                      },
                      child: const Icon(Icons.favorite, color: AppColors.failed, size: 22),
                    ),
                  ],
                ),
                Text(
                  'EGP ${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // 🛒 زرار "إضافة للسلة" السريع
                // 🛒 زرار "إضافة للسلة" السريع في ملف fav_screen.dart
                CustomButton(
                  text: 'Add to Cart',
                  height: 40, // ✅ دلوقت هيفهمها
                  fontSize: 12, // ✅ ودي كمان هيفهمها
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    cart.addItem(product.id, product.name, product.price, product.image);
                    _showAddedSnackBar(context, product.name);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, bool isDark) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColors.greyLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: url.isNotEmpty
            ? Image.network(url, fit: BoxFit.cover)
            : const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  void _showAddedSnackBar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to cart!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}