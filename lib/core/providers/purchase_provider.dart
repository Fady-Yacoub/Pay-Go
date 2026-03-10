import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 ضروري لعزل البيانات

class PurchaseRecord {
  final String orderId;
  final double totalAmount;
  final DateTime date;
  final List<String> itemsNames;

  PurchaseRecord({
    required this.orderId,
    required this.totalAmount,
    required this.date,
    required this.itemsNames,
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'totalAmount': totalAmount,
    'date': date.toIso8601String(),
    'itemsNames': itemsNames,
  };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
    orderId: json['orderId'],
    totalAmount: (json['totalAmount'] as num).toDouble(), // 🛡️ Safe guard تحويل الأرقام
    date: DateTime.parse(json['date']),
    itemsNames: List<String>.from(json['itemsNames']),
  );
}

class PurchaseProvider with ChangeNotifier {
  List<PurchaseRecord> _history = [];
  bool _isInitialized = false; // 🛡️ لمنع ظهور "Syncing your data" المتكرر

  List<PurchaseRecord> get history => [..._history];
  bool get isInitialized => _isInitialized;

  // مفتاح ديناميكي مربوط بكل UID مستقل
  String get _historyKey => 'history_${FirebaseAuth.instance.currentUser?.uid ?? "guest"}';

  PurchaseProvider() {
    _loadHistory();
  }

  // 🔄 تحديث البيانات فوراً عند تبديل المستخدم
  void refreshHistory() {
    _isInitialized = false;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyData = prefs.getString(_historyKey);

      if (historyData != null) {
        final List<dynamic> decodedData = jsonDecode(historyData);
        _history = decodedData.map((item) => PurchaseRecord.fromJson(item)).toList();
        _history.sort((a, b) => b.date.compareTo(a.date));
      } else {
        _history = []; // تصفير السجل لو مستخدم جديد
      }
    } catch (e) {
      debugPrint("Load History Error: $e");
      _history = [];
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(_history.map((item) => item.toJson()).toList());
      await prefs.setString(_historyKey, encodedData);
    } catch (e) {
      debugPrint("Save History Error: $e");
    }
  }

  void addPurchase({required double amount, required List<String> items}) {
    final newRecord = PurchaseRecord(
      orderId: 'PAY-${DateTime.now().millisecondsSinceEpoch}', // ID احترافي أكتر
      totalAmount: amount,
      date: DateTime.now(),
      itemsNames: items,
    );

    _history.insert(0, newRecord);
    notifyListeners(); // 🚀 تحديث الـ UI فوراً
    _saveHistory(); // الحفظ في الخلفية
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
    _saveHistory();
  }

  double get totalSpent => _history.fold(0, (sum, item) => sum + item.totalAmount);
}