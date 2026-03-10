import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/cart_provider.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart';
import 'package:payngo2/presentation/widgets/fade_in_animation.dart';
import 'package:payngo2/presentation/screens/cart/shopping_cart_screen.dart'; // 🚀 للتنقل للسلة

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String productPrice;
  final String productImage;
  final String productDescription;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with TickerProviderStateMixin {
  late String name, price, image, desc;
  bool isSyncing = false;

  // 🚀 المتحكم في أنيميشن نبضة الكارت
  late AnimationController _cartIconController;

  @override
  void initState() {
    super.initState();
    name = widget.productName;
    price = widget.productPrice;
    image = widget.productImage;
    desc = widget.productDescription;

    // تهيئة أنيميشن النبضة (Pulse)
    _cartIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.3,
    );

    if (name == "Loading..." || name.isEmpty) {
      _fetchLatestData();
    }
  }

  @override
  void dispose() {
    _cartIconController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestData() async {
    if (!mounted) return;
    setState(() => isSyncing = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('Products').doc(widget.productId).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? 'Unknown Item';
          price = data['price']?.toString() ?? '0.0';
          image = data['image'] ?? "";
          desc = data['description'] ?? "No description available.";
          isSyncing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDark, onSurface),
          SliverToBoxAdapter(
            child: FadeInAnimation(
              direction: FadeDirection.bottom,
              child: _buildProductBody(onSurface, isDark),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: _buildBottomAction(onSurface, isDark),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark, Color onSurface) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: isDark ? AppColors.black : Colors.white,
      leading: _buildCircleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context), isDark, onSurface),
      actions: [
        // 🚀 أيقونة السلة الماركة مع الـ Badge والأنيميشن
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            return ScaleTransition(
              scale: _cartIconController,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  _buildCircleBtn(
                      Icons.shopping_bag_outlined,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCartScreen())),
                      isDark, onSurface
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: FadeInAnimation(
                        direction: FadeDirection.none,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.failed, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${widget.productId}',
          child: image.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
          )
              : Container(color: AppColors.greyMedium),
        ),
      ),
    );
  }

  Widget _buildProductBody(Color onSurface, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("NEW COLLECTION", style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              Text("EGP $price", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface, height: 1.1)),
          const SizedBox(height: 24),
          const Divider(thickness: 0.5),
          const SizedBox(height: 24),
          Text("Description", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
          const SizedBox(height: 12),
          Text(desc, style: GoogleFonts.poppins(color: onSurface.withOpacity(0.5), height: 1.7, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(Color onSurface, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          _buildFavBtn(),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: isSyncing ? "SYNCING..." : "ADD TO CART",
              icon: Icons.add_shopping_cart_rounded,
              isLoading: isSyncing,
              onPressed: _handleAddToCart,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    if (isSyncing) return;

    // 1. اهتزاز الموبايل
    HapticFeedback.mediumImpact();

    // 2. تشغيل أنيميشن النبضة لأيقونة الكارت اللي فوق
    _cartIconController.forward().then((_) => _cartIconController.reverse());

    // 3. إضافة المنتج للسلة فعلياً
    context.read<CartProvider>().addItem(widget.productId, name, double.tryParse(price) ?? 0.0, image);

    // 4. إظهار سناك بار شيك جداً وأنيميشن خفيف
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Added to cart successfully!', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.fromLTRB(50, 0, 50, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildFavBtn() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        bool isFav = cart.isFavorite(widget.productId);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            cart.toggleFavorite(widget.productId, name, double.tryParse(price) ?? 0.0, image);
          },
          child: Container(
            height: 56, width: 56,
            decoration: BoxDecoration(
              color: isFav ? AppColors.failed.withOpacity(0.1) : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : AppColors.greyLight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppColors.failed : AppColors.accent),
          ),
        );
      },
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, bool isDark, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        child: IconButton(icon: Icon(icon, color: onSurface, size: 18), onPressed: onTap),
      ),
    );
  }
}