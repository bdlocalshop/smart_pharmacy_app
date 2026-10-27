import 'package:drift/drift.dart';
import '../converters.dart';
import 'pharmacy_settings_table.dart';
import 'products_table.dart';

/// Multi-price batches with FEFO tracking.
@DataClassName('ProductBatch')
class ProductBatchesTable extends Table {
  @override
  String get tableName => 'product_batches';

  TextColumn get id => text()(); // UUIDv4
  TextColumn get pharmacyUid => text().references(PharmacySettingsTable, #pharmacyUid)();
  TextColumn get productId => text().references(ProductsTable, #id)();
  TextColumn get batchNumber => text()();
  TextColumn get supplierName => text().nullable()();
  RealColumn get purchasePrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get initialQuantity => integer()();
  IntColumn get currentStock => integer()(); // Real-time remaining stock counter
  TextColumn get expiryDate => text().map(const DateOnlyConverter())(); // YYYY-MM-DD
  TextColumn get createdAt => text().map(const IsoDateTimeConverter())();
  TextColumn get updatedAt => text().map(const IsoDateTimeConverter())();
  TextColumn get deletedAt => text().map(const IsoDateTimeConverter()).nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();

  @override
  Set<Column> get primaryKey => {id};
}

