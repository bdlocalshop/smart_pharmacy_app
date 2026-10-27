import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/features/reports/domain/report_models.dart';

/// Modal dialog showing the itemized line items of an invoice with batch details and costs.
class InvoiceItemsDialog extends StatelessWidget {
  final DetailedSaleReport report;
  final String currencySymbol;

  const InvoiceItemsDialog({
    super.key,
    required this.report,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnly = DateFormat('dd/MM/yyyy');
    final s = report.sale;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 850,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Breakdown: ${s.invoiceNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Date: ${dateFormat.format(s.createdAt)} • Cashier: ${report.cashierName} • Customer: ${s.customerName.isEmpty ? 'Walk-in' : s.customerName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Itemized Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.background),
                    horizontalMargin: 16,
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('Medicine (Generic)')),
                      DataColumn(label: Text('Batch #')),
                      DataColumn(label: Text('Expiry')),
                      DataColumn(numeric: true, label: Text('Qty')),
                      DataColumn(numeric: true, label: Text('Unit Cost')),
                      DataColumn(numeric: true, label: Text('Selling MRP')),
                      DataColumn(numeric: true, label: Text('Total')),
                      DataColumn(numeric: true, label: Text('Real Profit')),
                    ],
                    rows: report.items.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.brandName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  item.genericName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.batchNumber,
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(dateOnly.format(item.expiryDate))),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text('$currencySymbol${item.unitCostPrice.toStringAsFixed(2)}')),
                          DataCell(
                            Text('$currencySymbol${item.unitSellingPrice.toStringAsFixed(2)}'),
                          ),
                          DataCell(
                            Text(
                              '$currencySymbol${item.lineTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$currencySymbol${item.lineProfit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Summary Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Total Units: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${report.totalUnits} items'),
                    const SizedBox(width: 24),
                    const Text(
                      'Payment Method: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(s.paymentMethod),
                    const SizedBox(width: 24),
                    Text(
                      'Subtotal: $currencySymbol${s.subtotal.toStringAsFixed(2)}  •  Discount: -$currencySymbol${s.discountAmount.toStringAsFixed(2)}  •  ',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Net Paid: $currencySymbol${s.totalPayable.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Real Profit: $currencySymbol${s.grossProfit.toStringAsFixed(2)} (${report.profitMargin.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
