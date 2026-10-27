import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/localization/language_controller.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import 'batch_management_dialog.dart';
import 'medicine_dialog.dart';
import '../../../../core/widgets/voice_input_suffix_icon.dart';

/// Desktop Medicine Master Catalog view with search, filter chips, and stock indicators.
class MedicinesMasterView extends ConsumerStatefulWidget {
  const MedicinesMasterView({super.key});

  @override
  ConsumerState<MedicinesMasterView> createState() => _MedicinesMasterViewState();
}

class _MedicinesMasterViewState extends ConsumerState<MedicinesMasterView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider) ?? UserRole.salesman;
    final canManage = role.canManageInventory;
    final productsAsync = ref.watch(productsWithStockProvider);
    final strings = ref.watch(appStringsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Notice Banner for Salesman
        if (!canManage)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.salesmanViewNotice,
                    style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

        // Action Toolbar & Search Bar
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          ref.read(medicineSearchQueryProvider.notifier).state = val;
                        },
                        decoration: InputDecoration(
                          hintText: strings.searchCatalogHint,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(medicineSearchQueryProvider.notifier).state = '';
                                  },
                                ),
                              VoiceInputSuffixIcon(
                                controller: _searchController,
                                tooltip: 'Voice Search Catalog',
                                onChanged: (val) {
                                  ref.read(medicineSearchQueryProvider.notifier).state = val;
                                },
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add Medicine Button (Owner/Manager only)
                    if (canManage)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(strings.addMedicineF3, style: const TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const MedicineDialog(),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category Filter Chips
                Row(
                  children: [
                    Text(strings.categoryLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', displayLabel: strings.catAll),
                            _buildFilterChip('Analgesic / Antipyretic'),
                            _buildFilterChip('Antibiotic'),
                            _buildFilterChip('Gastrointestinal / PPI'),
                            _buildFilterChip('Antihistamine'),
                            _buildFilterChip('Antidiabetic'),
                            _buildFilterChip('Cardiovascular'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Data Table
        productsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (err, _) => Center(
            child: Text('Error loading inventory: $err', style: const TextStyle(color: AppColors.alertCritical)),
          ),
          data: (products) {
            // Filter by category if selected
            final filtered = _selectedCategory == 'All'
                ? products
                : products.where((p) => p.product.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No medicines matching your search criteria.',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      if (canManage)
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add This Medicine'),
                          onPressed: () => showDialog(context: context, builder: (_) => const MedicineDialog()),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text(strings.colMedBrandGeneric, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 3, child: Text(strings.colCategoryManufacturer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text(strings.colShelfLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text(strings.colActiveStockFefo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text(strings.colEarliestExpiry, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 3, child: Text(strings.colActions, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),

                  // Table Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      final p = item.product;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            // Brand & Generic
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        p.brandName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          p.unitType,
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.genericName,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),

                            // Category & Manufacturer
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                  Text(p.manufacturer, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),

                            // Shelf Location (Physical Rack Locator)
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

                            // Active Stock & Low Stock Alert
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        '${item.activeStock} units',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: item.activeStock == 0
                                              ? AppColors.alertCritical
                                              : (item.isLowStock ? AppColors.alertWarning : AppColors.alertSafe),
                                        ),
                                      ),
                                      if (item.isLowStock)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.alertWarning.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(strings.lowStockTag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.alertWarning)),
                                        ),
                                    ],
                                  ),
                                  Text('${strings.thresholdPrefix} ${p.minStockAlert} units', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  if (item.expiredStock > 0)
                                    Text(strings.expiredCount(item.expiredStock), style: const TextStyle(fontSize: 10, color: AppColors.alertCritical, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                            // Earliest Expiry (FEFO Tracker)
                            Expanded(
                              flex: 2,
                              child: item.earliestExpiry != null
                                  ? Text(
                                      DateFormat('yyyy-MM-dd').format(item.earliestExpiry!),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    )
                                  : Text(strings.noBatches, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ),

                            // Action Buttons
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Batches Button (All roles)
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.inventory, size: 14),
                                        label: Text(strings.batchCountLabel(item.batchCount)),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => BatchManagementDialog(product: p),
                                          );
                                        },
                                      ),

                                      // Edit & Delete (Manager/Owner only)
                                      if (canManage) ...[
                                        const SizedBox(width: 6),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Details',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => MedicineDialog(existingProduct: p),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.alertCritical),
                                          tooltip: 'Delete Medicine',
                                          onPressed: () => _confirmDelete(p),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
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
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {String? displayLabel}) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(displayLabel ?? label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        visualDensity: VisualDensity.compact,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primaryDark,
        onSelected: (_) => setState(() => _selectedCategory = label),
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: Text('Are you sure you want to soft-delete "${product.brandName}"? Existing sales transaction history will remain intact for reporting.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCritical, foregroundColor: Colors.white),
            onPressed: () async {
              final session = ref.read(currentUserSessionProvider);
              if (session != null) {
                final repo = ref.read(inventoryRepositoryProvider);
                await repo.deleteProduct(session.pharmacyUid, product.id);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
