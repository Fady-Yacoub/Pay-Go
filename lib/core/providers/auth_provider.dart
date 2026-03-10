import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_auth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart'; // مهم جداً لاستقلال المستخدم

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final google_auth.GoogleSignIn _googleSignIn = google_auth.GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false; // 🛡️ Safe Guard: عشان نعرف إننا خلصنا أول فحص داتا

  AuthProvider() {
    _initAuth();
  }

  // --- 🛠️ التحميل الذكي (Initialization) ---
  Future<void> _initAuth() async {
    // 🚀 الحل: خد حالة اليوزر فوراً أول ما الأبلكيشن يفتح
    _user = _auth.currentUser;

    // بمجرد ما قرأنا الحالة (سواء فيه يوزر أو لا)، نعتبره Initialized
    _isInitialized = true;
    notifyListeners();

    // وبعدين نفضل مراقبين أي تغيير يحصل في المستقبل
    _auth.authStateChanges().listen((User? user) {
      if (_user?.uid != user?.uid) {
        _user = user;
        notifyListeners();
      }
    });
  }

  // --- Getters ---
  User? get user => _user;
  String? get uid => _user?.uid; // 🔑 مفتاح استقلال البيانات
  bool get isAuthenticated => _user != null;
  bool get isGuest => _user?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  String get userFirstName {
    if (isGuest) return 'Guest';
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!.split(' ')[0];
    }
    return _user?.email?.split('@')[0] ?? 'User';
  }

  String? get userProfilePic => _user?.photoURL;

  // 🕵️ تسجيل الدخول كضيف (Anonymous) مع حفظ الحالة
  Future<void> signInAnonymously() async {
    _setLoading(true);
    try {
      await _auth.signInAnonymously();
      // حفظ الحالة محلياً للوصول السريع بدون انتظار الـ Syncing
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGuestMode', true);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint("Anonymous Sign-In Error: $e");
      rethrow;
    }
  }

  // 🔵 تسجيل الدخول بجوجل
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGuestMode', false); // نلغي حالة الضيف
      _setLoading(false);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      _setLoading(false);
      rethrow;
    }
  }

  // 🚪 خروج (تنظيف شامل للـ Cache والـ Session)
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      await _googleSignIn.signOut();

      // 🛡️ أهم خطوة لضمان استقلال المستخدم القادم: مسح الكاش
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      debugPrint("Sign Out Error: $e");
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}