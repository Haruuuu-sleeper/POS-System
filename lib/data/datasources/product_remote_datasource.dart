import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_system/data/models/product_dto.dart';

class ProductRemoteDataSource {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<List<ProductDto>> fetchProducts({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/products')
        .replace(queryParameters: {'limit': limit.toString()});

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load products (HTTP ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = (decoded['products'] as List<dynamic>? ?? []);

    return rawList
        .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
