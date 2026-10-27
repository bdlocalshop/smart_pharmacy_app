import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'csv_medicine_importer.dart';

/// Contract for inventory management, multi-supplier batches, and expiry alerts.
abstract class IInventoryRepository {
  Stream<List<ProductWithAggregateStock>> watchProducts(String pharmacyUid, {String? searchQuery});

  Future<void> addProduct({
    required String pharmacyUid,
    required String brandName,
    required String genericName,
    required String category,
    required String manufacturer,
    required String shelfLocation,
    String unitType = 'Tablet',
    int minStockAlert = 10,
  });

  /// Inserts multiple medicines in a single atomic database batch transaction.
  Future<int> addMultipleProducts({
    required String pharmacyUid,
    required List<ProductImportItem> products,
  });

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
  });

  Future<void> deleteProduct(String pharmacyUid, String productId);

  Stream<List<ProductBatch>> watchBatchesForProduct(String pharmacyUid, String productId);

  Future<void> addBatch({
    required String pharmacyUid,
    required String productId,
    required String batchNumber,
    String? supplierName,
    required double purchasePrice,
    required double sellingPrice,
    required int initialQuantity,
    required DateTime expiryDate,
  });

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
  });

  Future<void> deleteBatch(String pharmacyUid, String batchId);

  Stream<List<BatchWithProductInfo>> watchExpiredBatches(String pharmacyUid);

  Stream<List<BatchWithProductInfo>> watchExpiringBatches(
    String pharmacyUid, {
    int minDays = 0,
    required int maxDays,
  });
}

