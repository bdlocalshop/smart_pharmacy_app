import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/database/daos/sales_dao.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/pos/domain/pos_repository_interface.dart';
import 'package:smart_pharmacy_app/features/pos/presentation/controllers/pos_controller.dart';
import 'package:smart_pharmacy_app/features/pos/presentation/views/pos_billing_view.dart';

UserSession _createTestSession({UserRole role = UserRole.salesman}) {
  return UserSession(
    userId: 'user-salesman-001',
    username: 'salesman1',
    fullName: 'David Cashier',
    role: role,
    pharmacyUid: 'pharmacy-pos-101',
    pharmacyName: 'Central Care Pharmacy',
    currencySymbol: '৳',
    token: 'test-token',
    loginTimestamp: DateTime.now(),
  );
}

Product _createSampleProduct({
  String id = 'prod-panadol',
  String brandName = 'Panadol Advance 500mg',
  String genericName = 'Paracetamol',
  String category = 'Analgesic',
  String shelfLocation = 'Rack A-12',
}) {
  final now = DateTime.now();
  return Product(
    id: id,
    pharmacyUid: 'pharmacy-pos-101',
    brandName: brandName,
    genericName: genericName,
    category: category,
    manufacturer: 'GSK',
    shelfLocation: shelfLocation,
    unitType: 'Tablet',
    minStockAlert: 20,
    createdAt: now,
    updatedAt: now,
    syncStatus: 'synced',
  );
}

ProductBatch _createSampleBatch({
  String id = 'batch-panadol-1',
  String productId = 'prod-panadol',
  String batchNumber = 'P-2026-01',
  double purchasePrice = 1.0,
  double sellingPrice = 2.0,
  int currentStock = 150,
  required DateTime expiryDate,
}) {
  final now = DateTime.now();
  return ProductBatch(
    id: id,
    pharmacyUid: 'pharmacy-pos-101',
    productId: productId,
    batchNumber: batchNumber,
    supplierName: 'National Med',
    purchasePrice: purchasePrice,
    sellingPrice: sellingPrice,
    initialQuantity: currentStock,
    currentStock: currentStock,
    expiryDate: expiryDate,
    createdAt: now,
    updatedAt: now,
    syncStatus: 'synced',
  );
}

class FakePosRepository implements IPosRepository {
  final List<ProductWithAggregateStock> products;
  final Map<String, ProductBatch> earliestBatches;

  FakePosRepository({
    required this.products,
    required this.earliestBatches,
  });

  @override
  Stream<List<ProductWithAggregateStock>> searchMedicines(
    String pharmacyUid, {
    String? searchQuery,
  }) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return Stream.value(products);
    }
    final q = searchQuery.toLowerCase();
    final filtered = products.where((p) =>
        p.product.brandName.toLowerCase().contains(q) ||
        p.product.genericName.toLowerCase().contains(q) ||
        p.product.shelfLocation.toLowerCase().contains(q));
    return Stream.value(filtered.toList());
  }

  @override
  Future<ProductBatch?> getEarliestFefoBatch(String pharmacyUid, String productId) async {
    return earliestBatches[productId];
  }

  @override
  Future<List<ProductBatch>> getFefoBatches(String pharmacyUid, String productId) async {
    final b = earliestBatches[productId];
    return b != null ? [b] : [];
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
  }) async {
    final now = DateTime.now();
    double subtotal = 0;
    final saleItems = <SaleItem>[];

    for (final item in items) {
      final unitPrice = item.unitSellingPrice ?? 2.0;
      final lineSubtotal = unitPrice * item.quantity;
      final lineTotal = lineSubtotal - item.lineDiscountAmount;
      subtotal += lineSubtotal;

      saleItems.add(
        SaleItem(
          id: 'sale-item-1',
          pharmacyUid: pharmacyUid,
          saleId: 'sale-001',
          productId: item.productId,
          batchId: 'batch-001',
          quantity: item.quantity,
          unitCostPrice: 1.0,
          unitSellingPrice: unitPrice,
          lineTotal: lineTotal,
          createdAt: now,
          syncStatus: 'pending_insert',
        ),
      );
    }

    final totalPayable = subtotal - invoiceDiscount;

    final sale = Sale(
      id: 'sale-001',
      pharmacyUid: pharmacyUid,
      invoiceNumber: 'INV-20261024-0001',
      cashierUserId: cashierUserId,
      customerName: customerName,
      customerPhone: customerPhone,
      subtotal: subtotal,
      discountAmount: invoiceDiscount,
      taxAmount: 0.0,
      totalPayable: totalPayable,
      amountTendered: amountTendered,
      changeReturned: (amountTendered - totalPayable).clamp(0.0, double.infinity),
      paymentMethod: paymentMethod,
      totalCostPrice: 10.0,
      grossProfit: totalPayable - 10.0,
      createdAt: now,
      syncStatus: 'pending_insert',
    );

    return CompletedCheckoutResult(sale: sale, items: saleItems);
  }

  @override
  Future<Sale?> getSaleByInvoice(String pharmacyUid, String invoiceNumber) async => null;
}

