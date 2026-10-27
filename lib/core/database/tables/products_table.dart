import 'package:drift/drift.dart';
import '../converters.dart';
import 'pharmacy_settings_table.dart';

/// Medicines master catalog.
@DataClassName('Product')
class ProductsTable extends Table {
  @override
  String get tableName => 'products';

  TextColumn get id => text()(); // UUIDv4
  TextColumn get pharmacyUid => text().references(PharmacySettingsTable, #pharmacyUid)();
  TextColumn get brandName => text()();
  TextColumn get genericName => text()();
  TextColumn get category => text()();
  TextColumn get manufacturer => text()();
  TextColumn get shelfLocation => text()(); // e.g., 'Rack A-1'
  TextColumn get unitType => text().withDefault(const Constant('Tablet'))(); // Tablet, Strip, Syrup, Box
  IntColumn get minStockAlert => integer().withDefault(const Constant(10))();
  TextColumn get createdAt => text().map(const IsoDateTimeConverter())();
  TextColumn get updatedAt => text().map(const IsoDateTimeConverter())();
  TextColumn get deletedAt => text().map(const IsoDateTimeConverter()).nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();

  @override
  Set<Column> get primaryKey => {id};
}

