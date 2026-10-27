import 'dart:io';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/core/database/seed_data.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/reports/data/sales_report_exporter.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/views/reports_view.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/widgets/invoice_items_dialog.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/widgets/receipt_preview_dialog.dart';

void main() {
  late AppDatabase db;
  late DatabaseSeeder seeder;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    seeder = DatabaseSeeder(db);
    await seeder.seedIfEmpty();
  });

  tearDown(() async {
    await db.close();
  });

  UserSession createSession(UserRole role, {String pharmacyUid = 'pharmacy-main-001'}) {
    return UserSession(
      userId: 'test-user-01',
      username: 'manager_test',
      fullName: 'Manager Alex Carter',
      role: role,
      pharmacyUid: pharmacyUid,
      pharmacyName: 'Smart Pharmacy & Healthcare',
      currencySymbol: '\$',
      token: 'test-token',
      loginTimestamp: DateTime.now(),
    );
  }

  group('Dual Sales Report Exporter Tests (@io-agent)', () {
    test('exportToExcel creates a valid 3-sheet Excel workbook with full transaction details',
        () async {
      final tempDir = Directory.systemTemp.createTempSync('excel_export_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final pharmacy = await db.select(db.pharmacySettingsTable).getSingle();
      final now = DateTime.now();
      final range = DateTimeRange(
        start: now.subtract(const Duration(days: 3)),
        end: now.add(const Duration(days: 1)),
      );

      final sales = await db.salesDao.getDetailedSalesReport(pharmacy.pharmacyUid, range.start, range.end);
      final kpis = await db.salesDao.getReportKpis(pharmacy.pharmacyUid, range.start, range.end);

      final excelFile = await SalesReportExporter.exportToExcel(
        sales: sales,
        kpis: kpis,
        pharmacy: pharmacy,
        period: range,
        customDirectory: tempDir.path,
      );

      expect(await excelFile.exists(), isTrue);
      expect(excelFile.path.endsWith('.xlsx'), isTrue);

      final bytes = await excelFile.readAsBytes();
      expect(bytes.isNotEmpty, isTrue);

      // Inspect excel sheets
      final decodedExcel = Excel.decodeBytes(bytes);
      expect(decodedExcel.sheets.containsKey('Executive Summary'), isTrue);
      expect(decodedExcel.sheets.containsKey('Invoices Ledger'), isTrue);
      expect(decodedExcel.sheets.containsKey('Itemized Transactions'), isTrue);
    });

    test('exportToTextAuditLog creates structured text audit report with KPIs & payment channels',
        () async {
      final tempDir = Directory.systemTemp.createTempSync('txt_audit_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final pharmacy = await db.select(db.pharmacySettingsTable).getSingle();
      final now = DateTime.now();
      final range = DateTimeRange(
        start: now.subtract(const Duration(days: 3)),
        end: now.add(const Duration(days: 1)),
      );

      final sales = await db.salesDao.getDetailedSalesReport(pharmacy.pharmacyUid, range.start, range.end);
      final kpis = await db.salesDao.getReportKpis(pharmacy.pharmacyUid, range.start, range.end);

      final txtFile = await SalesReportExporter.exportToTextAuditLog(
        sales: sales,
        kpis: kpis,
        pharmacy: pharmacy,
        period: range,
        customDirectory: tempDir.path,
      );

      expect(await txtFile.exists(), isTrue);
      expect(txtFile.path.endsWith('.txt'), isTrue);

      final content = await txtFile.readAsString();
      expect(content.contains('SMART PHARMACY - SALES VOLUME & PERFORMANCE AUDIT REPORT'), isTrue);
      expect(content.contains('1. EXECUTIVE KPI SUMMARY'), isTrue);
      expect(content.contains('2. PAYMENT METHODS AUDIT'), isTrue);
      expect(content.contains('3. INVOICES CHRONOLOGICAL AUDIT LEDGER'), isTrue);
      expect(content.contains('Cash'), isTrue);
      expect(content.contains('INV-'), isTrue);
    });
  });

  group('ReportsView UI & Interaction Tests (@ui-agent)', () {
    testWidgets('Renders KPI cards, period preset chips, dual export buttons, and invoices table',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pharmacy = await db.select(db.pharmacySettingsTable).getSingle();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentUserSessionProvider.overrideWithValue(
              createSession(UserRole.manager, pharmacyUid: pharmacy.pharmacyUid),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsView(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // 1. Verify Header & Period Filter Chips
      expect(find.text('Period:'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Custom Range...'), findsOneWidget);

      // 2. Verify Dual Exporter Buttons
      expect(find.text('Export Excel (.xlsx)'), findsOneWidget);
      expect(find.text('Export Audit Log (.txt)'), findsOneWidget);

      // 3. Verify Top 4 Primary KPI Cards
      expect(find.text('Total Invoices'), findsOneWidget);
      expect(find.text('Units Sold'), findsOneWidget);
      expect(find.text('Gross Revenue'), findsOneWidget);
      expect(find.text('Estimated Real Profit'), findsOneWidget);

      // 4. Verify Payment Channels breakdown banner
      expect(find.text('Payment Channels:'), findsOneWidget);
      expect(find.text('Cash: '), findsOneWidget);

      // 5. Verify Table Columns
      expect(find.text('Invoice #'), findsOneWidget);
      expect(find.text('Date & Time'), findsOneWidget);
      expect(find.text('Total Payable'), findsOneWidget);
      expect(find.text('Real Profit'), findsOneWidget);
      expect(find.text('Margin'), findsOneWidget);
    });

    testWidgets('Tapping line items action opens InvoiceItemsDialog modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pharmacy = await db.select(db.pharmacySettingsTable).getSingle();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentUserSessionProvider.overrideWithValue(
              createSession(UserRole.owner, pharmacyUid: pharmacy.pharmacyUid),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsView(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Tap on View Line Items button (first action button)
      final viewItemsBtn = find.byTooltip('View Line Items');
      expect(viewItemsBtn, findsWidgets);
      await tester.ensureVisible(viewItemsBtn.first);
      await tester.tap(viewItemsBtn.first);
      await tester.pumpAndSettle();

      expect(find.byType(InvoiceItemsDialog), findsOneWidget);
      expect(find.textContaining('Invoice Breakdown:'), findsOneWidget);
      expect(find.text('Medicine (Generic)'), findsOneWidget);
      expect(find.text('Batch #'), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(InvoiceItemsDialog), findsNothing);
    });

    testWidgets('Tapping receipt action opens ReceiptPreviewDialog with 80mm & 58mm toggles',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pharmacy = await db.select(db.pharmacySettingsTable).getSingle();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentUserSessionProvider.overrideWithValue(
              createSession(UserRole.owner, pharmacyUid: pharmacy.pharmacyUid),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsView(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Tap on Thermal Slip button
      final receiptBtn = find.byTooltip('Thermal Slip (80mm/58mm)');
      expect(receiptBtn, findsWidgets);
      await tester.ensureVisible(receiptBtn.first);
      await tester.tap(receiptBtn.first);
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptPreviewDialog), findsOneWidget);
      expect(find.textContaining('Thermal Receipt Preview'), findsOneWidget);
      expect(find.text('80mm (Standard)'), findsOneWidget);
      expect(find.text('58mm (Compact)'), findsOneWidget);
      expect(find.text('Save Slip (.txt)'), findsOneWidget);

      // Toggle to 58mm
      await tester.tap(find.text('58mm (Compact)'));
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(ReceiptPreviewDialog), findsNothing);
    });
  });
}
