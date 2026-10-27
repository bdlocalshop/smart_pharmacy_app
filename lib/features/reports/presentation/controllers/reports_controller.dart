import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/reports/data/sales_report_exporter.dart';
import 'package:smart_pharmacy_app/features/reports/domain/report_models.dart';

/// Active date period filter provider.
class ReportsPeriodFilterNotifier extends Notifier<DatePeriodFilter> {
  @override
  DatePeriodFilter build() => DatePeriodFilter.today;
  void setFilter(DatePeriodFilter filter) => state = filter;
}

final reportsPeriodFilterProvider =
    NotifierProvider<ReportsPeriodFilterNotifier, DatePeriodFilter>(
  ReportsPeriodFilterNotifier.new,
);

/// Custom date range provider (used when [DatePeriodFilter.custom] is active).
class ReportsCustomRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;
  void setRange(DateTimeRange? range) => state = range;
}

final reportsCustomRangeProvider =
    NotifierProvider<ReportsCustomRangeNotifier, DateTimeRange?>(
  ReportsCustomRangeNotifier.new,
);

/// Search query provider for filtering invoices in reports table.
class ReportsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final reportsSearchQueryProvider =
    NotifierProvider<ReportsSearchQueryNotifier, String>(
  ReportsSearchQueryNotifier.new,
);

/// Payment method filter ('All', 'Cash', 'Card', 'Mobile', 'Due').
class ReportsPaymentFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void setFilter(String filter) => state = filter;
}

final reportsPaymentFilterProvider =
    NotifierProvider<ReportsPaymentFilterNotifier, String>(
  ReportsPaymentFilterNotifier.new,
);

/// State object representing the reports data and operations.
class ReportsState {
  final bool isLoading;
  final String? errorMessage;
  final String? exportMessage;
  final DateTimeRange activeRange;
  final ReportKpiMetrics kpis;
  final List<DetailedSaleReport> allSales;
  final List<DetailedSaleReport> filteredSales;
  final PharmacySetting? pharmacy;

  ReportsState({
    this.isLoading = false,
    this.errorMessage,
    this.exportMessage,
    required this.activeRange,
    required this.kpis,
    this.allSales = const [],
    this.filteredSales = const [],
    this.pharmacy,
  });

  ReportsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? exportMessage,
    DateTimeRange? activeRange,
    ReportKpiMetrics? kpis,
    List<DetailedSaleReport>? allSales,
    List<DetailedSaleReport>? filteredSales,
    PharmacySetting? pharmacy,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      exportMessage: exportMessage,
      activeRange: activeRange ?? this.activeRange,
      kpis: kpis ?? this.kpis,
      allSales: allSales ?? this.allSales,
      filteredSales: filteredSales ?? this.filteredSales,
      pharmacy: pharmacy ?? this.pharmacy,
    );
  }
}

/// Controller managing reports loading, filtering, and dual exports.
class ReportsController extends Notifier<ReportsState> {
  @override
  ReportsState build() {
    final now = DateTime.now();
    final initialRange = DatePeriodFilter.today.toDateRange(now);

    // Initial load
    Future.microtask(() => loadReportData());

    return ReportsState(
      isLoading: true,
      activeRange: initialRange,
      kpis: ReportKpiMetrics.empty(),
    );
  }

  /// Calculates the active DateTimeRange based on current filter state.
  DateTimeRange _resolveActiveRange() {
    final filter = ref.read(reportsPeriodFilterProvider);
    final customRange = ref.read(reportsCustomRangeProvider);
    final now = DateTime.now();

    if (filter == DatePeriodFilter.custom && customRange != null) {
      return customRange;
    }
    return filter.toDateRange(now);
  }

  /// Reloads sales and KPIs from the local SQLite database.
  Future<void> loadReportData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final db = ref.read(databaseProvider);
      final session = ref.read(currentUserSessionProvider);
      final pharmacyUid = session?.pharmacyUid ?? 'pharmacy-main-001';

      // 1. Fetch pharmacy settings
      final pharmacy = await (db.select(db.pharmacySettingsTable)
            ..where((tbl) => tbl.pharmacyUid.equals(pharmacyUid)))
          .getSingleOrNull();

