import 'package:drift/drift.dart';
import '../converters.dart';

/// Pharmacy tenant configuration table.
@DataClassName('PharmacySetting')
class PharmacySettingsTable extends Table {
  @override
  String get tableName => 'pharmacy_settings';

  TextColumn get pharmacyUid => text()();
  TextColumn get pharmacyName => text()();
  TextColumn get licenseNumber => text().nullable()();
  TextColumn get contactPhone => text()();
  TextColumn get address => text().nullable()();
  TextColumn get mapPinUrl => text().nullable()();
  TextColumn get currencySymbol => text().withDefault(const Constant('৳'))();
  TextColumn get createdAt => text().map(const IsoDateTimeConverter())();
  TextColumn get updatedAt => text().map(const IsoDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {pharmacyUid};
}

