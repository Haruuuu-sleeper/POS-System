import 'package:drift/drift.dart';
import 'package:pos_system/data/database/app_database.dart';
import 'package:pos_system/data/datasources/product_remote_datasource.dart';
import 'package:pos_system/data/models/product_dto.dart';

class PosRepository {
  final AppDatabase _db;
  final ProductRemoteDataSource _remoteDataSource;

  PosRepository({
    required AppDatabase db,
    required ProductRemoteDataSource remoteDataSource,
  }) : _db = db,
       _remoteDataSource = remoteDataSource;

  // --- READ / WATCH (Local Drift DB) ---

  Stream<List<Product>> watchProducts({bool onlyActive = true}) {
    final query = _db.select(_db.products);
    if (onlyActive) {
      query.where((tbl) => tbl.isActive.equals(true));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Future<List<Product>> getAllProducts() {
    return _db.select(_db.products).get();
  }

  Future<Product?> getProductById(int id) {
    return (_db.select(
      _db.products,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // --- CREATE / UPDATE / DELETE (Local Drift DB) ---

  Future<int> createProduct({
    required String sku,
    required String name,
    required int priceCents,
    String category = 'General',
    int stockQty = 0,
    bool isActive = true,
  }) {
    final companion = ProductsCompanion.insert(
      sku: Value(sku),
      name: name,
      category: Value(category),
      priceCents: priceCents,
      stockQty: Value(stockQty),
      isActive: Value(isActive),
    );
    return _db.into(_db.products).insert(companion);
  }

  Future<bool> updateProduct(Product product) {
    return _db.update(_db.products).replace(product);
  }

  Future<int> adjustStock(int productId, int deltaQty) async {
    return _db.transaction(() async {
      final current = await getProductById(productId);
      if (current == null) {
        throw StateError('Product not found (id: $productId)');
      }
      final nextStock = current.stockQty + deltaQty;
      if (nextStock < 0) {
        throw StateError('Insufficient stock for ${current.name}');
      }
      return (_db.update(_db.products)
            ..where((tbl) => tbl.id.equals(productId)))
          .write(ProductsCompanion(stockQty: Value(nextStock)));
    });
  }

  Future<int> deleteProduct(int id) {
    return (_db.delete(_db.products)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- SYNC (Remote API -> Local Drift DB) ---

  Future<int> syncProductsFromApi({int limit = 30}) async {
    final List<ProductDto> remoteProducts = await _remoteDataSource
        .fetchProducts(limit: limit);

    await _db.batch((batch) {
      for (final dto in remoteProducts) {
        batch.insert(
          _db.products,
          dto.toCompanion(),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    return remoteProducts.length;
  }
}
