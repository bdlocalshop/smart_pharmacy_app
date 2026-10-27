import 'package:drift/drift.dart';
import '../converters.dart';
import 'pharmacy_settings_table.dart';
import 'users_table.dart';

/// Sales invoices.
@DataClassName('Sale')
class SalesTable extends Table {
  @override
  String get tableName => 'sales';

  TextColumn get id => text()(); // UUIDv4
  TextColumn get pharmacyUid => text().references(PharmacySettingsTable, #pharmacyUid)();
  TextColumn get invoiceNumber => text().unique()(); // INV-YYYYMMDD-XXXX
  TextColumn get cashierUserId => text().references(UsersTable, #id)();
  TextColumn get customerName => text().withDefault(const Constant('Walk-in Customer'))();
  TextColumn get customerPhone => text().nullable()();
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalPayable => real()();
  RealColumn get amountTendered => real()();
  RealColumn get changeReturned => real()();
  TextColumn get paymentMethod => text()(); // Cash, Card, Mobile, Due
  RealColumn get totalCostPrice => real()(); // Summed procurement cost for fast profit reporting
  RealColumn get grossProfit => real()(); // totalPayable - totalCostPrice
  TextColumn get createdAt => text().map(const IsoDateTimeConverter())();
  TextColumn get deletedAt => text().map(const IsoDateTimeConverter()).nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();

  @override
  Set<Column> get primaryKey => {id};
}

