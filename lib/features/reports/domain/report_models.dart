import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';

/// Preset and custom period filters for sales performance reports.
enum DatePeriodFilter {
  today(label: 'Today'),
  yesterday(label: 'Yesterday'),
  thisWeek(label: 'This Week'),
  thisMonth(label: 'This Month'),
  last7Days(label: 'Last 7 Days'),
  last30Days(label: 'Last 30 Days'),
  thisYear(label: 'This Year'),
  custom(label: 'Custom Range');

  final String label;
  const DatePeriodFilter({required this.label});

  DateTimeRange toDateRange(DateTime referenceNow) {
    final y = referenceNow.year;
    final m = referenceNow.month;
    final d = referenceNow.day;

    return switch (this) {
      DatePeriodFilter.today => DateTimeRange(
          start: DateTime(y, m, d, 0, 0, 0),
          end: DateTime(y, m, d, 23, 59, 59, 999),
        ),
      DatePeriodFilter.yesterday => DateTimeRange(
          start: DateTime(y, m, d - 1, 0, 0, 0),
          end: DateTime(y, m, d - 1, 23, 59, 59, 999),
        ),
      DatePeriodFilter.thisWeek => () {
          // In Dart, Monday is 1, Sunday is 7
          final monday = referenceNow.subtract(Duration(days: referenceNow.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          return DateTimeRange(
            start: DateTime(monday.year, monday.month, monday.day, 0, 0, 0),
            end: DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999),
          );
        }(),
      DatePeriodFilter.thisMonth => () {
          final firstDay = DateTime(y, m, 1, 0, 0, 0);
          final lastDay = DateTime(y, m + 1, 0, 23, 59, 59, 999);
          return DateTimeRange(start: firstDay, end: lastDay);
        }(),
      DatePeriodFilter.last7Days => DateTimeRange(
          start: DateTime(y, m, d - 6, 0, 0, 0),
          end: DateTime(y, m, d, 23, 59, 59, 999),
        ),
      DatePeriodFilter.last30Days => DateTimeRange(
          start: DateTime(y, m, d - 29, 0, 0, 0),
          end: DateTime(y, m, d, 23, 59, 59, 999),
        ),
      DatePeriodFilter.thisYear => DateTimeRange(
          start: DateTime(y, 1, 1, 0, 0, 0),
          end: DateTime(y, 12, 31, 23, 59, 59, 999),
        ),
      DatePeriodFilter.custom => DateTimeRange(
          start: DateTime(y, m, d, 0, 0, 0),
          end: DateTime(y, m, d, 23, 59, 59, 999),
        ),
    };
  }
}

/// Itemized line transaction for audit and reporting.
class DetailedSaleItemReport {
  final String id;
  final String saleId;
  final String invoiceNumber;
  final DateTime saleDate;
  final String productId;
  final String brandName;
  final String genericName;
  final String category;
  final String batchId;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantity;
  final double unitCostPrice;
  final double unitSellingPrice;
  final double lineTotal;

  DetailedSaleItemReport({
    required this.id,
    required this.saleId,
    required this.invoiceNumber,
    required this.saleDate,
    required this.productId,
    required this.brandName,
    required this.genericName,
    required this.category,
    required this.batchId,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.unitCostPrice,
    required this.unitSellingPrice,
    required this.lineTotal,
  });

  double get lineCost => unitCostPrice * quantity;
  double get lineProfit => lineTotal - lineCost;
  double get profitMargin => lineTotal > 0 ? (lineProfit / lineTotal) * 100 : 0.0;
}

/// High-level invoice report with cashier details and item breakdown.
class DetailedSaleReport {
  final Sale sale;
  final String cashierName;
  final int totalUnits;
  final List<DetailedSaleItemReport> items;

  DetailedSaleReport({
    required this.sale,
    required this.cashierName,
    required this.totalUnits,
    required this.items,
  });

  double get profitMargin =>
      sale.totalPayable > 0 ? (sale.grossProfit / sale.totalPayable) * 100 : 0.0;
}

/// Aggregated KPI metrics for sales and financial performance.
class ReportKpiMetrics {
  final int totalInvoices;
  final int totalUnitsSold;
  final double grossRevenue;
  final double totalCostPrice;
  final double grossProfit;
  final double totalDiscounts;
  final Map<String, double> paymentBreakdown;
  final Map<String, int> paymentCounts;

  ReportKpiMetrics({
    required this.totalInvoices,
    required this.totalUnitsSold,
    required this.grossRevenue,
    required this.totalCostPrice,
    required this.grossProfit,
    required this.totalDiscounts,
    required this.paymentBreakdown,
    required this.paymentCounts,
  });

  double get profitMarginPercentage =>
      grossRevenue > 0 ? (grossProfit / grossRevenue) * 100 : 0.0;

  static ReportKpiMetrics empty() {
    return ReportKpiMetrics(
      totalInvoices: 0,
      totalUnitsSold: 0,
      grossRevenue: 0.0,
      totalCostPrice: 0.0,
      grossProfit: 0.0,
      totalDiscounts: 0.0,
      paymentBreakdown: {
        'Cash': 0.0,
        'Card': 0.0,
        'Mobile': 0.0,
        'Due': 0.0,
      },
      paymentCounts: {
        'Cash': 0,
        'Card': 0,
        'Mobile': 0,
        'Due': 0,
      },
    );
  }
}
