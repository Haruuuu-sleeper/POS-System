import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text().withDefault(const Constant('cashier'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sku => text().nullable()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant('General'))();
  IntColumn get priceCents => integer()();
  IntColumn get costPriceCents => integer().withDefault(const Constant(0))();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()();
  IntColumn get subtotalCents => integer()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();
  IntColumn get totalCents => integer()();
  TextColumn get paymentMethod => text()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get qty => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get lineTotalCents => integer()();
}

class CheckoutLineInput {
  final int productId;
  final int qty;
  final int unitPriceCents;

  const CheckoutLineInput({
    required this.productId,
    required this.qty,
    required this.unitPriceCents,
  });
}

@DriftDatabase(tables: [Users, Products, Orders, OrderItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(users);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pos_system_db');
  }

  Future<int> createOrderWithStockDeduction({
    required String orderNumber,
    required int subtotalCents,
    required int discountCents,
    required int totalCents,
    required String paymentMethod,
    required List<CheckoutLineInput> items,
  }) {
    return transaction(() async {
      final orderId = await into(orders).insert(
        OrdersCompanion.insert(
          orderNumber: orderNumber,
          subtotalCents: subtotalCents,
          discountCents: Value(discountCents),
          totalCents: totalCents,
          paymentMethod: paymentMethod,
        ),
      );

      for (final item in items) {
        final product = await (select(
          products,
        )..where((tbl) => tbl.id.equals(item.productId))).getSingle();

        if (product.stockQty < item.qty) {
          throw StateError('Insufficient stock for ${product.name}');
        }

        final lineTotal = item.qty * item.unitPriceCents;

        await into(orderItems).insert(
          OrderItemsCompanion.insert(
            orderId: orderId,
            productId: item.productId,
            qty: item.qty,
            unitPriceCents: item.unitPriceCents,
            lineTotalCents: lineTotal,
          ),
        );

        await (update(
          products,
        )..where((tbl) => tbl.id.equals(item.productId))).write(
          ProductsCompanion(stockQty: Value(product.stockQty - item.qty)),
        );
      }

      return orderId;
    });
  }
}
