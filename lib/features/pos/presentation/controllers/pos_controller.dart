import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/database/daos/sales_dao.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../../data/pos_repository.dart';
import '../../domain/pos_models.dart';
import '../../domain/pos_repository_interface.dart';

/// POS repository provider.
final posRepositoryProvider = Provider<IPosRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PosRepository(db);
});

/// Search text query state for POS typeahead medicine lookup.
class PosSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String value) => super.state = value;
  void setQuery(String query) => super.state = query;
}

final posSearchQueryProvider =
    NotifierProvider<PosSearchQueryNotifier, String>(PosSearchQueryNotifier.new);

/// Stream of medicines matching POS search query with real-time stock levels.
final posSearchResultsProvider = StreamProvider<List<ProductWithAggregateStock>>((ref) {
  final repo = ref.watch(posRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);
  final search = ref.watch(posSearchQueryProvider);

  if (session == null) return const Stream.empty();

  return repo.searchMedicines(
    session.pharmacyUid,
    searchQuery: search.isEmpty ? null : search,
  );
});

/// Riverpod controller managing active POS cart items and checkout flow.
class PosCartController extends Notifier<PosCartState> {
  @override
  PosCartState build() => const PosCartState();

  IPosRepository get _repo => ref.read(posRepositoryProvider);

  /// Adds a medicine to cart. Automatically queries earliest FEFO batch.
  Future<void> addToCart(Product product, {int quantity = 1, int? availableStock}) async {
    final session = ref.read(currentUserSessionProvider);
    if (session == null) return;

    // Check if already in cart
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);

    // Retrieve FEFO batches for price, expiry preview, and aggregate stock
    ProductBatch? fefoBatch;
    int totalFefoStock = 0;
    try {
      final batches = await _repo.getFefoBatches(session.pharmacyUid, product.id);
      if (batches.isNotEmpty) {
        fefoBatch = batches.first;
        totalFefoStock = batches.fold<int>(0, (sum, b) => sum + b.currentStock);
      }
    } catch (_) {}

    final unitPrice = fefoBatch?.sellingPrice ?? 0.0;
    final stock = (availableStock != null && availableStock > 0)
        ? availableStock
        : (totalFefoStock > 0 ? totalFefoStock : (fefoBatch?.currentStock ?? 0));

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final maxStock = stock > 0 ? stock : existing.availableStock;
      int newQty = existing.quantity + quantity;
      if (maxStock > 0 && newQty > maxStock) {
        newQty = maxStock;
      }

      final updatedList = List<CartItem>.from(state.items);
      updatedList[existingIndex] = existing.copyWith(
        quantity: newQty,
        availableStock: maxStock,
      );

