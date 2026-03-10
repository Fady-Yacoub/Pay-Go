import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/cart_provider.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart';
import 'package:payngo2/presentation/widgets/custom_text_field.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/screens/payment/payment_selection_screen.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

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
          'My Cart',
          style: GoogleFonts.poppins(color: onSurface, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.read<CartProvider>().clearCart(),
            child: Text('Clear', style: GoogleFonts.poppins(color: AppColors.failed, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) return _buildEmptyState(onSurface);

          return Column(
            children: [
              // 1. القائمة (استخدام ListView بـ BouncingScroll)
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return FadeInAnimation(
                      delay: 30 * index,
                      direction: FadeDirection.left,
                      child: _buildCartItem(context, item, isDark, onSurface),
                    );
                  },
                ),
              ),

              // 2. الملخص السفلي
              _buildBottomSummary(context, cart, isDark, onSurface),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, bool isDark, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // الصورة - حجم ثابت ومحكوم
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(item.image, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),

          // 🛡️ المُنقذ الأول: Expanded بيجبر المحتوى يلم نفسه
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('EGP ${item.price.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),

                // 🛡️ Row الكمية والحذف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // استخدام Flexible هنا يمنع الـ Overflow لو الأرقام كبرت
                    Flexible(child: _QuantitySelector(item: item)),
                    GestureDetector(
                      onTap: () => context.read<CartProvider>().removeItem(item.id),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.failed, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider cart, bool isDark, Color onSurface) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🛡️ منطقة الـ Promo Code (الأكثر عرضة للـ Overflow)
          Row(
            children: [
              const Expanded( // 🚀 التكست فيلد يفرش في المساحة المتاحة "فقط"
                child: CustomTextField(
                  hintText: "Promo Code",
                  prefixIcon: Icons.local_offer_outlined,
                ),
              ),
              const SizedBox(width: 10),
              // تحديد عرض ثابت وصغير للزرار لمنع الـ Overflow
              CustomButton(
                text: "APPLY",
                width: 80,
                height: 45,
                fontSize: 12,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 15),

          _summaryRow('Subtotal', 'EGP ${cart.subtotal.toStringAsFixed(2)}', onSurface, false),
          _summaryRow('VAT (14%)', 'EGP ${cart.taxAmount.toStringAsFixed(2)}', onSurface, false),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(thickness: 0.5)),
          _summaryRow('Total', 'EGP ${cart.totalWithTax.toStringAsFixed(2)}', AppColors.accent, true),

          const SizedBox(height: 20),
          CustomButton(
            text: 'CHECKOUT NOW',
            icon: Icons.shopping_bag_outlined,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentSelectionScreen())),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🛡️ حتى الكلام لو طويل ميبوظش السطر
        Expanded(child: Text(label, style: GoogleFonts.poppins(color: color.withOpacity(isBold ? 1 : 0.6), fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500))),
        Text(value, style: GoogleFonts.poppins(color: color, fontSize: isBold ? 16 : 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState(Color onSurface) {
    return Center(child: Text('Your cart is empty', style: GoogleFonts.poppins(color: onSurface.withOpacity(0.3))));
  }
}

class _QuantitySelector extends StatelessWidget {
  final CartItem item;
  const _QuantitySelector({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      // 🛡️ استخدام FittedBox بيخلي المحتوى "يصغر" لو المساحة ضاقت بدل ما يعمل Error
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _qBtn(Icons.remove, () => cart.decreaseItemQuantity(item.id)),
            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _qBtn(Icons.add, () => cart.addItem(item.id, item.name, item.price, item.image)),
          ],
        ),
      ),
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: AppColors.accent),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      padding: EdgeInsets.zero,
    );
  }
}