import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/localization/app_strings.dart';
import 'package:smart_pharmacy_app/core/localization/language_controller.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/batch_management_dialog.dart';

/// Expiry Radar & Stock Threshold Alerts Screen with multi-tier urgency filters.
class ExpiryRadarView extends ConsumerStatefulWidget {
  const ExpiryRadarView({super.key});

  @override
  ConsumerState<ExpiryRadarView> createState() => _ExpiryRadarViewState();
}

class _ExpiryRadarViewState extends ConsumerState<ExpiryRadarView> {
  int _selectedFilterTab = 0; // 0: All, 1: Expired, 2: <30d, 3: 31-60d, 4: 61-90d, 5: Low Stock

  @override
  Widget build(BuildContext context) {
    final expiredAsync = ref.watch(expiredBatchesProvider);
    final urgentAsync = ref.watch(urgentExpiringBatchesProvider);
    final warningAsync = ref.watch(warningExpiringBatchesProvider);
    final cautionAsync = ref.watch(cautionExpiringBatchesProvider);
    final lowStockList = ref.watch(lowStockProductsProvider);
    final strings = ref.watch(appStringsProvider);

    final expiredList = expiredAsync.value ?? [];
    final urgentList = urgentAsync.value ?? [];
    final warningList = warningAsync.value ?? [];
    final cautionList = cautionAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Urgency KPI Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildRadarKpiCard(
                title: strings.radarExpiredTitle,
                count: '${expiredList.length}',
                unitCount: '${expiredList.fold<int>(0, (s, b) => s + b.batch.currentStock)} ${strings.unitsLabel}',
                subtitle: strings.radarExpiredSub,
                color: AppColors.alertCritical,
                icon: Icons.cancel_outlined,
                isSelected: _selectedFilterTab == 1,
                onTap: () => setState(() => _selectedFilterTab = 1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildRadarKpiCard(
                title: strings.radarUnder30Title,
                count: '${urgentList.length}',
                unitCount: '${urgentList.fold<int>(0, (s, b) => s + b.batch.currentStock)} ${strings.unitsLabel}',
                subtitle: strings.radarUnder30Sub,
                color: AppColors.alertUrgent,
                icon: Icons.warning_amber_rounded,
                isSelected: _selectedFilterTab == 2,
                onTap: () => setState(() => _selectedFilterTab = 2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildRadarKpiCard(
                title: strings.radar31To60Title,
                count: '${warningList.length}',
                unitCount: '${warningList.fold<int>(0, (s, b) => s + b.batch.currentStock)} ${strings.unitsLabel}',
                subtitle: strings.radar31To60Sub,
                color: AppColors.alertWarning,
                icon: Icons.hourglass_top,
                isSelected: _selectedFilterTab == 3,
                onTap: () => setState(() => _selectedFilterTab = 3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildRadarKpiCard(
                title: strings.radar61To90Title,
                count: '${cautionList.length}',
                unitCount: '${cautionList.fold<int>(0, (s, b) => s + b.batch.currentStock)} ${strings.unitsLabel}',
                subtitle: strings.radar61To90Sub,
                color: AppColors.alertCaution,
                icon: Icons.timelapse,
                isSelected: _selectedFilterTab == 4,
                onTap: () => setState(() => _selectedFilterTab = 4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildRadarKpiCard(
                title: strings.radarLowStockTitle,
                count: '${lowStockList.length}',
                unitCount: strings.medicinesLabel,
                subtitle: strings.radarLowStockSub,
                color: Colors.deepPurple,
                icon: Icons.production_quantity_limits,
                isSelected: _selectedFilterTab == 5,
                onTap: () => setState(() => _selectedFilterTab = 5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Filter Tab Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTabButton(0, '${strings.radarAllAlerts} (${expiredList.length + urgentList.length + warningList.length + cautionList.length + lowStockList.length})'),
              const SizedBox(width: 8),
              _buildTabButton(1, '${strings.radarExpiredFilter} (${expiredList.length})', color: AppColors.alertCritical),
              const SizedBox(width: 8),
              _buildTabButton(2, '${strings.radarUrgentFilter} (${urgentList.length})', color: AppColors.alertUrgent),
              const SizedBox(width: 8),
              _buildTabButton(3, '${strings.radarWarningFilter} (${warningList.length})', color: AppColors.alertWarning),
              const SizedBox(width: 8),
              _buildTabButton(4, '${strings.radarCautionFilter} (${cautionList.length})', color: AppColors.alertCaution),
              const SizedBox(width: 8),
              _buildTabButton(5, '${strings.radarLowStockFilter} (${lowStockList.length})', color: Colors.deepPurple),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Main Alert Content Display
        if (_selectedFilterTab == 5)
          _buildLowStockTable(lowStockList, strings)
        else
          _buildExpiryAlertsTable(
            expired: _selectedFilterTab == 0 || _selectedFilterTab == 1 ? expiredList : [],
            urgent: _selectedFilterTab == 0 || _selectedFilterTab == 2 ? urgentList : [],
            warning: _selectedFilterTab == 0 || _selectedFilterTab == 3 ? warningList : [],
            caution: _selectedFilterTab == 0 || _selectedFilterTab == 4 ? cautionList : [],
            strings: strings,
          ),
      ],
    );
  }

  Widget _buildRadarKpiCard({
    required String title,
    required String count,
    required String unitCount,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  count,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 6),
                Text(unitCount, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, {Color? color}) {
    final isSelected = _selectedFilterTab == index;
    final activeColor = color ?? AppColors.primary;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? activeColor.withValues(alpha: 0.12) : AppColors.surface,
        side: BorderSide(
          color: isSelected ? activeColor : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _selectedFilterTab = index),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? (color ?? AppColors.primaryDark) : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExpiryAlertsTable({
    required List<BatchWithProductInfo> expired,
    required List<BatchWithProductInfo> urgent,
    required List<BatchWithProductInfo> warning,
    required List<BatchWithProductInfo> caution,
    required AppStrings strings,
  }) {
    final allItems = [...expired, ...urgent, ...warning, ...caution];

    if (allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, size: 52, color: AppColors.accent),
              const SizedBox(height: 12),
              Text(
                strings.noExpiringStockTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 4),
              Text(strings.noExpiringStockSub, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(strings.colMedBrandGeneric, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colShelfLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colBatchSupplier, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colStockRemaining, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colExpiryDateStatus, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colActions, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = allItems[i];
                      final b = item.batch;
                      final p = item.product;
                      final days = item.daysUntilExpiry;
                      final isExpired = days < 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            // Brand & Generic
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.brandName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    p.genericName,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Physical Shelf Locator
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.shelves, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      p.shelfLocation,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                    // Batch # & Supplier
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batch #${b.batchNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(b.supplierName ?? 'Direct Store', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),

                    // Stock Remaining
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.currentStock} ${strings.unitsLabel}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('MRP: ৳${b.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    // Expiry Date & Urgency Indicator
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(b.expiryDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isExpired ? AppColors.alertCritical : AppColors.textPrimary,
                            ),
                          ),
                          _buildUrgencyChip(days, strings),
                        ],
                      ),
                    ),

                    // Action
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isExpired ? AppColors.alertCritical : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BatchManagementDialog(product: p),
                              );
                            },
                            child: Text(isExpired ? strings.disposeReturn : strings.inspectBatch, style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(int days, AppStrings strings) {
    if (days < 0) {
      return Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.alertCritical.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
        child: Text(strings.expiredDaysAgo(-days), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.alertCritical)),
      );
    } else if (days <= 30) {
      return Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.alertUrgent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
        child: Text(strings.urgentDaysLeft(days), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.alertUrgent)),
      );
    } else if (days <= 60) {
      return Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.alertWarning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
        child: Text(strings.warningDaysLeft(days), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.alertWarning)),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.alertCaution.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
        child: Text(strings.cautionDaysLeft(days), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
      );
    }
  }

  Widget _buildLowStockTable(List<ProductWithAggregateStock> lowStockItems, AppStrings strings) {
    if (lowStockItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, size: 52, color: AppColors.accent),
              const SizedBox(height: 12),
              Text(strings.allStockAboveReorder, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(strings.colMedBrandGeneric, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colShelfLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.availableActiveStock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.reorderThreshold, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.shortageCount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(strings.colActions, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStockItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = lowStockItems[i];
              final p = item.product;
              final deficit = p.minStockAlert - item.activeStock;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.brandName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(p.genericName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(Icons.shelves, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(p.shelfLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${item.activeStock} ${strings.unitsLabel}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.alertWarning)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${p.minStockAlert} ${strings.unitsLabel}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(strings.belowMinAlert(deficit), style: const TextStyle(color: AppColors.alertCritical, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 14),
                            label: Text(strings.procureBatch, style: const TextStyle(fontSize: 11)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BatchManagementDialog(product: p),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
