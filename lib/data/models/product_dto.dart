import 'package:drift/drift.dart';
import 'package:pos_system/data/database/app_database.dart';

class ProductDto {
  final int id;
  final String title;
  final String category;
  final double price;
  final int stock;
  final String? sku;

  ProductDto({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.stock,
    this.sku,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? 'General').toString(),
      price: ((json['price'] ?? 0) as num).toDouble(),
      stock: ((json['stock'] ?? 0) as num).toInt(),
      sku: json['sku']?.toString(),
    );
  }

  ProductsCompanion toCompanion() {
    return ProductsCompanion.insert(
      sku: Value(sku != null && sku!.isNotEmpty ? sku! : 'API-$id'),
      name: title,
      category: Value(category.isNotEmpty ? category : 'General'),
      priceCents: (price * 100).round(),
      stockQty: Value(stock),
      isActive: const Value(true),
    );
  }
}
