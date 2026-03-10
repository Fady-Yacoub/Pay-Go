import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:payngo2/core/app_colors.dart';
import 'package:payngo2/core/providers/theme_provider.dart';
import 'package:payngo2/core/providers/transaction_provider.dart';
import 'package:payngo2/core/providers/auth_provider.dart';
import 'package:payngo2/core/providers/cart_provider.dart';
import 'package:payngo2/core/providers/purchase_provider.dart';
import 'package:payngo2/presentation/screens/splash/splash_screen.dart';
import 'package:payngo2/presentation/screens/product/product_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 تحسين أداء الـ Firebase لبدء التشغيل الفوري
  try {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firebase Setup Error: $e");
  }

  // 🛡️ ضبط السيستم بار (Edge-to-Edge) لضمان عدم تداخل الأزرار من أول لحظة
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
      ],
      child: const PayNgoApp(),
    ),
  );
}

class PayNgoApp extends StatefulWidget {
  const PayNgoApp({super.key});

  @override
  State<PayNgoApp> createState() => _PayNgoAppState();
}

class _PayNgoAppState extends State<PayNgoApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // فحص اللينك الافتتاحي (Cold Start)
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleDeepLink(initialUri);

    // الاستماع للينكات والـ App شغال
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'payngo' && uri.host == 'product') {
      final productId = uri.pathSegments.last;

      // 🛡️ Safe Guard: التأكد من إن الـ Navigator جاهز قبل الانتقال
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: productId,
              productName: "Loading...", // هيتم تحميل البيانات داخل الشاشة
              productPrice: "0",
              productImage: "",
              productDescription: "Fetching product via secure link...",
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 تحسين الأداء: استخدام Selector لمراقبة الـ ThemeMode فقط
    return Selector<ThemeProvider, ThemeMode>(
      selector: (_, provider) => provider.themeMode,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'PayNGo',
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,

          // --- 🎨 ثيم الـ Premium (Light) ---
          theme: _buildTheme(Brightness.light),

          // --- 🎨 ثيم الـ Premium (Dark) ---
          darkTheme: _buildTheme(Brightness.dark),

          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.black : Colors.white,
      colorSchemeSeed: AppColors.accent,

      // 🚀 تحسين سرعة التنقل (Cupertino Transitions) في كل الأجهزة
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ضبط الخطوط لتقليل الـ Loading Lag
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),

      // ستايل الـ AppBar الموحد لمنع التداخل مع الـ StatusBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),

      // ستايل الكروت لمنع الـ Overdraw (أداء أسرع)
      cardTheme: CardThemeData( // ✅ تم تغيير الاسم لـ CardThemeData
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: isDark ? AppColors.surfaceDark : Colors.white,
      ),

      // 🧪 تحسين تفاعل اللمس (Splash Effect)
      splashFactory: InkSparkle.splashFactory,
    );
  }
}