void main() {
  group('POS Billing Screen UI & Interaction Tests', () {
    testWidgets('Renders POS layout with search input, shelf display, empty cart, and payment panels', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(expiryDate: DateTime(2027, 4, 15));
      final sampleStockItem = ProductWithAggregateStock(
        product: sampleProd,
        activeStock: 150,
        expiredStock: 0,
        batchCount: 1,
        earliestExpiry: sampleBatch.expiryDate,
        isLowStock: false,
      );

      final fakeRepo = FakePosRepository(
        products: [sampleStockItem],
        earliestBatches: {sampleProd.id: sampleBatch},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession()),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            posRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PosBillingView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // 1. Verify Top Search Bar
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('F2: Search'), findsOneWidget);

      // 2. Verify Empty Cart Placeholder
      expect(find.text('POS Cart is currently empty'), findsOneWidget);

      // 3. Verify Customer & Payment Panels
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('Invoice Financial Summary'), findsOneWidget);
      expect(find.text('Payment Method & Cash Tender'), findsOneWidget);
      expect(find.text('Complete Sale (Ctrl + Enter)'), findsOneWidget);
    });

    testWidgets('Typeahead search displays shelf location, FEFO expiry, stock pill, and adds to cart', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(expiryDate: DateTime(2027, 4, 15));
      final sampleStockItem = ProductWithAggregateStock(
        product: sampleProd,
        activeStock: 150,
        expiredStock: 0,
        batchCount: 1,
        earliestExpiry: sampleBatch.expiryDate,
        isLowStock: false,
      );

      final fakeRepo = FakePosRepository(
        products: [sampleStockItem],
        earliestBatches: {sampleProd.id: sampleBatch},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession()),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            posRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PosBillingView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Type "Panadol" in search bar
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Panadol');
      await tester.pump();

      // Verify Typeahead Search Results Panel appears
      expect(find.text('Panadol Advance 500mg'), findsOneWidget);
      expect(find.text('Paracetamol • Analgesic'), findsOneWidget);
      // Verify Physical Shelf Location is prominently surfaced
      expect(find.text('Rack A-12'), findsOneWidget);
      // Verify FEFO Expiry indicator
      expect(find.text('FEFO: 2027-04-15'), findsOneWidget);
      // Verify Real-time Stock pill
      expect(find.text('150 in stock'), findsOneWidget);

      // Tap "Add (Enter)"
      await tester.tap(find.text('Add (Enter)'));
      await tester.pump();

      // Verify Cart Now Has 1 Item and Empty State is gone
      expect(find.text('POS Cart is currently empty'), findsNothing);
      expect(find.text('1 line items (1 total units)'), findsOneWidget);
      // Verify allocated batch pill
      expect(find.text('Batch #P-2026-01'), findsOneWidget);
      expect(find.text('Exp: 2027-04-15'), findsOneWidget);
    });

    testWidgets('Dynamic cart calculates line discounts, invoice discount, cash tendered, and change', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(
        expiryDate: DateTime(2027, 4, 15),
        sellingPrice: 10.0,
      );

      final fakeRepo = FakePosRepository(
        products: [],
        earliestBatches: {sampleProd.id: sampleBatch},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession()),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            posRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PosBillingView(),
            ),
          ),
        ),
      );

      // Add item to cart via controller
      final container = ProviderScope.containerOf(tester.element(find.byType(PosBillingView)));
      await container.read(posCartControllerProvider.notifier).addToCart(sampleProd, quantity: 3);
      await tester.pump();

      // Verify Subtotal = ৳30.00, Net Payable = ৳30.00
      expect(find.text('৳30.00'), findsWidgets);

      // Apply Invoice Discount of ৳5.00
      container.read(posCartControllerProvider.notifier).setInvoiceDiscount(5.0);
      await tester.pump();

      // Net Payable should now be ৳25.00
      expect(find.text('৳25.00'), findsWidgets);

      // Enter Tendered Amount = ৳30.00
      container.read(posCartControllerProvider.notifier).setAmountTendered(30.0);
      await tester.pump();

      // Change to Return: ৳30.00 - ৳25.00 = ৳5.00
      expect(find.text('Change to Return:'), findsOneWidget);
      expect(find.text('৳5.00'), findsWidgets);

      // Test Payment Shortfall: Tender only ৳20.00 (Short by ৳5.00)
      container.read(posCartControllerProvider.notifier).setAmountTendered(20.0);
      await tester.pump();

      expect(find.text('Payment Shortfall:'), findsOneWidget);
      expect(find.text('- ৳5.00'), findsOneWidget);
    });

    testWidgets('Completing sale triggers atomic checkout and displays invoice confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(
        expiryDate: DateTime(2027, 4, 15),
        sellingPrice: 15.0,
      );

      final fakeRepo = FakePosRepository(
        products: [],
        earliestBatches: {sampleProd.id: sampleBatch},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession()),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            posRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PosBillingView(),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(tester.element(find.byType(PosBillingView)));
      await container.read(posCartControllerProvider.notifier).addToCart(sampleProd, quantity: 2);
      container.read(posCartControllerProvider.notifier).setAmountTendered(50.0);
      await tester.pump();

      // Tap Complete Sale Button
      final completeButton = find.text('Complete Sale (Ctrl + Enter)');
      expect(completeButton, findsOneWidget);
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Verify Sale Completed Dialog
      expect(find.text('Sale Completed Successfully!'), findsOneWidget);
      expect(find.text('INV-20261024-0001'), findsOneWidget);
      expect(find.text('৳30.00'), findsWidgets); // Total
      expect(find.text('৳20.00'), findsOneWidget); // Change
      expect(find.text('New Sale (F1 / Enter)'), findsOneWidget);
    });

    testWidgets('Editable quantity input supports direct entry, minimum 1 floor, and relative +/- steps without overflow', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(
        expiryDate: DateTime(2027, 4, 15),
        sellingPrice: 10.0,
      );

      final fakeRepo = FakePosRepository(
        products: [],
        earliestBatches: {sampleProd.id: sampleBatch},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession()),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            posRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PosBillingView(),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(tester.element(find.byType(PosBillingView)));
      await container.read(posCartControllerProvider.notifier).addToCart(sampleProd, quantity: 1);
      await tester.pumpAndSettle();

      // Find the quantity text field in the cart
      final qtyFinder = find.byKey(ValueKey('cart_qty_${sampleProd.id}'));
      expect(qtyFinder, findsOneWidget);

      // 1. Direct Entry: enter "5"
      await tester.tap(qtyFinder);
      await tester.pump();
      await tester.enterText(qtyFinder, '5');
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(5));
      expect(find.text('৳50.00'), findsWidgets); // 5 * ৳10.00

      // 2. Click "+" button: increases from typed 5 -> 6
      final addBtn = find.byIcon(Icons.add_circle_outline);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(6));
      expect(find.widgetWithText(TextField, '6'), findsOneWidget);

      // 3. Click "-" button: decreases from 6 -> 5
      final minusBtn = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(minusBtn);
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(5));
      expect(find.widgetWithText(TextField, '5'), findsOneWidget);

      // 4. Direct Entry: enter "1" (minimum allowed quantity)
      await tester.enterText(qtyFinder, '1');
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(1));
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);

      // 5. Click "-" button when 1: stays 1 (clamped to minimum 1)
      await tester.tap(minusBtn);
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(1));
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);

      // 6. Click "+" button from 1: becomes 2
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(2));
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    });

    testWidgets('Quantity input is limited to available stock counts and reverts if user exceeds it', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(
        expiryDate: DateTime(2027, 4, 15),
        sellingPrice: 10.0,
        currentStock: 90,
      );

      final fakeRepo = FakePosRepository(
        products: [],
        earliestBatches: {sampleProd.id: sampleBatch},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession()),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            posRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PosBillingView(),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(tester.element(find.byType(PosBillingView)));
      await container.read(posCartControllerProvider.notifier).addToCart(
            sampleProd,
            quantity: 1,
            availableStock: 90,
          );
      await tester.pumpAndSettle();

      final qtyFinder = find.byKey(ValueKey('cart_qty_${sampleProd.id}'));
      expect(qtyFinder, findsOneWidget);

      // 1. Enter an excessive quantity "150" when only 90 is available
      await tester.enterText(qtyFinder, '150');
      await tester.pumpAndSettle();

      // Quantity must snap back to available stock 90
      expect(container.read(posCartControllerProvider).items.first.quantity, equals(90));
      expect(find.widgetWithText(TextField, '90'), findsOneWidget);

      // 2. Click "+" when already at max stock 90 -> stays 90 (button disabled/clamped)
      final addBtn = find.byIcon(Icons.add_circle_outline);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(90));
      expect(find.widgetWithText(TextField, '90'), findsOneWidget);

      // 3. Enter "91" -> snaps back to 90
      await tester.enterText(qtyFinder, '91');
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(90));
      expect(find.widgetWithText(TextField, '90'), findsOneWidget);

      // 4. Enter valid quantity "50" -> accepted
      await tester.enterText(qtyFinder, '50');
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(50));
      expect(find.widgetWithText(TextField, '50'), findsOneWidget);

      // 5. Click "+" from 50 -> becomes 51
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(container.read(posCartControllerProvider).items.first.quantity, equals(51));
      expect(find.widgetWithText(TextField, '51'), findsOneWidget);
    });
  });
}

