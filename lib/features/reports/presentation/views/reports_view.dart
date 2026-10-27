import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/services/thermal_receipt_generator.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/controllers/reports_controller.dart';
import 'package:smart_pharmacy_app/features/reports/domain/report_models.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/widgets/custom_range_picker_dialog.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/widgets/invoice_items_dialog.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/widgets/receipt_preview_dialog.dart';

/// Sales Volume & Performance Reports Screen.
class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final controller = ref.read(reportsControllerProvider.notifier);
    final activeFilter = ref.watch(reportsPeriodFilterProvider);
    final selectedPayment = ref.watch(reportsPaymentFilterProvider);
    final session = ref.watch(currentUserSessionProvider);
    final role = session?.role ?? UserRole.manager;

    final currency = state.pharmacy?.currencySymbol ?? '\$';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnly = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top Filter & Export Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Period:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 12),

                  // Period Preset Filter Chips with scroll protection
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPeriodChip(
                            context,
                            filter: DatePeriodFilter.today,
                            activeFilter: activeFilter,
                            onSelect: () => controller.setPeriodFilter(DatePeriodFilter.today),
                          ),
                          const SizedBox(width: 8),
                          _buildPeriodChip(
                            context,
                            filter: DatePeriodFilter.yesterday,
                            activeFilter: activeFilter,
                            onSelect: () => controller.setPeriodFilter(DatePeriodFilter.yesterday),
                          ),
                          const SizedBox(width: 8),
                          _buildPeriodChip(
                            context,
                            filter: DatePeriodFilter.thisWeek,
                            activeFilter: activeFilter,
                            onSelect: () => controller.setPeriodFilter(DatePeriodFilter.thisWeek),
                          ),
                          const SizedBox(width: 8),
                          _buildPeriodChip(
                            context,
                            filter: DatePeriodFilter.thisMonth,
                            activeFilter: activeFilter,
                            onSelect: () => controller.setPeriodFilter(DatePeriodFilter.thisMonth),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.date_range, size: 15),
                            label: Text(
                              activeFilter == DatePeriodFilter.custom
                                  ? 'Custom: ${dateOnly.format(state.activeRange.start)} - ${dateOnly.format(state.activeRange.end)}'
                                  : 'Custom Range...',
                            ),
                            backgroundColor: activeFilter == DatePeriodFilter.custom
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : null,
                            side: activeFilter == DatePeriodFilter.custom
                                ? const BorderSide(color: AppColors.primary, width: 1.5)
                                : null,
                            onPressed: () async {
                              final range = await showDialog<DateTimeRange>(
                                context: context,
                                builder: (ctx) =>
                                    CustomRangePickerDialog(initialRange: state.activeRange),
                              );
                              if (range != null) {
                                controller.setCustomRange(range);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Dual Exporters
                  OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart, size: 16, color: Colors.green),
                    label: const Text('Export Excel (.xlsx)'),
                    onPressed: state.isLoading || state.allSales.isEmpty
                        ? null
                        : () async {
                            final file = await controller.exportExcel();
                            if (context.mounted && file != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Excel workbook exported: ${file.path}'),
                                  backgroundColor: AppColors.primaryDark,
                                ),
                              );
                            }
                          },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 16, color: Colors.blueGrey),
                    label: const Text('Export Audit Log (.txt)'),
                    onPressed: state.isLoading || state.allSales.isEmpty
                        ? null
                        : () async {
                            final file = await controller.exportTextAudit();
                            if (context.mounted && file != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Text audit log exported: ${file.path}'),
                                  backgroundColor: AppColors.primaryDark,
                                ),
                              );
                            }
                          },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Refresh Metrics',
                    onPressed: () => controller.loadReportData(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Active Window: ${dateFormat.format(state.activeRange.start)} to ${dateFormat.format(state.activeRange.end)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Primary KPI Cards
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Total Invoices',
                value: '${state.kpis.totalInvoices}',
                subtitle: state.kpis.totalInvoices > 0
                    ? 'Avg: $currency${(state.kpis.grossRevenue / state.kpis.totalInvoices).toStringAsFixed(2)} / inv'
                    : 'No sales recorded',
                icon: Icons.receipt_long,
                iconColor: AppColors.cyan,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildKpiCard(
                title: 'Units Sold',
                value: '${state.kpis.totalUnitsSold} Units',
                subtitle: 'Across all deducted batches',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.purple,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildKpiCard(
                title: 'Gross Revenue',
                value: '$currency${state.kpis.grossRevenue.toStringAsFixed(2)}',
                subtitle: 'Discounts: -$currency${state.kpis.totalDiscounts.toStringAsFixed(2)}',
                icon: Icons.payments_outlined,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildKpiCard(
                title: 'Estimated Real Profit',
                value: '$currency${state.kpis.grossProfit.toStringAsFixed(2)}',
                subtitle:
                    'Margin: ${state.kpis.profitMarginPercentage.toStringAsFixed(1)}% • Cost: $currency${state.kpis.totalCostPrice.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                iconColor: AppColors.accent,
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. Payment Methods Breakdown Strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text(
                'Payment Channels:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 16),
              ...['Cash', 'Card', 'Mobile', 'Due'].map((method) {
                final amt = state.kpis.paymentBreakdown[method] ?? 0.0;
                final count = state.kpis.paymentCounts[method] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPaymentColor(method),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$method: ',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      Text(
                        '$currency${amt.toStringAsFixed(2)} ($count)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Invoices Ledger & Filter Bar
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter controls
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Search by Invoice #, Customer, Phone, or Cashier...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onChanged: controller.setSearchQuery,
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: selectedPayment,
                        underline: const SizedBox.shrink(),
                        items: ['All', 'Cash', 'Card', 'Mobile', 'Due'].map((p) {
                          return DropdownMenuItem(value: p, child: Text('Payment: $p'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.setPaymentFilter(val);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Table View
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.filteredSales.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.query_stats, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No sales invoices found for the selected period & filters.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                  horizontalMargin: 16,
                                  columnSpacing: 16,
                                  columns: [
                                    const DataColumn(label: Text('Invoice #')),
                                    const DataColumn(label: Text('Actions')),
                                    const DataColumn(label: Text('Date & Time')),
                                    const DataColumn(label: Text('Customer')),
                                    const DataColumn(label: Text('Cashier')),
                                    const DataColumn(label: Text('Method')),
                                    const DataColumn(numeric: true, label: Text('Units')),
                                    const DataColumn(numeric: true, label: Text('Total Payable')),
                                    if (role.canViewProfits) ...[
                                      const DataColumn(numeric: true, label: Text('Batch Cost')),
                                      const DataColumn(numeric: true, label: Text('Real Profit')),
                                      const DataColumn(numeric: true, label: Text('Margin')),
                                    ],
                                  ],
                                  rows: state.filteredSales.map((report) {
                                    final s = report.sale;
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            s.invoiceNumber,
                                            style: const TextStyle(
                                              fontFamily: 'Courier',
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 18,
                                                  color: AppColors.primary,
                                                ),
                                                tooltip: 'View Line Items',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) => InvoiceItemsDialog(
                                                      report: report,
                                                      currencySymbol: currency,
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.receipt_outlined,
                                                  size: 18,
                                                  color: AppColors.primaryDark,
                                                ),
                                                tooltip: 'Thermal Slip (80mm/58mm)',
                                                onPressed: () {
                                                  final receiptData = _toReceiptData(
                                                    report: report,
                                                    pharmacy: state.pharmacy,
                                                  );
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) => ReceiptPreviewDialog(
                                                      receiptData: receiptData,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(dateFormat.format(s.createdAt))),
                                        DataCell(
                                          Text(
                                            s.customerName.isEmpty
                                                ? 'Walk-in Customer'
                                                : s.customerName,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        DataCell(
                                          Text(report.cashierName, style: const TextStyle(fontSize: 12)),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPaymentColor(s.paymentMethod).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              s.paymentMethod,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _getPaymentColor(s.paymentMethod),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text('${report.totalUnits}')),
                                        DataCell(
                                          Text(
                                            '$currency${s.totalPayable.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (role.canViewProfits) ...[
                                          DataCell(Text('$currency${s.totalCostPrice.toStringAsFixed(2)}')),
                                          DataCell(
                                            Text(
                                              '$currency${s.grossProfit.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: AppColors.accent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text('${report.profitMargin.toStringAsFixed(1)}%'),
                                          ),
                                        ],
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(
    BuildContext context, {
    required DatePeriodFilter filter,
    required DatePeriodFilter activeFilter,
    required VoidCallback onSelect,
  }) {
    final isSelected = filter == activeFilter;
    return ChoiceChip(
      label: Text(filter.label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? AppColors.accent.withValues(alpha: 0.6) : AppColors.border,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: highlight ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String method) {
    return switch (method.toLowerCase()) {
      'cash' => AppColors.accent,
      'card' => AppColors.cyan,
      'mobile' => AppColors.purple,
      'due' => AppColors.warning,
      _ => AppColors.textSecondary,
    };
  }

  ReceiptInvoiceData _toReceiptData({
    required DetailedSaleReport report,
    required dynamic pharmacy,
  }) {
    final s = report.sale;
    return ReceiptInvoiceData(
      pharmacyName: pharmacy?.pharmacyName ?? 'Smart Pharmacy & Healthcare',
      licenseNumber: pharmacy?.licenseNumber,
      contactPhone: pharmacy?.contactPhone ?? '+880 1717-449639',
      address: pharmacy?.address,
      currencySymbol: pharmacy?.currencySymbol ?? '\$',
      invoiceNumber: s.invoiceNumber,
      date: s.createdAt,
      cashierName: report.cashierName,
      customerName: s.customerName.isEmpty ? 'Walk-in Customer' : s.customerName,
      customerPhone: s.customerPhone,
      items: report.items.map((item) {
        return ReceiptLineItem(
          brandName: item.brandName,
          genericName: item.genericName,
          batchNumber: item.batchNumber,
          expiryDate: item.expiryDate,
          quantity: item.quantity,
          unitSellingPrice: item.unitSellingPrice,
          lineTotal: item.lineTotal,
        );
      }).toList(),
      subtotal: s.subtotal,
      discountAmount: s.discountAmount,
      taxAmount: s.taxAmount,
      totalPayable: s.totalPayable,
      paymentMethod: s.paymentMethod,
      amountTendered: s.amountTendered,
      changeReturned: s.changeReturned,
    );
  }
}
