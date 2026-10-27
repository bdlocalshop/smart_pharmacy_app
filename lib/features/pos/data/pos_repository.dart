import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/database/daos/sales_dao.dart';
import '../domain/pos_repository_interface.dart';

/// Concrete implementation of [IPosRepository] utilizing Drift SQLite DAOs.
class PosRepository implements IPosRepository {
  final AppDatabase _db;

  PosRepository(this._db);

  @override
  Stream<List<ProductWithAggregateStock>> searchMedicines(
    String pharmacyUid, {
    String? searchQuery,
  }) {
    return _db.productsDao.watchProductsWithAggregateStock(
      pharmacyUid,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<ProductBatch?> getEarliestFefoBatch(String pharmacyUid, String productId) async {
    final batches = await _db.productsDao.getFefoBatches(pharmacyUid, productId).get();
    return batches.isEmpty ? null : batches.first;
  }

  @override
  Future<List<ProductBatch>> getFefoBatches(String pharmacyUid, String productId) {
    return _db.productsDao.getFefoBatches(pharmacyUid, productId).get();
  }

  @override
  Future<CompletedCheckoutResult> checkout({
    required String pharmacyUid,
    required String cashierUserId,
    required List<CheckoutItemRequest> items,
    String customerName = 'Walk-in Customer',
    String? customerPhone,
    double invoiceDiscount = 0.0,
    required double amountTendered,
    String paymentMethod = 'Cash',
  }) {
    return _db.salesDao.executeAtomicCheckout(
      pharmacyUid: pharmacyUid,
      cashierUserId: cashierUserId,
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      invoiceDiscount: invoiceDiscount,
      amountTendered: amountTendered,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<Sale?> getSaleByInvoice(String pharmacyUid, String invoiceNumber) {
    return _db.salesDao.getSaleByInvoiceNumber(pharmacyUid, invoiceNumber);
  }
}

