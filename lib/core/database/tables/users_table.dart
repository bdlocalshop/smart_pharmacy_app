import 'package:drift/drift.dart';
import '../converters.dart';
import 'pharmacy_settings_table.dart';

/// User accounts and Role-Based Access Control (RBAC).
@DataClassName('User')
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()(); // UUIDv4
  TextColumn get pharmacyUid => text().references(PharmacySettingsTable, #pharmacyUid)();
  TextColumn get fullName => text()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text()(); // 'OWNER', 'MANAGER', 'SALESMAN'
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text().map(const IsoDateTimeConverter())();
  TextColumn get updatedAt => text().map(const IsoDateTimeConverter())();
  TextColumn get deletedAt => text().map(const IsoDateTimeConverter()).nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();

  @override
  Set<Column> get primaryKey => {id};
}

