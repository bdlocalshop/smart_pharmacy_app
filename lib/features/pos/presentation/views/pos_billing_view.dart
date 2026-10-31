import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/localization/app_strings.dart';
import 'package:smart_pharmacy_app/core/localization/language_controller.dart';
import '../controllers/pos_controller.dart';
import '../../domain/pos_models.dart';
import '../../../../core/widgets/voice_input_suffix_icon.dart';

/// Desktop POS Billing Screen with typeahead search, shelf locations,
/// smart FEFO allocation, dynamic cart calculations, and full keyboard shortcuts.
class PosBillingView extends ConsumerStatefulWidget {
  const PosBillingView({super.key});

  @override
  ConsumerState<PosBillingView> createState() => _PosBillingViewState();
}

class _PosBillingViewState extends ConsumerState<PosBillingView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _tenderFocusNode = FocusNode();
  final _discountFocusNode = FocusNode();

  final _customerNameCtl = TextEditingController(text: 'Walk-in Customer');
  final _customerPhoneCtl = TextEditingController();
  final _invoiceDiscountCtl = TextEditingController(text: '0.00');
  final _tenderedCtl = TextEditingController();

  final _currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 2);
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tenderFocusNode.dispose();
    _discountFocusNode.dispose();
    _customerNameCtl.dispose();
    _customerPhoneCtl.dispose();
    _invoiceDiscountCtl.dispose();
    _tenderedCtl.dispose();
    super.dispose();
  }

  void _handleHotkeys(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // F2: Focus Search
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      _searchFocusNode.requestFocus();
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    }
    // F4: Focus Cash Tendered
    else if (event.logicalKey == LogicalKeyboardKey.f4) {
      _tenderFocusNode.requestFocus();
      _tenderedCtl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _tenderedCtl.text.length,
      );
    }
    // F6: Focus Invoice Discount
    else if (event.logicalKey == LogicalKeyboardKey.f6) {
      _discountFocusNode.requestFocus();
      _discountDiscountSelection();
    }
    // Ctrl + Enter: Complete Checkout
    else if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      _triggerCheckout();
    }
    // Escape: Clear search
    else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        ref.read(posSearchQueryProvider.notifier).state = '';
      }
    }
  }

  void _discountDiscountSelection() {
    _invoiceDiscountCtl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _invoiceDiscountCtl.text.length,
    );
  }

  Future<void> _triggerCheckout() async {
    final cart = ref.read(posCartControllerProvider);
    if (!cart.canCheckout) return;

    final result = await ref.read(posCartControllerProvider.notifier).checkout();

    if (result != null && mounted) {
      _tenderedCtl.clear();
      _invoiceDiscountCtl.text = '0.00';
      _customerNameCtl.text = 'Walk-in Customer';
      _customerPhoneCtl.clear();

      _showCheckoutSuccessDialog(result.sale);
    }
  }

  void _showCheckoutSuccessDialog(Sale sale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.accent, size: 28),
            ),
            const SizedBox(width: 14),
            const Text('Sale Completed Successfully!'),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Invoice Number', sale.invoiceNumber, isBold: true),
                    const Divider(height: 16),
                    _buildReceiptRow('Customer', sale.customerName),
                    _buildReceiptRow('Payment Method', sale.paymentMethod),
                    _buildReceiptRow('Total Amount', _currencyFormat.format(sale.totalPayable), isBold: true, color: AppColors.primaryDark),
                    _buildReceiptRow('Amount Tendered', _currencyFormat.format(sale.amountTendered)),
                    const Divider(height: 16),
                    _buildReceiptRow(
                      'Change Returned',
                      _currencyFormat.format(sale.changeReturned),
                      isBold: true,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.sync, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Recorded locally in SQLite (WAL) • Pending cloud sync',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Sale (F1 / Enter)', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              _searchFocusNode.requestFocus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartControllerProvider);
    final searchResultsAsync = ref.watch(posSearchResultsProvider);
    final strings = ref.watch(appStringsProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleHotkeys,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= LEFT REGION (64%): Search + Typeahead Catalog + Active Cart Table =================
          Expanded(
            flex: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search & Quick Scan Bar
                _buildSearchAndScanBar(strings),
                const SizedBox(height: 12),

                // Search Results Dropdown / Table (if query typed)
                if (_searchController.text.trim().isNotEmpty) ...[
                  _buildSearchResultsPanel(searchResultsAsync, strings),
                  const SizedBox(height: 12),
                ],

                // Cart Line Items Table
                Expanded(
                  child: _buildCartItemsTable(cart, strings),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          // ================= RIGHT REGION (36%): Customer Info + Financial Summary + Cash Tender =================
          Expanded(
            flex: 36,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Header
                  _buildCustomerCard(strings),
                  const SizedBox(height: 14),

                  // Financial Breakdown Card
                  _buildFinancialBreakdownCard(cart, strings),
                  const SizedBox(height: 14),

                  // Cash Tender & Live Change Card
                  _buildPaymentTenderCard(cart, strings),
                  const SizedBox(height: 18),

                  // Complete Sale Action Button
                  _buildCompleteSaleButton(cart, strings),

                  // Error Banner
                  if (cart.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.alertCritical.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.alertCritical, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cart.errorMessage!,
                              style: const TextStyle(color: AppColors.alertCritical, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndScanBar(AppStrings strings) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: strings.posSearchHint,
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  border: InputBorder.none,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(posSearchQueryProvider.notifier).state = '';
                          },
                        ),
                      VoiceInputSuffixIcon(
                        controller: _searchController,
                        tooltip: strings.posVoiceSearch,
                        onChanged: (val) {
                          ref.read(posSearchQueryProvider.notifier).state = val;
                        },
                      ),
                    ],
                  ),
                ),
                onChanged: (val) {
                  ref.read(posSearchQueryProvider.notifier).state = val;
                },
                onSubmitted: (val) {
                  // If barcode scanned or single exact match, add first item automatically
                  final results = ref.read(posSearchResultsProvider).value ?? [];
                  if (results.isNotEmpty) {
                    final item = results.first;
                    if (item.activeStock > 0) {
                      ref.read(posCartControllerProvider.notifier).addToCart(
                            item.product,
                            availableStock: item.activeStock,
                          );
                      _searchController.clear();
                      ref.read(posSearchQueryProvider.notifier).state = '';
                      _searchFocusNode.requestFocus();
                    }
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(strings.posHotkeySearch, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsPanel(AsyncValue<List<ProductWithAggregateStock>> searchResultsAsync, AppStrings strings) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primaryLight),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250),
        child: searchResultsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Search error: $e', style: const TextStyle(color: AppColors.alertCritical)),
          ),
          data: (results) {
            if (results.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No matching medicines found in catalog.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = results[i];
                final p = item.product;
                final isAvailable = item.activeStock > 0;

                return InkWell(
                  onTap: isAvailable
                      ? () {
                          ref.read(posCartControllerProvider.notifier).addToCart(
                                p,
                                availableStock: item.activeStock,
                              );
                          _searchController.clear();
                          ref.read(posSearchQueryProvider.notifier).state = '';
                          _searchFocusNode.requestFocus();
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Medicine Name & Generic
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.brandName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${p.genericName} • ${p.category}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),

                        // Shelf Location
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              const Icon(Icons.shelves, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(p.shelfLocation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                            ],
                          ),
                        ),

                        // Earliest Expiry (FEFO)
                        Expanded(
                          flex: 2,
                          child: item.earliestExpiry != null
                              ? Text(
                                  'FEFO: ${_dateFormat.format(item.earliestExpiry!)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                )
                              : const Text('No active batch', style: TextStyle(fontSize: 11, color: AppColors.alertCritical)),
                        ),

                        // Stock Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? (item.isLowStock ? AppColors.alertWarning.withValues(alpha: 0.15) : AppColors.alertSafe.withValues(alpha: 0.15))
                                : AppColors.alertCritical.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAvailable ? '${item.activeStock} ${strings.inStock}' : strings.outOfStock,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? (item.isLowStock ? AppColors.alertWarning : AppColors.alertSafe)
                                  : AppColors.alertCritical,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Add Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable ? AppColors.primary : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: isAvailable
                              ? () {
                                  ref.read(posCartControllerProvider.notifier).addToCart(
                                        p,
                                        availableStock: item.activeStock,
                                      );
                                  _searchController.clear();
                                  ref.read(posSearchQueryProvider.notifier).state = '';
                                  _searchFocusNode.requestFocus();
                                }
                              : null,
                          child: Text(strings.addEnter, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItemsTable(PosCartState cart, AppStrings strings) {
    if (cart.items.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_shopping_cart, size: 64, color: AppColors.textMuted.withValues(alpha: 0.4)),
              const SizedBox(height: 14),
              Text(
                strings.posCartEmptyTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                strings.posCartEmptySubtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(strings.colMedicineShelf, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text(strings.colBatchExpiry, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colUnitMrp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text(strings.colQuantity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colLineDisc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colTotal, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 36), // Delete icon slot
              ],
            ),
          ),

          // Table Rows
          Expanded(
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = cart.items[i];
                final p = item.product;
                final batch = item.allocatedBatch;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Medicine & Shelf Locator
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.brandName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Row(
                              children: [
                                const Icon(Icons.shelves, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(p.shelfLocation, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                const SizedBox(width: 8),
                                Text('• ${p.unitType}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // FEFO Batch
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (batch != null) ...[
                              Text('Batch #${batch.batchNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(
                                'Exp: ${_dateFormat.format(batch.expiryDate)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold),
                              ),
                            ] else
                              Text(strings.autoAllocatedFefo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),

                      // Unit MRP Price
                      Expanded(
                        flex: 2,
                        child: Text(
                          _currencyFormat.format(item.unitSellingPrice),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),

                      // Quantity Toggler (+ / - with direct editable input and stock limit enforcement)
                      Expanded(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (context) {
                              final isAtMaxStock = item.availableStock > 0 && item.quantity >= item.availableStock;
                              final isAtMinQty = item.quantity <= 1;

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                                    color: isAtMinQty ? AppColors.textSecondary.withAlpha(76) : AppColors.textSecondary,
                                    tooltip: isAtMinQty ? 'Minimum 1 unit' : 'Decrease quantity',
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    padding: EdgeInsets.zero,
                                    splashRadius: 14,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: isAtMinQty
                                        ? null
                                        : () {
                                            ref.read(posCartControllerProvider.notifier).decrementQuantity(p.id);
                                          },
                                  ),
                                  const SizedBox(width: 2),
                                  _CartItemQuantityField(item: item),
                                  const SizedBox(width: 2),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 18),
                                    color: isAtMaxStock ? AppColors.textSecondary.withAlpha(76) : AppColors.primary,
                                    tooltip: isAtMaxStock ? 'Max available stock: ${item.availableStock}' : 'Increase quantity',
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    padding: EdgeInsets.zero,
                                    splashRadius: 14,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: isAtMaxStock
                                        ? null
                                        : () {
                                            ref.read(posCartControllerProvider.notifier).incrementQuantity(p.id);
                                          },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // Line Discount
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 52,
                            child: TextFormField(
                              initialValue: item.lineDiscountAmount > 0 ? item.lineDiscountAmount.toStringAsFixed(2) : '',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              ),
                              style: const TextStyle(fontSize: 12),
                              onChanged: (val) {
                                final d = double.tryParse(val) ?? 0.0;
                                ref.read(posCartControllerProvider.notifier).updateLineDiscount(p.id, d);
                              },
                            ),
                          ),
                        ),
                      ),

                      // Line Total
                      Expanded(
                        flex: 2,
                        child: Text(
                          _currencyFormat.format(item.lineTotal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                        ),
                      ),

                      // Delete Item
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.alertCritical),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        splashRadius: 14,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove from cart',
                        onPressed: () {
                          ref.read(posCartControllerProvider.notifier).removeItem(p.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Bar of Cart: Quick Item Count & Clear Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.lineItemsCount(cart.items.length, cart.totalItemCount),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.alertCritical),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  label: Text(strings.clearCart, style: const TextStyle(fontSize: 12)),
                  onPressed: () => ref.read(posCartControllerProvider.notifier).clearCart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(AppStrings strings) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(strings.customerDetails, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customerNameCtl,
                    decoration: InputDecoration(
                      labelText: strings.customerName,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: VoiceInputSuffixIcon(
                        controller: _customerNameCtl,
                        tooltip: 'Voice Input Customer Name',
                        iconSize: 18,
                        onChanged: (val) => ref.read(posCartControllerProvider.notifier).setCustomerName(val),
                      ),
                    ),
                    onChanged: (val) => ref.read(posCartControllerProvider.notifier).setCustomerName(val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _customerPhoneCtl,
                    decoration: InputDecoration(
                      labelText: strings.mobilePhone,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: VoiceInputSuffixIcon(
                        controller: _customerPhoneCtl,
                        tooltip: 'Voice Input Mobile Phone',
                        iconSize: 18,
                        onChanged: (val) => ref.read(posCartControllerProvider.notifier).setCustomerPhone(val),
                      ),
                    ),
                    onChanged: (val) => ref.read(posCartControllerProvider.notifier).setCustomerPhone(val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialBreakdownCard(PosCartState cart, AppStrings strings) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.invoiceFinancialSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),

            _buildSummaryRow(strings.cartSubtotal, _currencyFormat.format(cart.subtotal)),
            if (cart.lineDiscountsTotal > 0)
              _buildSummaryRow(strings.lineItemDiscounts, '- ${_currencyFormat.format(cart.lineDiscountsTotal)}', color: AppColors.alertCritical),

            const SizedBox(height: 8),

            // Invoice Level Discount Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(strings.invoiceDiscountPrompt, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: _invoiceDiscountCtl,
                    focusNode: _discountFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixText: '৳ ',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      final d = double.tryParse(val) ?? 0.0;
                      ref.read(posCartControllerProvider.notifier).setInvoiceDiscount(d);
                    },
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Grand Total Payable
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.totalNetPayable, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _currencyFormat.format(cart.totalPayable),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPaymentTenderCard(PosCartState cart, AppStrings strings) {
    final change = cart.changeReturned;
    final isShort = cart.paymentMethod == 'Cash' && cart.amountTendered < cart.totalPayable && cart.items.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.paymentMethodTender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),

            // Payment Method Radios / Chips
            Row(
              children: ['Cash', 'Card', 'Mobile', 'Due'].map((method) {
                final isSelected = cart.paymentMethod == method;
                final label = switch (method) {
                  'Cash' => strings.payCash,
                  'Card' => strings.payCard,
                  'Mobile' => strings.payMobile,
                  'Due' => strings.payDue,
                  _ => method,
                };

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                    onSelected: (_) {
                      ref.read(posCartControllerProvider.notifier).setPaymentMethod(method);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Cash Tendered Input (F4)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tenderedCtl,
                    focusNode: _tenderFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: strings.cashTenderedF4,
                      prefixText: '৳ ',
                      hintText: cart.totalPayable.toStringAsFixed(2),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      final amount = double.tryParse(val) ?? 0.0;
                      ref.read(posCartControllerProvider.notifier).setAmountTendered(amount);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Quick Cash Tender Increment Buttons
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF94A3B8), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(54, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    _tenderedCtl.text = cart.totalPayable.toStringAsFixed(2);
                    ref.read(posCartControllerProvider.notifier).setAmountTendered(cart.totalPayable);
                  },
                  child: Text(
                    strings.exactCash,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF94A3B8), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(54, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final curr = double.tryParse(_tenderedCtl.text) ?? cart.totalPayable;
                    final next = curr + 10;
                    _tenderedCtl.text = next.toStringAsFixed(2);
                    ref.read(posCartControllerProvider.notifier).setAmountTendered(next);
                  },
                  child: const Text(
                    '+৳10',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF94A3B8), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(54, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final curr = double.tryParse(_tenderedCtl.text) ?? cart.totalPayable;
                    final next = curr + 50;
                    _tenderedCtl.text = next.toStringAsFixed(2);
                    ref.read(posCartControllerProvider.notifier).setAmountTendered(next);
                  },
                  child: const Text(
                    '+৳50',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF94A3B8), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(54, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final curr = double.tryParse(_tenderedCtl.text) ?? cart.totalPayable;
                    final next = curr + 100;
                    _tenderedCtl.text = next.toStringAsFixed(2);
                    ref.read(posCartControllerProvider.notifier).setAmountTendered(next);
                  },
                  child: const Text(
                    '+৳100',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Live Change Returned Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isShort
                    ? AppColors.alertCritical.withValues(alpha: 0.12)
                    : AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isShort
                      ? AppColors.alertCritical.withValues(alpha: 0.3)
                      : AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isShort ? Icons.warning_amber_rounded : Icons.payments_outlined,
                        size: 20,
                        color: isShort ? AppColors.alertCritical : AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isShort ? strings.paymentShortfall : strings.changeToReturn,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isShort ? AppColors.alertCritical : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isShort
                        ? '- ${_currencyFormat.format(cart.totalPayable - cart.amountTendered)}'
                        : _currencyFormat.format(change),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isShort ? AppColors.alertCritical : AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteSaleButton(PosCartState cart, AppStrings strings) {
    final canCheckout = cart.canCheckout;

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: canCheckout
            ? const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        boxShadow: canCheckout
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: canCheckout ? Colors.transparent : Colors.grey.shade400,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: cart.isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline, size: 22),
        label: Text(
          cart.isProcessing ? strings.processingTransaction : strings.completeSaleButton,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: canCheckout && !cart.isProcessing ? _triggerCheckout : null,
      ),
    );
  }
}

/// Editable quantity field widget for cart line items.
/// - Automatically selects entire number upon click/focus.
/// - Allows direct typing of numbers (minimum "0").
/// - Seamlessly synchronizes with `+` and `-` buttons.
class _CartItemQuantityField extends ConsumerStatefulWidget {
  final CartItem item;

  const _CartItemQuantityField({
    required this.item,
  });

  @override
  ConsumerState<_CartItemQuantityField> createState() => _CartItemQuantityFieldState();
}

class _CartItemQuantityFieldState extends ConsumerState<_CartItemQuantityField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.item.quantity}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _selectAll() {
    Future.microtask(() {
      if (mounted && _focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _selectAll();
    } else {
      final parsed = int.tryParse(_controller.text.trim());
      final maxStock = widget.item.availableStock;
      if (parsed == null || parsed < 1) {
        _controller.text = '${widget.item.quantity}';
      } else if (maxStock > 0 && parsed > maxStock) {
        _controller.text = '$maxStock';
        ref.read(posCartControllerProvider.notifier).updateQuantity(widget.item.product.id, maxStock);
      }
    }
  }

  @override
  void didUpdateWidget(covariant _CartItemQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity ||
        oldWidget.item.availableStock != widget.item.availableStock) {
      final currentText = _controller.text.trim();
      final currentVal = int.tryParse(currentText);
      if (currentVal != widget.item.quantity) {
        _controller.text = '${widget.item.quantity}';
        if (_focusNode.hasFocus) {
          _selectAll();
        }
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 28,
      child: TextField(
        key: ValueKey('cart_qty_${widget.item.product.id}'),
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onTap: () {
          _focusNode.requestFocus();
          _selectAll();
        },
        onChanged: (val) {
          if (val.isEmpty) return;
          final parsed = int.tryParse(val);
          final maxStock = widget.item.availableStock;
          if (parsed != null) {
            if (maxStock > 0 && parsed > maxStock) {
              // Input exceeds available units: automatically snap back to max available count
              _controller.value = TextEditingValue(
                text: '$maxStock',
                selection: TextSelection.collapsed(offset: '$maxStock'.length),
              );
              ref.read(posCartControllerProvider.notifier).updateQuantity(widget.item.product.id, maxStock);
            } else if (parsed >= 1) {
              ref.read(posCartControllerProvider.notifier).updateQuantity(widget.item.product.id, parsed);
            }
          }
        },
        onSubmitted: (val) {
          final parsed = int.tryParse(val.trim());
          final maxStock = widget.item.availableStock;
          if (parsed == null || parsed < 1) {
            _controller.text = '${widget.item.quantity}';
          } else if (maxStock > 0 && parsed > maxStock) {
            _controller.text = '$maxStock';
            ref.read(posCartControllerProvider.notifier).updateQuantity(widget.item.product.id, maxStock);
          }
          _focusNode.unfocus();
        },
      ),
    );
  }
}
