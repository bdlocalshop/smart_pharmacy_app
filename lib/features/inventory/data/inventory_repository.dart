import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_pharmacy_app/core/constants/app_constants.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';

import '../domain/csv_medicine_importer.dart';
import '../domain/inventory_repository_interface.dart';

/// Exception thrown when attempting to delete a medicine that still has unsold stock.
class UnsoldStockException implements Exception {
  final int unsoldQuantity;
  UnsoldStockException(this.unsoldQuantity);

  @override
  String toString() =>
      'Cannot delete product: $unsoldQuantity unsold units remain in active inventory.';
}

/// Concrete data repository implementation for inventory and batch operations.
class InventoryRepository implements IInventoryRepository {
  final AppDatabase db;
  static const _uuid = Uuid();

  InventoryRepository(this.db);

  ProductsDao get _dao => db.productsDao;

  @override
  Stream<List<ProductWithAggregateStock>> watchProducts(
    String pharmacyUid, {
    String? searchQuery,
  }) {
    return _dao.watchProductsWithAggregateStock(
      pharmacyUid,
      searchQuery: searchQuery,
    );
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
  Future<List<Product>> getActiveProducts(String pharmacyUid) {
    return _dao.getActiveProducts(pharmacyUid);
  }

  @override
  Future<CsvBatchImportReport> importMedicinesWithDuplicateCheck({
    required String pharmacyUid,
    required List<ProductImportItem> parsedProducts,
    required List<CsvSkippedItem> initialSkippedItems,
  }) async {
    // 1. Fetch all existing active products in the DB for duplicate comparison
    final existingProducts = await _dao.getActiveProducts(pharmacyUid);
    final existingKeys = <String>{};
    for (final ep in existingProducts) {
      existingKeys.add(
        ProductImportItem.buildDuplicateKey(ep.brandName, ep.unitType),
      );
    }

    final newProductsToInsert = <ProductImportItem>[];
    final allSkippedItems = List<CsvSkippedItem>.from(initialSkippedItems);
    int existingDbDuplicateCount = 0;

    for (final p in parsedProducts) {
      final key = p.duplicateKey;
      if (existingKeys.contains(key)) {
        existingDbDuplicateCount++;
        allSkippedItems.add(
          CsvSkippedItem(
            rowNumber: p.sourceRowNumber,
            brandName: p.brandName,
            genericName: p.genericName,
            category: p.category,
            manufacturer: p.manufacturer,
            shelfLocation: p.shelfLocation,
            unitType: p.unitType,
            minStockAlert: p.minStockAlert.toString(),
            reason:
                'Already exists in database with Brand: "${p.brandName}" & Unit: "${p.unitType}".',
          ),
        );
      } else {
        newProductsToInsert.add(p);
        existingKeys.add(key); // Prevent any subsequent in-batch duplicates
      }
    }

    // 2. Insert genuinely new products in an atomic batch
    if (newProductsToInsert.isNotEmpty) {
      final now = DateTime.now();
      await db.batch((batch) {
        for (final p in newProductsToInsert) {
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
    }

    // Sort skipped items by row number
    allSkippedItems.sort((a, b) => a.rowNumber.compareTo(b.rowNumber));

    final inCsvDupes = initialSkippedItems
        .where((i) => i.reason.contains('Duplicate in CSV'))
        .length;
    final missingNames = initialSkippedItems
        .where((i) => !i.reason.contains('Duplicate in CSV'))
        .length;

    return CsvBatchImportReport(
      insertedCount: newProductsToInsert.length,
      existingDbDuplicateCount: existingDbDuplicateCount,
      inCsvDuplicateCount: inCsvDupes,
      skippedMissingCount: missingNames,
      insertedProducts: newProductsToInsert,
      skippedItems: allSkippedItems,
    );
  }

  @override
  Future<int> addMultipleProducts({
    required String pharmacyUid,
    required List<ProductImportItem> products,
  }) async {
    final report = await importMedicinesWithDuplicateCheck(
      pharmacyUid: pharmacyUid,
      parsedProducts: products,
      initialSkippedItems: const [],
    );
    return report.insertedCount;
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
    await (db.update(
      db.productsTable,
    )..where((tbl) => tbl.id.equals(productId))).write(
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
  Future<void> deleteProduct(String pharmacyUid, String productId) async {
    final batches = await _dao
        .watchBatchesForProduct(pharmacyUid, productId)
        .first;
    final totalUnsold = batches.fold<int>(0, (sum, b) => sum + b.currentStock);
    if (totalUnsold > 0) {
      throw UnsoldStockException(totalUnsold);
    }
    return _dao.softDeleteProduct(pharmacyUid, productId);
  }

  @override
  Stream<List<ProductBatch>> watchBatchesForProduct(
    String pharmacyUid,
    String productId,
  ) {
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
    await (db.update(
      db.productBatchesTable,
    )..where((tbl) => tbl.id.equals(batchId))).write(
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
    return _dao.watchExpiringBatchesWithProduct(
      pharmacyUid,
      minDays: minDays,
      maxDays: maxDays,
    );
  }
}