      // 2. Fetch sales and KPI metrics
      final range = _resolveActiveRange();
      final kpis = await db.salesDao.getReportKpis(pharmacyUid, range.start, range.end);
      final sales = await db.salesDao.getDetailedSalesReport(pharmacyUid, range.start, range.end);

      final filtered = _filterSales(
        sales,
        ref.read(reportsSearchQueryProvider),
        ref.read(reportsPaymentFilterProvider),
      );

      state = state.copyWith(
        isLoading: false,
        activeRange: range,
        kpis: kpis,
        allSales: sales,
        filteredSales: filtered,
        pharmacy: pharmacy,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load sales report: ${e.toString()}',
      );
    }
  }

  /// Changes the active preset period filter.
  void setPeriodFilter(DatePeriodFilter filter) {
    ref.read(reportsPeriodFilterProvider.notifier).setFilter(filter);
    loadReportData();
  }

  /// Sets a custom date range.
  void setCustomRange(DateTimeRange range) {
    ref.read(reportsPeriodFilterProvider.notifier).setFilter(DatePeriodFilter.custom);
    ref.read(reportsCustomRangeProvider.notifier).setRange(range);
    loadReportData();
  }

  /// Updates the search filter.
  void setSearchQuery(String query) {
    ref.read(reportsSearchQueryProvider.notifier).setQuery(query);
    _applyLocalFilters();
  }

  /// Updates the payment method filter.
  void setPaymentFilter(String paymentMethod) {
    ref.read(reportsPaymentFilterProvider.notifier).setFilter(paymentMethod);
    _applyLocalFilters();
  }

  void _applyLocalFilters() {
    final query = ref.read(reportsSearchQueryProvider);
    final payment = ref.read(reportsPaymentFilterProvider);
    final filtered = _filterSales(state.allSales, query, payment);
    state = state.copyWith(filteredSales: filtered);
  }

  List<DetailedSaleReport> _filterSales(
    List<DetailedSaleReport> sales,
    String query,
    String paymentMethod,
  ) {
    return sales.where((report) {
      final s = report.sale;
      // Payment method match
      if (paymentMethod != 'All' && s.paymentMethod.toLowerCase() != paymentMethod.toLowerCase()) {
        return false;
      }

      // Search match
      if (query.trim().isEmpty) return true;
      final q = query.trim().toLowerCase();
      final matchInv = s.invoiceNumber.toLowerCase().contains(q);
      final matchCustomer = s.customerName.toLowerCase().contains(q);
      final matchPhone = (s.customerPhone ?? '').toLowerCase().contains(q);
      final matchCashier = report.cashierName.toLowerCase().contains(q);

      return matchInv || matchCustomer || matchPhone || matchCashier;
    }).toList();
  }

  /// Exports the current sales report to a formatted Excel (.xlsx) file.
  Future<File?> exportExcel({String? customDirectory}) async {
    if (state.pharmacy == null) return null;
    try {
      final file = await SalesReportExporter.exportToExcel(
        sales: state.allSales,
        kpis: state.kpis,
        pharmacy: state.pharmacy!,
        period: state.activeRange,
        customDirectory: customDirectory,
      );
      state = state.copyWith(exportMessage: 'Excel report exported successfully: ${file.path}');
      return file;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Excel export failed: ${e.toString()}');
      return null;
    }
  }

  /// Exports the current sales report to a formatted Text (.txt) audit log.
  Future<File?> exportTextAudit({String? customDirectory}) async {
    if (state.pharmacy == null) return null;
    try {
      final file = await SalesReportExporter.exportToTextAuditLog(
        sales: state.allSales,
        kpis: state.kpis,
        pharmacy: state.pharmacy!,
        period: state.activeRange,
        customDirectory: customDirectory,
      );
      state = state.copyWith(exportMessage: 'Text audit log exported successfully: ${file.path}');
      return file;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Text audit export failed: ${e.toString()}');
      return null;
    }
  }
}

/// Provider exposing the [ReportsController].
final reportsControllerProvider =
    NotifierProvider<ReportsController, ReportsState>(ReportsController.new);
