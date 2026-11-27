import 'package:flutter/material.dart';

enum UserRole { admin, cashier }

class AppUser {
  final String id;
  final String fullName;
  final String username;
  final UserRole role;
  bool isActive;

  AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
    this.isActive = true,
  });
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class PosOrder {
  final String invoiceNo;
  final DateTime createdAt;
  final String cashierName;
  final List<CartItem> items;
  final double total;
  final double cashReceived;
  final double changeDue;

  PosOrder({
    required this.invoiceNo,
    required this.createdAt,
    required this.cashierName,
    required this.items,
    required this.total,
    required this.cashReceived,
    required this.changeDue,
  });
}

class PosStore extends ChangeNotifier {
  AppUser currentUser = AppUser(
    id: 'u1',
    fullName: 'System Admin',
    username: 'admin',
    role: UserRole.admin,
  );

  final List<AppUser> users = [
    AppUser(
      id: 'u1',
      fullName: 'System Admin',
      username: 'admin',
      role: UserRole.admin,
    ),
    AppUser(
      id: 'u2',
      fullName: 'Sokha Cashier',
      username: 'cashier1',
      role: UserRole.cashier,
    ),
  ];

  final List<Product> products = [
    Product(
      id: 'p1',
      name: 'Iced Americano',
      category: 'Drinks',
      price: 2.00,
      stock: 45,
    ),
    Product(
      id: 'p2',
      name: 'Matcha Latte',
      category: 'Drinks',
      price: 2.75,
      stock: 30,
    ),
    Product(
      id: 'p3',
      name: 'Croissant',
      category: 'Bakery',
      price: 2.25,
      stock: 18,
    ),
    Product(
      id: 'p4',
      name: 'Chicken Sandwich',
      category: 'Food',
      price: 3.50,
      stock: 12,
    ),
    Product(
      id: 'p5',
      name: 'Mineral Water',
      category: 'Drinks',
      price: 0.75,
      stock: 4,
    ),
    Product(
      id: 'p6',
      name: 'Chocolate Muffin',
      category: 'Bakery',
      price: 1.80,
      stock: 22,
    ),
  ];

  final List<CartItem> cart = [];
  final List<PosOrder> orders = [];

  List<String> get categories => [
    'All',
    ...products.map((p) => p.category).toSet(),
  ];

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.subtotal);

  double get todayRevenue => orders.fold(0, (sum, o) => sum + o.total);

  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= 5).toList();

  void setCurrentUser(AppUser user) {
    currentUser = user;
    notifyListeners();
  }

  // --- Cart Operations ---
  void addToCart(Product product) {
    if (product.stock <= 0) return;
    final index = cart.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      if (cart[index].quantity < product.stock) {
        cart[index].quantity++;
      }
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void updateCartQty(String productId, int delta) {
    final index = cart.indexWhere((c) => c.product.id == productId);
    if (index < 0) return;
    final newQty = cart[index].quantity + delta;
    if (newQty <= 0) {
      cart.removeAt(index);
    } else if (newQty <= cart[index].product.stock) {
      cart[index].quantity = newQty;
    }
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  PosOrder completeCheckout(double cashReceived) {
    final total = cartTotal;
    final orderItems = cart
        .map((c) => CartItem(product: c.product, quantity: c.quantity))
        .toList();

    for (final item in orderItems) {
      item.product.stock -= item.quantity;
    }

    final order = PosOrder(
      invoiceNo:
          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      createdAt: DateTime.now(),
      cashierName: currentUser.fullName,
      items: orderItems,
      total: total,
      cashReceived: cashReceived,
      changeDue: cashReceived - total,
    );

    orders.insert(0, order);
    cart.clear();
    notifyListeners();
    return order;
  }

  // --- Product CRUD ---
  void saveProduct({
    String? id,
    required String name,
    required String category,
    required double price,
    required int stock,
  }) {
    if (id == null) {
      products.add(
        Product(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          category: category,
          price: price,
          stock: stock,
        ),
      );
    } else {
      final index = products.indexWhere((p) => p.id == id);
      if (index >= 0) {
        products[index] = Product(
          id: id,
          name: name,
          category: category,
          price: price,
          stock: stock,
        );
      }
    }
    notifyListeners();
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    cart.removeWhere((c) => c.product.id == id);
    notifyListeners();
  }

  // --- User Management ---
  void addUser(String fullName, String username, UserRole role) {
    users.add(
      AppUser(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        username: username,
        role: role,
      ),
    );
    notifyListeners();
  }

  void toggleUserStatus(String id) {
    final user = users.firstWhere((u) => u.id == id);
    user.isActive = !user.isActive;
    notifyListeners();
  }
}
