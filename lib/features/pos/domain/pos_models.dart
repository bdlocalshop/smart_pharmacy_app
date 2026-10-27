import 'package:smart_pharmacy_app/core/database/app_database.dart';

/// Represents a single line item within the active POS checkout cart.
class CartItem {
  final Product product;
  final int quantity;
  final double unitSellingPrice;
  final double lineDiscountAmount;
  final ProductBatch? allocatedBatch; // Earliest FEFO batch preview
  final int availableStock;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.unitSellingPrice,
    this.lineDiscountAmount = 0.0,
    this.allocatedBatch,
    this.availableStock = 0,
  });

  double get lineSubtotal => unitSellingPrice * quantity;
  double get lineTotal => (lineSubtotal - lineDiscountAmount).clamp(0.0, double.infinity);

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? unitSellingPrice,
    double? lineDiscountAmount,
    ProductBatch? allocatedBatch,
    int? availableStock,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitSellingPrice: unitSellingPrice ?? this.unitSellingPrice,
      lineDiscountAmount: lineDiscountAmount ?? this.lineDiscountAmount,
      allocatedBatch: allocatedBatch ?? this.allocatedBatch,
      availableStock: availableStock ?? this.availableStock,
    );
  }
}

/// Represents the active state of the POS cart and cashier checkout.
class PosCartState {
  final List<CartItem> items;
  final String customerName;
  final String? customerPhone;
  final double invoiceDiscount;
  final double amountTendered;
  final String paymentMethod;
  final bool isProcessing;
  final String? errorMessage;
  final Sale? lastCompletedSale;

  const PosCartState({
    this.items = const [],
    this.customerName = 'Walk-in Customer',
    this.customerPhone,
    this.invoiceDiscount = 0.0,
    this.amountTendered = 0.0,
    this.paymentMethod = 'Cash',
    this.isProcessing = false,
    this.errorMessage,
    this.lastCompletedSale,
  });

  int get totalItemCount => items.fold<int>(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold<double>(0.0, (sum, i) => sum + i.lineSubtotal);

  double get lineDiscountsTotal => items.fold<double>(0.0, (sum, i) => sum + i.lineDiscountAmount);

  double get totalDiscount => lineDiscountsTotal + invoiceDiscount;

  double get totalPayable => (subtotal - totalDiscount).clamp(0.0, double.infinity);

  double get changeReturned => (amountTendered - totalPayable).clamp(0.0, double.infinity);

  bool get isPaymentSufficient =>
      paymentMethod == 'Due' || amountTendered >= totalPayable;

  bool get canCheckout =>
      items.isNotEmpty &&
      !isProcessing &&
      isPaymentSufficient;

  PosCartState copyWith({
    List<CartItem>? items,
    String? customerName,
    String? customerPhone,
    double? invoiceDiscount,
    double? amountTendered,
    String? paymentMethod,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    Sale? lastCompletedSale,
    bool clearSale = false,
  }) {
    return PosCartState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      invoiceDiscount: invoiceDiscount ?? this.invoiceDiscount,
      amountTendered: amountTendered ?? this.amountTendered,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastCompletedSale: clearSale ? null : (lastCompletedSale ?? this.lastCompletedSale),
    );
  }
}

