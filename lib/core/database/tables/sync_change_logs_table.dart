import 'package:drift/drift.dart';
import '../converters.dart';
import 'pharmacy_settings_table.dart';

/// Audit & Sync Outbox Queue for Bi-Directional CDC.
@DataClassName('SyncChangeLog')
class SyncChangeLogsTable extends Table {
  @override
  String get tableName => 'sync_change_log';

  TextColumn get logId => text()(); // UUIDv4
  TextColumn get pharmacyUid => text().references(PharmacySettingsTable, #pharmacyUid)();
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'INSERT', 'UPDATE', 'DELETE'
  TextColumn get changedAt => text().map(const IsoDateTimeConverter())();
  BoolColumn get isPushed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {logId};
}

