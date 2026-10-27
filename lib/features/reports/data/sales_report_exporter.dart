import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/features/reports/domain/report_models.dart';

/// Hardware & Export Integration Agent (@io-agent)
/// Generates Excel (.xlsx) workbooks and formatted Text (.txt) audit logs.
class SalesReportExporter {
  static final _fileDateFormat = DateFormat('yyyyMMdd_HHmmss');
  static final _displayDateFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateOnlyFormat = DateFormat('dd/MM/yyyy');

  /// Resolves the default export directory in the user's Documents folder.
  static Future<Directory> _getExportDirectory(String? customDirectory) async {
    if (customDirectory != null) {
      final dir = Directory(customDirectory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }

    final docDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(docDir.path, 'SmartPharmacy', 'Reports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// Exports full sales performance data to a formatted multi-sheet Excel (.xlsx) workbook.
  static Future<File> exportToExcel({
    required List<DetailedSaleReport> sales,
    required ReportKpiMetrics kpis,
    required PharmacySetting pharmacy,
    required DateTimeRange period,
    String? customDirectory,
  }) async {
    final excel = Excel.createExcel();

    // Sheet 1: Executive KPI Summary
    excel.rename('Sheet1', 'Executive Summary');
    final summarySheet = excel['Executive Summary'];

    final currency = pharmacy.currencySymbol;
    final periodStr =
        '${_displayDateFormat.format(period.start)} - ${_displayDateFormat.format(period.end)}';

    // Header info
    summarySheet.appendRow([
      TextCellValue('SMART PHARMACY - EXECUTIVE PERFORMANCE & FINANCIAL AUDIT'),
    ]);
    summarySheet.appendRow([TextCellValue('Pharmacy:'), TextCellValue(pharmacy.pharmacyName)]);
    summarySheet.appendRow([TextCellValue('Period:'), TextCellValue(periodStr)]);
    summarySheet.appendRow([
      TextCellValue('Export Timestamp:'),
      TextCellValue(_displayDateFormat.format(DateTime.now())),
    ]);
    summarySheet.appendRow([
      TextCellValue('Tenant ID:'),
      TextCellValue(pharmacy.pharmacyUid),
    ]);
    summarySheet.appendRow([TextCellValue('')]); // Spacer

    // KPI Summary Table
    summarySheet.appendRow([TextCellValue('PERFORMANCE METRIC'), TextCellValue('VALUE')]);
    summarySheet.appendRow([
      TextCellValue('Total Invoices Generated'),
      IntCellValue(kpis.totalInvoices),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total Medicine Units Sold'),
      IntCellValue(kpis.totalUnitsSold),
    ]);
    summarySheet.appendRow([
      TextCellValue('Gross Revenue ($currency)'),
      DoubleCellValue(kpis.grossRevenue),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total Deducted Batch Cost ($currency)'),
      DoubleCellValue(kpis.totalCostPrice),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total Discounts Granted ($currency)'),
      DoubleCellValue(kpis.totalDiscounts),
    ]);
    summarySheet.appendRow([
      TextCellValue('Estimated Real Profit ($currency)'),
      DoubleCellValue(kpis.grossProfit),
    ]);
    summarySheet.appendRow([
      TextCellValue('Overall Gross Profit Margin (%)'),
      DoubleCellValue(double.parse(kpis.profitMarginPercentage.toStringAsFixed(2))),
    ]);
    summarySheet.appendRow([TextCellValue('')]); // Spacer

    // Payment Methods Breakdown
    summarySheet.appendRow([
      TextCellValue('PAYMENT METHOD'),
      TextCellValue('INVOICES COUNT'),
      TextCellValue('TOTAL COLLECTED ($currency)'),
    ]);
    for (final method in ['Cash', 'Card', 'Mobile', 'Due']) {
      final count = kpis.paymentCounts[method] ?? 0;
      final amount = kpis.paymentBreakdown[method] ?? 0.0;
      summarySheet.appendRow([
        TextCellValue(method),
        IntCellValue(count),
        DoubleCellValue(amount),
      ]);
    }

    // Sheet 2: Invoices Ledger
    final invoicesSheet = excel['Invoices Ledger'];
    invoicesSheet.appendRow([
      TextCellValue('Invoice #'),
      TextCellValue('Date & Time'),
      TextCellValue('Cashier'),
      TextCellValue('Customer Name'),
      TextCellValue('Customer Phone'),
      TextCellValue('Payment Method'),
      TextCellValue('Subtotal ($currency)'),
      TextCellValue('Discount ($currency)'),
      TextCellValue('Net Payable ($currency)'),
      TextCellValue('Batch Cost ($currency)'),
      TextCellValue('Real Profit ($currency)'),
      TextCellValue('Margin (%)'),
      TextCellValue('Units Sold'),
    ]);

    for (final report in sales) {
      final s = report.sale;
      invoicesSheet.appendRow([
        TextCellValue(s.invoiceNumber),
        TextCellValue(_displayDateFormat.format(s.createdAt)),
        TextCellValue(report.cashierName),
        TextCellValue(s.customerName.isEmpty ? 'Walk-in Customer' : s.customerName),
        TextCellValue(s.customerPhone ?? 'N/A'),
        TextCellValue(s.paymentMethod),
        DoubleCellValue(s.subtotal),
        DoubleCellValue(s.discountAmount),
        DoubleCellValue(s.totalPayable),
        DoubleCellValue(s.totalCostPrice),
        DoubleCellValue(s.grossProfit),
        DoubleCellValue(double.parse(report.profitMargin.toStringAsFixed(2))),
        IntCellValue(report.totalUnits),
      ]);
    }

    // Sheet 3: Itemized Transactions Ledger
    final itemsSheet = excel['Itemized Transactions'];
    itemsSheet.appendRow([
      TextCellValue('Invoice #'),
      TextCellValue('Sale Date'),
      TextCellValue('Brand Name'),
      TextCellValue('Generic Formula'),
      TextCellValue('Category'),
      TextCellValue('Batch #'),
      TextCellValue('Expiry Date'),
      TextCellValue('Quantity Sold'),
      TextCellValue('Unit Cost ($currency)'),
      TextCellValue('Unit Selling MRP ($currency)'),
      TextCellValue('Line Total ($currency)'),
      TextCellValue('Line Cost ($currency)'),
      TextCellValue('Line Real Profit ($currency)'),
      TextCellValue('Line Margin (%)'),
    ]);

    for (final report in sales) {
      for (final item in report.items) {
        itemsSheet.appendRow([
          TextCellValue(report.sale.invoiceNumber),
          TextCellValue(_displayDateFormat.format(report.sale.createdAt)),
          TextCellValue(item.brandName),
          TextCellValue(item.genericName),
          TextCellValue(item.category),
          TextCellValue(item.batchNumber),
          TextCellValue(_dateOnlyFormat.format(item.expiryDate)),
          IntCellValue(item.quantity),
          DoubleCellValue(item.unitCostPrice),
          DoubleCellValue(item.unitSellingPrice),
          DoubleCellValue(item.lineTotal),
          DoubleCellValue(item.lineCost),
          DoubleCellValue(item.lineProfit),
          DoubleCellValue(double.parse(item.profitMargin.toStringAsFixed(2))),
        ]);
      }
    }

    // Save to file
    final exportDir = await _getExportDirectory(customDirectory);
    final timestamp = _fileDateFormat.format(DateTime.now());
    final filePath = p.join(exportDir.path, 'Sales_Report_$timestamp.xlsx');

    final file = File(filePath);
    final fileBytes = excel.save();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes, flush: true);
    }
    return file;
  }

  /// Exports comprehensive sales audit data to a structured, human-readable Text (.txt) report.
  static Future<File> exportToTextAuditLog({
    required List<DetailedSaleReport> sales,
    required ReportKpiMetrics kpis,
    required PharmacySetting pharmacy,
    required DateTimeRange period,
    String? customDirectory,
  }) async {
    final currency = pharmacy.currencySymbol;
    final buffer = StringBuffer();
    const divider = '========================================================================================';
    const subDivider = '----------------------------------------------------------------------------------------';

    // 1. Report Header
    buffer.writeln(divider);
    buffer.writeln('SMART PHARMACY - SALES VOLUME & PERFORMANCE AUDIT REPORT');
    buffer.writeln(divider);
    buffer.writeln('Pharmacy Name  : ${pharmacy.pharmacyName}');
    if (pharmacy.licenseNumber != null && pharmacy.licenseNumber!.isNotEmpty) {
      buffer.writeln('Drug Lic Number: ${pharmacy.licenseNumber}');
    }
    buffer.writeln('Contact Phone  : ${pharmacy.contactPhone}');
    buffer.writeln(
      'Audit Period   : ${_displayDateFormat.format(period.start)} to ${_displayDateFormat.format(period.end)}',
    );
    buffer.writeln('Generated At   : ${_displayDateFormat.format(DateTime.now())}');
    buffer.writeln('Tenant ID      : ${pharmacy.pharmacyUid}');
    buffer.writeln(divider);
    buffer.writeln();

    // 2. Executive KPI Summary Block
    buffer.writeln('1. EXECUTIVE KPI SUMMARY');
    buffer.writeln(subDivider);
    buffer.writeln('  Total Invoices Processed   : ${kpis.totalInvoices}');
    buffer.writeln('  Total Medicine Units Sold  : ${kpis.totalUnitsSold}');
    buffer.writeln('  Gross Revenue Generated    : $currency${kpis.grossRevenue.toStringAsFixed(2)}');
    buffer.writeln('  Total Deducted Batch Cost  : $currency${kpis.totalCostPrice.toStringAsFixed(2)}');
    buffer.writeln('  Total Discounts Granted    : $currency${kpis.totalDiscounts.toStringAsFixed(2)}');
    buffer.writeln('  Estimated Real Profit      : $currency${kpis.grossProfit.toStringAsFixed(2)}');
    buffer.writeln('  Overall Profit Margin      : ${kpis.profitMarginPercentage.toStringAsFixed(2)}%');
    buffer.writeln(subDivider);
    buffer.writeln();

    // 3. Payment Methods Breakdown
    buffer.writeln('2. PAYMENT METHODS AUDIT');
    buffer.writeln(subDivider);
    buffer.writeln(
      '  ${'Payment Method'.padRight(18)}${'Invoices'.padRight(16)}${'Total Collected'.padLeft(18)}',
    );
    buffer.writeln(subDivider);
    for (final method in ['Cash', 'Card', 'Mobile', 'Due']) {
      final count = kpis.paymentCounts[method] ?? 0;
      final amount = kpis.paymentBreakdown[method] ?? 0.0;
      final countStr = count.toString().padRight(16);
      final amtStr = '$currency${amount.toStringAsFixed(2)}'.padLeft(18);
      buffer.writeln('  ${method.padRight(18)}$countStr$amtStr');
    }
    buffer.writeln(subDivider);
    buffer.writeln();

    // 4. Invoices Chronological Audit Ledger
    buffer.writeln('3. INVOICES CHRONOLOGICAL AUDIT LEDGER');
    buffer.writeln(subDivider);
    buffer.writeln(
      '  ${'Invoice #'.padRight(20)}${'Date & Time'.padRight(18)}${'Cashier'.padRight(18)}${'Method'.padRight(10)}${'Payable'.padLeft(10)}${'Profit'.padLeft(10)}',
    );
    buffer.writeln(subDivider);

    for (final report in sales) {
      final s = report.sale;
      final inv = s.invoiceNumber.padRight(20);
      final dt = _displayDateFormat.format(s.createdAt).padRight(18);
      final cashier = (report.cashierName.length > 16
              ? report.cashierName.substring(0, 16)
              : report.cashierName)
          .padRight(18);
      final method = s.paymentMethod.padRight(10);
      final payable = '$currency${s.totalPayable.toStringAsFixed(2)}'.padLeft(10);
      final profit = '$currency${s.grossProfit.toStringAsFixed(2)}'.padLeft(10);

      buffer.writeln('  $inv$dt$cashier$method$payable$profit');
      buffer.writeln('    Customer: ${s.customerName.isEmpty ? 'Walk-in Customer' : s.customerName} | Units: ${report.totalUnits} | Margin: ${report.profitMargin.toStringAsFixed(1)}%');

      // Itemized sub-lines
      if (report.items.isNotEmpty) {
        for (final item in report.items) {
          final exp = _dateOnlyFormat.format(item.expiryDate);
          final lineProfit = '$currency${item.lineProfit.toStringAsFixed(2)}';
          buffer.writeln(
            '      - ${item.brandName} (${item.genericName}) | Batch: ${item.batchNumber} (Exp: $exp) | Qty: ${item.quantity} | Sell: $currency${item.unitSellingPrice.toStringAsFixed(2)} | Cost: $currency${item.unitCostPrice.toStringAsFixed(2)} | Profit: $lineProfit',
          );
        }
      }
      buffer.writeln();
    }

    buffer.writeln(divider);
    buffer.writeln('[End of Audit Report - Generated by Smart Pharmacy Desktop System]');
    buffer.writeln(divider);

    // Save to file
    final exportDir = await _getExportDirectory(customDirectory);
    final timestamp = _fileDateFormat.format(DateTime.now());
    final filePath = p.join(exportDir.path, 'Sales_Audit_Log_$timestamp.txt');

    final file = File(filePath);
    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }
}
