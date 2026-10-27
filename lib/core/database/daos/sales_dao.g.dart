// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_dao.dart';

// ignore_for_file: type=lint
mixin _$SalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PharmacySettingsTableTable get pharmacySettingsTable =>
      attachedDatabase.pharmacySettingsTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $SalesTableTable get salesTable => attachedDatabase.salesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $ProductBatchesTableTable get productBatchesTable =>
      attachedDatabase.productBatchesTable;
  $SaleItemsTableTable get saleItemsTable => attachedDatabase.saleItemsTable;
  SalesDaoManager get managers => SalesDaoManager(this);
}

class SalesDaoManager {
  final _$SalesDaoMixin _db;
  SalesDaoManager(this._db);
  $$PharmacySettingsTableTableTableManager get pharmacySettingsTable =>
      $$PharmacySettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.pharmacySettingsTable,
      );
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db.attachedDatabase, _db.salesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$ProductBatchesTableTableTableManager get productBatchesTable =>
      $$ProductBatchesTableTableTableManager(
        _db.attachedDatabase,
        _db.productBatchesTable,
      );
  $$SaleItemsTableTableTableManager get saleItemsTable =>
      $$SaleItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.saleItemsTable,
      );
}
