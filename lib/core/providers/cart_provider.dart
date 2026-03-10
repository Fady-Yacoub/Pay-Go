import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 ضروري لمعرفة الـ UID

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'price': price, 'image': image, 'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'], name: map['name'], price: map['price'],
    image: map['image'], quantity: map['quantity'],
  );
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> _favoriteItems = {};

  // 🛡️ مفتاح استقلالية المستخدم
  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

  CartProvider() {
    _loadDataFromPrefs();
  }

  // Getters
  Map<String, CartItem> get items => {..._items};
  List<CartItem> get favoriteItems => _favoriteItems.values.toList();
  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, item) => total += item.price * item.quantity);
    return total;
  }
  double get taxAmount => subtotal * 0.14;
  double get totalWithTax => subtotal + taxAmount;

  // --- 💾 حفظ وقراءة البيانات (مع عزل المستخدمين) ---

  Future<void> _saveDataToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = _currentUid;

      // حفظ السلة بـ Key فريد لكل UID
      final cartData = json.encode(_items.map((key, value) => MapEntry(key, value.toMap())));
      await prefs.setString('cart_$uid', cartData);

      // حفظ المفضلات بـ Key فريد لكل UID
      final favData = json.encode(_favoriteItems.map((key, value) => MapEntry(key, value.toMap())));
      await prefs.setString('fav_$uid', favData);
    } catch (e) {
      debugPrint("Storage Error: $e");
    }
  }

  Future<void> _loadDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = _currentUid;

      // تحميل بيانات السلة الخاصة بالمستخدم الحالي فقط
      if (prefs.containsKey('cart_$uid')) {
        final String? cartRaw = prefs.getString('cart_$uid');
        if (cartRaw != null) {
          final Map<String, dynamic> decoded = json.decode(cartRaw);
          _items = decoded.map((key, value) => MapEntry(key, CartItem.fromMap(value)));
        }
      } else {
        _items = {}; // تصفير لو مستخدم جديد
      }

      // تحميل بيانات المفضلات الخاصة بالمستخدم الحالي فقط
      if (prefs.containsKey('fav_$uid')) {
        final String? favRaw = prefs.getString('fav_$uid');
        if (favRaw != null) {
          final Map<String, dynamic> decoded = json.decode(favRaw);
          _favoriteItems = decoded.map((key, value) => MapEntry(key, CartItem.fromMap(value)));
        }
      } else {
        _favoriteItems = {};
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  // دالة مهمة جداً يتم مناداتها عند تغيير المستخدم (Login/Logout)
  void refreshDataForNewUser() {
    _loadDataFromPrefs();
  }

  // --- 🛒 العمليات (مع تحسين الأداء) ---

  void addItem(String barcode, String name, double price, String image) {
    if (_items.containsKey(barcode)) {
      _items[barcode]!.quantity += 1;
    } else {
      _items[barcode] = CartItem(id: barcode, name: name, price: price, image: image);
    }
    notifyListeners();
    _saveDataToPrefs(); // 🚀 حفظ في الخلفية بدون تعطيل الـ UI
  }

  void decreaseItemQuantity(String barcode) {
    if (!_items.containsKey(barcode)) return;
    if (_items[barcode]!.quantity > 1) {
      _items[barcode]!.quantity -= 1;
    } else {
      _items.remove(barcode);
    }
    notifyListeners();
    _saveDataToPrefs();
  }

  void removeItem(String barcode) {
    _items.remove(barcode);
    notifyListeners();
    _saveDataToPrefs();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveDataToPrefs();
  }

  void toggleFavorite(String barcode, String name, double price, String image) {
    if (_favoriteItems.containsKey(barcode)) {
      _favoriteItems.remove(barcode);
    } else {
      _favoriteItems[barcode] = CartItem(id: barcode, name: name, price: price, image: image);
    }
    notifyListeners();
    _saveDataToPrefs();
  }

  bool isFavorite(String barcode) => _favoriteItems.containsKey(barcode);
}