import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/presentation/screens/product/product_details_screen.dart';
import 'package:payngo2/presentation/widgets/custom_button.dart'; // 🚀 زرارنا المطور
import 'package:payngo2/presentation/widgets/custom_text_field.dart'; // 🚀 التكست فيلد المطور

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isScanCompleted = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // الأنيميشن بقا محلي داخل الـ Frame مش واخد الشاشة كلها
    _animation = Tween<double>(begin: 10, end: 210).animate(_animationController);
  }

  Future<void> _fetchProductFromFirebase(String barcode) async {
    if (!mounted) return;

    try {
      // لودينج "شيك" وغير مزعج بصرياً
      _showLoadingDialog();

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Products')
          .doc(barcode)
          .get();

      if (mounted) Navigator.pop(context); // إغلاق اللودينج

      if (doc.exists && doc.data() != null) {
        HapticFeedback.vibrate(); // اهتزاز نجاح المسح
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: barcode,
                productName: data['name'] ?? 'Product',
                productPrice: data['price']?.toString() ?? '0.0',
                productImage: data['image'] ?? '',
                productDescription: data['description'] ?? '',
              ),
            ),
          ).then((_) {
            if (mounted) setState(() => isScanCompleted = false);
          });
        }
      } else {
        _handleError("Product not found! ($barcode)");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _handleError("Connection error. Please try again.");
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (isScanCompleted) return;
    final String? code = capture.barcodes.first.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() => isScanCompleted = true);
      _fetchProductFromFirebase(code.contains('payngo://') ? code.split('/').last : code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = isDark ? Colors.white : AppColors.black;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: onSurface, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SMART SCANNER',
          style: GoogleFonts.poppins(color: onSurface, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 🚀 الـ Scanner Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    MobileScanner(controller: controller, onDetect: _handleBarcode),
                    _buildScannerOverlay(),
                  ],
                ),
              ),
            ),
            // 🚀 الـ Controls تحت مع الـ SafeArea
            _buildBottomArea(onSurface, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: RepaintBoundary( // 🛡️ عزل الأنيميشن تماماً للأداء
        child: Container(
          width: 230, height: 230,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    top: _animation.value,
                    left: 15, right: 15,
                    child: child!,
                  );
                },
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(color: AppColors.accent.withOpacity(0.6), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomArea(Color onSurface, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'Align barcode within the frame to scan',
            style: GoogleFonts.poppins(color: onSurface.withOpacity(0.4), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // زر الفلاش الدائري
              _flashButton(isDark),
              const SizedBox(width: 16),
              // زر الإدخال اليدوي المطور
              Expanded(
                child: CustomButton(
                  text: "ENTER MANUALLY",
                  icon: Icons.keyboard_rounded,
                  onPressed: () => _showManualEntryDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flashButton(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await controller.toggleTorch();
        setState(() => _isFlashOn = !_isFlashOn);
      },
      child: Container(
        height: 56, width: 56,
        decoration: BoxDecoration(
          color: _isFlashOn ? AppColors.accent : (isDark ? AppColors.surfaceDark : AppColors.greyLight),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          _isFlashOn ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
          color: _isFlashOn ? Colors.white : AppColors.accent,
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
          child: const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
        ),
      ),
    );
  }

  void _handleError(String msg) {
    // 🚀 تم التعديل هنا لاهتزاز "تنبيه" بدل الخطأ البرمجي
    HapticFeedback.vibrate();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.failed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
    setState(() => isScanCompleted = false);
  }

  void _showManualEntryDialog() {
    String manualCode = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('Manual Entry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: CustomTextField(
          hintText: "Enter Product Code",
          prefixIcon: Icons.edit_note_rounded,
          onChanged: (v) => manualCode = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          CustomButton(
            text: "SEARCH",
            width: 120,
            onPressed: () {
              if (manualCode.isNotEmpty) {
                Navigator.pop(context);
                setState(() => isScanCompleted = true);
                _fetchProductFromFirebase(manualCode);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }
}