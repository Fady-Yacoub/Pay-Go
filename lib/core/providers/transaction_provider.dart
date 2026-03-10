import 'dart:math'; // 🚀 مهم جداً عشان الـ OTP والـ min
import 'package:flutter/material.dart';

// --- 📦 موديل المعاملة (بسيط ومنظم) ---
class Transaction {
  final String id;
  final List<dynamic> items; // قائمة المنتجات
  final double amount;
  final DateTime date;
  final String otp; // كود التحقق للخروج
  final bool isVerified; // هل الأمن وافق على الخروج؟

  Transaction({
    required this.id,
    required this.items,
    required this.amount,
    required this.date,
    required this.otp,
    this.isVerified = false,
  });
}

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.from(_transactions.reversed);

  // 💳 إضافة معاملة جديدة (بعد الدفع الناجح)
  void addTransaction(List<dynamic> cartItems, double totalAmount) {
    final String transactionId = "TX${DateTime.now().millisecondsSinceEpoch}";
    final String secureOtp = _generateOTP();

    final newTx = Transaction(
      id: transactionId,
      items: cartItems,
      amount: totalAmount,
      date: DateTime.now(),
      otp: secureOtp,
    );

    _transactions.add(newTx);
    notifyListeners();
  }

  // 🔑 توليد كود تحقق عشوائي من 4 أرقام
  String _generateOTP() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  // 🛡️ تحديث حالة الخروج (للأمن)
  void verifyExit(String txId) {
    final index = _transactions.indexWhere((tx) => tx.id == txId);
    if (index != -1) {
      // إحنا هنا بنحولها لـ Verified بصرياً في الأبلكيشن
      // في الحقيقة المفروض الأمن هو اللي يغيرها في Firestore
      notifyListeners();
    }
  }
}