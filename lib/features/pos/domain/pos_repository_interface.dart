import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/database/daos/sales_dao.dart';

/// Contract for POS search, stock queries, and atomic checkout operations.
abstract class IPosRepository {
  /// Stream of active medicines with aggregate stock for POS typeahead search.
  Stream<List<ProductWithAggregateStock>> searchMedicines(
    String pharmacyUid, {
    String? searchQuery,
  });

  /// Retrieves the earliest non-expired batch for a product according to FEFO.
  Future<ProductBatch?> getEarliestFefoBatch(String pharmacyUid, String productId);

  /// Retrieves all active non-expired batches for a product sorted by FEFO.
  Future<List<ProductBatch>> getFefoBatches(String pharmacyUid, String productId);

  /// Executes atomic checkout inside a Drift database transaction:
  /// - Deducts exact batch stock
  /// - Blocks sale if batch is expired
  /// - Creates Sale and SaleItem records marked as 'pending_insert'
  Future<CompletedCheckoutResult> checkout({
    required String pharmacyUid,
    required String cashierUserId,
    required List<CheckoutItemRequest> items,
    String customerName = 'Walk-in Customer',
    String? customerPhone,
    double invoiceDiscount = 0.0,
    required double amountTendered,
    String paymentMethod = 'Cash',
  });

  /// Fetches an invoice and its line items.
  Future<Sale?> getSaleByInvoice(String pharmacyUid, String invoiceNumber);
}

