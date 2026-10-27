import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_pharmacy_app/core/constants/app_constants.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import '../domain/csv_medicine_importer.dart';
import '../domain/inventory_repository_interface.dart';

/// Concrete data repository implementation for inventory and batch operations.
class InventoryRepository implements IInventoryRepository {
  final AppDatabase db;
  static const _uuid = Uuid();

  InventoryRepository(this.db);

  ProductsDao get _dao => db.productsDao;

  @override
  Stream<List<ProductWithAggregateStock>> watchProducts(String pharmacyUid, {String? searchQuery}) {
    return _dao.watchProductsWithAggregateStock(pharmacyUid, searchQuery: searchQuery);
  }

  @override
  Future<void> addProduct({
    required String pharmacyUid,
    required String brandName,
    required String genericName,
    required String category,
    required String manufacturer,
    required String shelfLocation,
    String unitType = 'Tablet',
    int minStockAlert = 10,
  }) async {
    final now = DateTime.now();
    await _dao.insertProduct(
      ProductsTableCompanion(
        id: Value(_uuid.v4()),
        pharmacyUid: Value(pharmacyUid),
        brandName: Value(brandName.trim()),
        genericName: Value(genericName.trim()),
        category: Value(category.trim()),
        manufacturer: Value(manufacturer.trim()),
        shelfLocation: Value(shelfLocation.trim()),
        unitType: Value(unitType.trim()),
        minStockAlert: Value(minStockAlert),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value(AppConstants.syncPendingInsert),
      ),
    );
  }

  @override
  Future<int> addMultipleProducts({
    required String pharmacyUid,
    required List<ProductImportItem> products,
  }) async {
    if (products.isEmpty) return 0;
    final now = DateTime.now();

    await db.batch((batch) {
      for (final p in products) {
        batch.insert(
          db.productsTable,
          ProductsTableCompanion(
            id: Value(_uuid.v4()),
            pharmacyUid: Value(pharmacyUid),
            brandName: Value(p.brandName.trim()),
            genericName: Value(p.genericName.trim()),
            category: Value(p.category.trim()),
            manufacturer: Value(p.manufacturer.trim()),
            shelfLocation: Value(p.shelfLocation.trim()),
            unitType: Value(p.unitType.trim()),
            minStockAlert: Value(p.minStockAlert),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value(AppConstants.syncPendingInsert),
          ),
        );
      }
    });

    return products.length;
  }

  @override
  Future<void> updateProduct({
    required String productId,
    required String pharmacyUid,
    required String brandName,
    required String genericName,
    required String category,
    required String manufacturer,
    required String shelfLocation,
    required String unitType,
    required int minStockAlert,
  }) async {
    final now = DateTime.now();
    await (db.update(db.productsTable)..where((tbl) => tbl.id.equals(productId))).write(
      ProductsTableCompanion(
        brandName: Value(brandName.trim()),
        genericName: Value(genericName.trim()),
        category: Value(category.trim()),
        manufacturer: Value(manufacturer.trim()),
        shelfLocation: Value(shelfLocation.trim()),
        unitType: Value(unitType.trim()),
        minStockAlert: Value(minStockAlert),
        updatedAt: Value(now),
        syncStatus: const Value(AppConstants.syncPendingUpdate),
      ),
    );
  }

  @override
  Future<void> deleteProduct(String pharmacyUid, String productId) {
    return _dao.softDeleteProduct(pharmacyUid, productId);
  }

  @override
  Stream<List<ProductBatch>> watchBatchesForProduct(String pharmacyUid, String productId) {
    return _dao.watchBatchesForProduct(pharmacyUid, productId);
  }

  @override
  Future<void> addBatch({
    required String pharmacyUid,
    required String productId,
    required String batchNumber,
    String? supplierName,
    required double purchasePrice,
    required double sellingPrice,
    required int initialQuantity,
    required DateTime expiryDate,
  }) async {
    final now = DateTime.now();
    await _dao.insertBatch(
      ProductBatchesTableCompanion(
        id: Value(_uuid.v4()),
        pharmacyUid: Value(pharmacyUid),
        productId: Value(productId),
        batchNumber: Value(batchNumber.trim()),
        supplierName: Value(supplierName?.trim()),
        purchasePrice: Value(purchasePrice),
        sellingPrice: Value(sellingPrice),
        initialQuantity: Value(initialQuantity),
        currentStock: Value(initialQuantity),
        expiryDate: Value(expiryDate),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value(AppConstants.syncPendingInsert),
      ),
    );
  }

  @override
  Future<void> updateBatch({
    required String batchId,
    required String pharmacyUid,
    required String productId,
    required String batchNumber,
    String? supplierName,
    required double purchasePrice,
    required double sellingPrice,
    required int currentStock,
    required DateTime expiryDate,
  }) async {
    final now = DateTime.now();
    await (db.update(db.productBatchesTable)..where((tbl) => tbl.id.equals(batchId))).write(
      ProductBatchesTableCompanion(
        batchNumber: Value(batchNumber.trim()),
        supplierName: Value(supplierName?.trim()),
        purchasePrice: Value(purchasePrice),
        sellingPrice: Value(sellingPrice),
        currentStock: Value(currentStock),
        expiryDate: Value(expiryDate),
        updatedAt: Value(now),
        syncStatus: const Value(AppConstants.syncPendingUpdate),
      ),
    );
  }

  @override
  Future<void> deleteBatch(String pharmacyUid, String batchId) {
    return _dao.softDeleteBatch(pharmacyUid, batchId);
  }

  @override
  Stream<List<BatchWithProductInfo>> watchExpiredBatches(String pharmacyUid) {
    return _dao.watchExpiredBatchesWithProduct(pharmacyUid);
  }

  @override
  Stream<List<BatchWithProductInfo>> watchExpiringBatches(
    String pharmacyUid, {
    int minDays = 0,
    required int maxDays,
  }) {
    return _dao.watchExpiringBatchesWithProduct(pharmacyUid, minDays: minDays, maxDays: maxDays);
  }
}

