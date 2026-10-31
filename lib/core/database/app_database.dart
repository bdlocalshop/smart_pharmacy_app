import 'package:drift/drift.dart';
import 'converters.dart';
import 'connection/connection.dart';
import 'tables/tables.dart';
import 'daos/products_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/users_dao.dart';

part 'app_database.g.dart';

/// Primary Drift Database for Smart Pharmacy Desktop.
@DriftDatabase(
  tables: [
    PharmacySettingsTable,
    UsersTable,
    ProductsTable,
    ProductBatchesTable,
    SalesTable,
    SaleItemsTable,
    SyncChangeLogsTable,
  ],
  daos: [
    ProductsDao,
    SalesDao,
    UsersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            final userColumns = await customSelect('PRAGMA table_info(users);').get();
            final hasPhone = userColumns.any((col) => col.data['name'] == 'phone');
            if (!hasPhone) {
              await m.addColumn(usersTable, usersTable.phone);
            }
          }
          if (from < 3) {
            final pharmacyColumns = await customSelect('PRAGMA table_info(pharmacy_settings);').get();
            final hasMapPin = pharmacyColumns.any((col) => col.data['name'] == 'map_pin_url');
            if (!hasMapPin) {
              await m.addColumn(pharmacySettingsTable, pharmacySettingsTable.mapPinUrl);
            }
          }
        },
        beforeOpen: (details) async {
          // Additional integrity and pragmatic checks
          await customStatement('PRAGMA foreign_keys = ON;');
          try {
            await customStatement("UPDATE pharmacy_settings SET currency_symbol = '৳' WHERE currency_symbol = '\$' OR currency_symbol IS NULL;");
          } catch (_) {
            // Table might not exist yet on initial run
          }
          try {
            final pharmacyColumns = await customSelect('PRAGMA table_info(pharmacy_settings);').get();
            final hasMapPin = pharmacyColumns.any((col) => col.data['name'] == 'map_pin_url');
            if (!hasMapPin) {
              await customStatement('ALTER TABLE pharmacy_settings ADD COLUMN map_pin_url TEXT;');
            }
          } catch (_) {}
        },
      );
}