      state = state.copyWith(
        items: updatedList,
        clearError: true,
      );
    } else {
      int initialQty = quantity;
      if (stock > 0 && initialQty > stock) {
        initialQty = stock;
      }

      final newItem = CartItem(
        product: product,
        quantity: initialQty,
        unitSellingPrice: unitPrice,
        allocatedBatch: fefoBatch,
        availableStock: stock,
      );

      state = state.copyWith(
        items: [...state.items, newItem],
        clearError: true,
      );
    }

    // Default cash tendered to total payable if not manually modified
    if (state.amountTendered == 0.0 || state.paymentMethod == 'Cash') {
      state = state.copyWith(amountTendered: state.totalPayable);
    }
  }

  /// Updates quantity for a cart line item. Clamps between 1 and available stock.
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity < 1) {
      return;
    }

    final updated = state.items.map((i) {
      if (i.product.id == productId) {
        int targetQty = newQuantity;
        if (i.availableStock > 0 && targetQty > i.availableStock) {
          targetQty = i.availableStock;
        }
        return i.copyWith(quantity: targetQty);
      }
      return i;
    }).toList();

    state = state.copyWith(items: updated);

    if (state.paymentMethod == 'Cash') {
      state = state.copyWith(amountTendered: state.totalPayable);
    }
  }

  void incrementQuantity(String productId) {
    final item = state.items.firstWhere((i) => i.product.id == productId);
    if (item.availableStock > 0 && item.quantity >= item.availableStock) {
      return;
    }
    updateQuantity(productId, item.quantity + 1);
  }

  void decrementQuantity(String productId) {
    final item = state.items.firstWhere((i) => i.product.id == productId);
    if (item.quantity > 1) {
      updateQuantity(productId, item.quantity - 1);
    }
  }

  /// Updates line-item specific discount.
  void updateLineDiscount(String productId, double discount) {
    final updated = state.items.map((i) {
      if (i.product.id == productId) {
        return i.copyWith(lineDiscountAmount: discount.clamp(0.0, i.lineSubtotal));
      }
      return i;
    }).toList();

    state = state.copyWith(items: updated);
    if (state.paymentMethod == 'Cash') {
      state = state.copyWith(amountTendered: state.totalPayable);
    }
  }

  /// Updates unit selling price for an item.
  void updateUnitPrice(String productId, double newPrice) {
    final updated = state.items.map((i) {
      if (i.product.id == productId) {
        return i.copyWith(unitSellingPrice: newPrice.clamp(0.0, double.infinity));
      }
      return i;
    }).toList();

    state = state.copyWith(items: updated);
    if (state.paymentMethod == 'Cash') {
      state = state.copyWith(amountTendered: state.totalPayable);
    }
  }

  /// Removes an item from cart.
  void removeItem(String productId) {
    final updated = state.items.where((i) => i.product.id != productId).toList();
    state = state.copyWith(items: updated);
    if (state.paymentMethod == 'Cash') {
      state = state.copyWith(amountTendered: state.totalPayable);
    }
  }

  /// Clears the entire cart.
  void clearCart() {
    state = const PosCartState();
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setCustomerPhone(String? phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void setInvoiceDiscount(double discount) {
    state = state.copyWith(
      invoiceDiscount: discount.clamp(0.0, state.subtotal),
    );
    if (state.paymentMethod == 'Cash') {
      state = state.copyWith(amountTendered: state.totalPayable);
    }
  }

  void setAmountTendered(double amount) {
    state = state.copyWith(amountTendered: amount.clamp(0.0, 1000000.0));
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void clearCompletedSale() {
    state = state.copyWith(clearSale: true);
  }

  /// Performs atomic checkout inside Drift database transaction.
  Future<CompletedCheckoutResult?> checkout() async {
    final session = ref.read(currentUserSessionProvider);
    if (session == null) {
      state = state.copyWith(errorMessage: 'Cashier session not found. Please log in.');
      return null;
    }

    if (state.items.isEmpty) {
      state = state.copyWith(errorMessage: 'Cart is empty.');
      return null;
    }

    if (!state.isPaymentSufficient) {
      state = state.copyWith(
        errorMessage: 'Amount tendered is less than total payable (\$${state.totalPayable.toStringAsFixed(2)}).',
      );
      return null;
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final checkoutRequests = state.items.map((i) {
        return CheckoutItemRequest(
          productId: i.product.id,
          quantity: i.quantity,
          unitSellingPrice: i.unitSellingPrice,
          lineDiscountAmount: i.lineDiscountAmount,
        );
      }).toList();

      final result = await _repo.checkout(
        pharmacyUid: session.pharmacyUid,
        cashierUserId: session.userId,
        items: checkoutRequests,
        customerName: state.customerName,
        customerPhone: state.customerPhone,
        invoiceDiscount: state.invoiceDiscount,
        amountTendered: state.amountTendered,
        paymentMethod: state.paymentMethod,
      );

      // Successfully processed: record sale and clear cart
      state = PosCartState(
        lastCompletedSale: result.sale,
        customerName: 'Walk-in Customer',
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString().replaceFirst('AppException: ', ''),
      );
      return null;
    }
  }
}

final posCartControllerProvider =
    NotifierProvider<PosCartController, PosCartState>(PosCartController.new);

