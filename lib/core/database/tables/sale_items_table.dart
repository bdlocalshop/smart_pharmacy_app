import 'package:drift/drift.dart';
import '../converters.dart';
import 'pharmacy_settings_table.dart';
import 'sales_table.dart';
import 'products_table.dart';
import 'product_batches_table.dart';

/// Sales invoice line items (FEFO audit ledger).
@DataClassName('SaleItem')
class SaleItemsTable extends Table {
  @override
  String get tableName => 'sale_items';

  TextColumn get id => text()(); // UUIDv4
  TextColumn get pharmacyUid => text().references(PharmacySettingsTable, #pharmacyUid)();
  TextColumn get saleId => text().references(SalesTable, #id)();
  TextColumn get productId => text().references(ProductsTable, #id)();
  TextColumn get batchId => text().references(ProductBatchesTable, #id)();
  IntColumn get quantity => integer()();
  RealColumn get unitCostPrice => real()(); // Historical cost at moment of sale
  RealColumn get unitSellingPrice => real()(); // Historical selling price
  RealColumn get lineTotal => real()();
  TextColumn get createdAt => text().map(const IsoDateTimeConverter())();
  TextColumn get deletedAt => text().map(const IsoDateTimeConverter()).nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();

  @override
  Set<Column> get primaryKey => {id};
}

