// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PharmacySettingsTableTable get pharmacySettingsTable =>
      attachedDatabase.pharmacySettingsTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $ProductBatchesTableTable get productBatchesTable =>
      attachedDatabase.productBatchesTable;
  ProductsDaoManager get managers => ProductsDaoManager(this);
}

class ProductsDaoManager {
  final _$ProductsDaoMixin _db;
  ProductsDaoManager(this._db);
  $$PharmacySettingsTableTableTableManager get pharmacySettingsTable =>
      $$PharmacySettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.pharmacySettingsTable,
      );
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$ProductBatchesTableTableTableManager get productBatchesTable =>
      $$ProductBatchesTableTableTableManager(
        _db.attachedDatabase,
        _db.productBatchesTable,
      );
}
