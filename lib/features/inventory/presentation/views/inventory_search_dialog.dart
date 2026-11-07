import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';

/// Data payload passed to the background search isolate.
class InventoryBackgroundSearchPayload {
  final List<InventoryStatusItem> allItems;
  final String query;

  const InventoryBackgroundSearchPayload({
    required this.allItems,
    required this.query,
  });
}

/// Aggregated inventory valuation and filtered items computed in the background isolate.
class InventoryBackgroundSearchResult {
  final List<InventoryStatusItem> filteredItems;
  final int totalMedicinesCount;
  final int totalStockUnits;
  final double totalPurchaseCost;
  final double totalSaleValue;
  final double totalEstimatedProfit;
  final double overallMargin;

  const InventoryBackgroundSearchResult({
    required this.filteredItems,
    required this.totalMedicinesCount,
    required this.totalStockUnits,
    required this.totalPurchaseCost,
    required this.totalSaleValue,
    required this.totalEstimatedProfit,
    required this.overallMargin,
  });
}

/// Parameters passed to the background CSV generation isolate.
class CsvExportPayload {
  final List<InventoryStatusItem> items;
  final String currencySymbol;
  final String targetFilePath;

  const CsvExportPayload({
    required this.items,
    required this.currencySymbol,
    required this.targetFilePath,
  });
}

/// Top-level worker function executed on a dedicated background isolate (thread).
///
/// Keeps Flutter's main UI thread completely unblocked even when filtering and summing
/// hundreds of thousands of medicines and batches in large pharmacy databases.
InventoryBackgroundSearchResult filterAndAggregateInventoryInBackground(
    InventoryBackgroundSearchPayload payload) {
  final query = payload.query.trim().toLowerCase();
  final allItems = payload.allItems;

  List<InventoryStatusItem> filtered;

  if (query.isEmpty || query == 'all') {
    filtered = allItems;
  } else {
    final terms = query
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty && t != 'all')
        .toList();

    if (terms.isEmpty) {
      filtered = allItems;
    } else {
      filtered = allItems.where((item) {
        final brand = item.product.brandName.toLowerCase();
        final generic = item.product.genericName.toLowerCase();
        final category = item.product.category.toLowerCase();
        final shelf = item.product.shelfLocation.toLowerCase();

        return terms.any((term) =>
            brand.contains(term) ||
            generic.contains(term) ||
            category.contains(term) ||
            shelf.contains(term));
      }).toList();
    }
  }

  // Compute sums and margins on the background thread
  final totalCount = filtered.length;
  int totalStock = 0;
  double totalCost = 0.0;
  double totalSale = 0.0;

  for (final item in filtered) {
    totalStock += item.activeStock;
    totalCost += item.totalPurchaseCost;
    totalSale += item.totalSaleValue;
  }

  final totalProfit = (totalSale - totalCost).clamp(0.0, double.infinity);
  final overallMargin = totalSale > 0 ? (totalProfit / totalSale) * 100.0 : 0.0;

  return InventoryBackgroundSearchResult(
    filteredItems: filtered,
    totalMedicinesCount: totalCount,
    totalStockUnits: totalStock,
    totalPurchaseCost: totalCost,
    totalSaleValue: totalSale,
    totalEstimatedProfit: totalProfit,
    overallMargin: overallMargin,
  );
}

/// Top-level worker function executing CSV string formatting and disk writing
/// on a dedicated background isolate (thread).
String generateAndSaveCsvInBackground(CsvExportPayload payload) {
  final items = payload.items;
  final currencySymbol = payload.currencySymbol;

  int totalStock = 0;
  double totalCost = 0.0;
  double totalSale = 0.0;
  int totalBatches = 0;

  for (final i in items) {
    totalStock += i.activeStock;
    totalCost += i.totalPurchaseCost;
    totalSale += i.totalSaleValue;
    totalBatches += i.batchCount;
  }

  final totalProfit = (totalSale - totalCost).clamp(0.0, double.infinity);
  final overallMargin = totalSale > 0 ? (totalProfit / totalSale) * 100.0 : 0.0;

  final rows = <List<dynamic>>[
    [
      'Medicine Name (Brand)',
      'Generic Formula',
      'Dispensing Unit Type',
      'Physical Shelf Location',
      'In-Stock Units',
      'Active Batches Count',
      'Total Purchase Cost ($currencySymbol)',
      'Total Sale Price ($currencySymbol)',
      'Estimated Profit ($currencySymbol)',
      'Gross Margin (%)',
    ],
    ...items.map((item) {
      return [
        item.product.brandName,
        item.product.genericName,
        item.product.unitType,
        item.product.shelfLocation,
        item.activeStock,
        item.batchCount,
        item.totalPurchaseCost.toStringAsFixed(2),
        item.totalSaleValue.toStringAsFixed(2),
        item.estimatedProfit.toStringAsFixed(2),
        '${item.grossMargin.toStringAsFixed(1)}%',
      ];
    }),
    [
      'TOTAL / SUMMARY (${items.length} medicines)',
      '',
      '',
      '',
      totalStock,
      totalBatches,
      totalCost.toStringAsFixed(2),
      totalSale.toStringAsFixed(2),
      totalProfit.toStringAsFixed(2),
      '${overallMargin.toStringAsFixed(1)}%',
    ],
  ];

  final csvContent = Csv().encode(rows);
  final targetFile = File(payload.targetFilePath);
  targetFile.writeAsStringSync(csvContent);
  return targetFile.path;
}

/// Modal dialog for searching inventory valuation, stock counts, purchase costs,
/// and retail sale values across single or multiple comma-separated medicines,
/// processed on a separate background worker thread for smooth desktop responsiveness.
class InventorySearchDialog extends ConsumerStatefulWidget {
  const InventorySearchDialog({super.key});

  @override
  ConsumerState<InventorySearchDialog> createState() => _InventorySearchDialogState();
}

class _InventorySearchDialogState extends ConsumerState<InventorySearchDialog> {
  late final TextEditingController _searchController;
  String _activeQuery = 'all';
  bool _isSearching = false;
  bool _isExporting = false;
  int _searchSessionId = 0;

  List<InventoryStatusItem>? _cachedAllItems;
  InventoryBackgroundSearchResult? _searchResult;

  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'all');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _executeSearch() {
    final query = _searchController.text.trim();
    if (_cachedAllItems != null) {
      _runBackgroundSearch(_cachedAllItems!, query);
    } else {
      setState(() {
        _activeQuery = query;
        _currentPage = 1;
      });
    }
  }

  /// Offloads search filtering and heavy aggregate calculations to a background worker isolate.
  Future<void> _runBackgroundSearch(List<InventoryStatusItem> allItems, String query) async {
    final currentSession = ++_searchSessionId;

    setState(() {
      _activeQuery = query;
      _isSearching = true;
      _currentPage = 1;
    });

    try {
      final payload = InventoryBackgroundSearchPayload(
        allItems: allItems,
        query: query,
      );

      // Runs in a separate worker thread (isolate)
      final result = await compute(filterAndAggregateInventoryInBackground, payload);

      if (!mounted || currentSession != _searchSessionId) return;

      setState(() {
        _searchResult = result;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted || currentSession != _searchSessionId) return;
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Offloads CSV creation and file writing to a background worker isolate.
  Future<void> _downloadCsv(List<InventoryStatusItem> filteredItems, String currencySymbol) async {
    if (filteredItems.isEmpty || _isExporting) return;

    setState(() => _isExporting = true);

    try {
      Directory? downloadsDir;
      try {
        downloadsDir = await getDownloadsDirectory();
      } catch (_) {}
      try {
        downloadsDir ??= await getApplicationDocumentsDirectory();
      } catch (_) {}
      downloadsDir ??= Directory.systemTemp;

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final targetPath = '${downloadsDir.path}${Platform.pathSeparator}inventory_status_$timestamp.csv';

      final payload = CsvExportPayload(
        items: filteredItems,
        currencySymbol: currencySymbol,
        targetFilePath: targetPath,
      );

      // Executed on background thread
      final savedPath = await compute(generateAndSaveCsvInBackground, payload);

      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Inventory CSV downloaded: $savedPath',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.alertSafe,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('CSV download error: $e\n$stack');
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate CSV: $e'),
            backgroundColor: AppColors.alertCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentUserSessionProvider);
    final currency = session?.currencySymbol ?? '৳';
    final inventoryAsync = ref.watch(inventoryStatusProvider);

    // Trigger background computation when inventory stream emits updated data
    ref.listen<AsyncValue<List<InventoryStatusItem>>>(
      inventoryStatusProvider,
      (previous, next) {
        next.whenData((items) {
          if (!identical(_cachedAllItems, items) || _searchResult == null) {
            _cachedAllItems = items;
            _runBackgroundSearch(items, _activeQuery);
          }
        });
      },
    );

    // Initial population when data is already available synchronously
    final currentItems = inventoryAsync.asData?.value;
    if (currentItems != null && _cachedAllItems == null) {
      _cachedAllItems = currentItems;
      _searchResult = filterAndAggregateInventoryInBackground(
        InventoryBackgroundSearchPayload(allItems: currentItems, query: _activeQuery),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header with Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inventory Status & Valuation Search',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Background worker isolate search with non-blocking stock counts, purchase costs & retail valuation.',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close Window',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // ================= ROW 1: INPUT FIELD (Default 'all') + SEARCH BUTTON =================
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name(s) *',
                        hintText: 'Enter "all" or specific names separated by comma (e.g. Napa, Losec, Fast)',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                tooltip: 'Reset to all',
                                onPressed: () {
                                  _searchController.text = 'all';
                                  _executeSearch();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onFieldSubmitted: (_) => _executeSearch(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search, size: 18),
                    label: const Text(
                      'Search',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: _isSearching ? null : _executeSearch,
                  ),
                ],
              ),

              if (_isSearching) ...[
                const SizedBox(height: 8),
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ],

              const SizedBox(height: 16),

              // ================= DATA CONTENT (ROW 2 + DETAILED BREAKDOWN) =================
              Expanded(
                child: _buildDataContent(context, inventoryAsync, currency),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataContent(
    BuildContext context,
    AsyncValue<List<InventoryStatusItem>> inventoryAsync,
    String currency,
  ) {
    if (_searchResult == null) {
      if (inventoryAsync.isLoading) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Calculating inventory stock and batch valuations in background thread...'),
            ],
          ),
        );
      }
      if (inventoryAsync.hasError) {
        return Center(
          child: Text(
            'Failed to load inventory status: ${inventoryAsync.error}',
            style: const TextStyle(color: AppColors.alertCritical),
          ),
        );
      }
    }

    final result = _searchResult;
    if (result == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Processing inventory status in background isolate...'),
          ],
        ),
      );
    }

    final filtered = result.filteredItems;
    final totalMedicinesCount = result.totalMedicinesCount;
    final totalStockUnits = result.totalStockUnits;
    final totalPurchaseCost = result.totalPurchaseCost;
    final totalSaleValue = result.totalSaleValue;
    final overallMargin = result.overallMargin;

    final isAll = _activeQuery.trim().isEmpty || _activeQuery.trim().toLowerCase() == 'all';
    final scopeLabel = isAll
        ? 'All Medicines ($totalMedicinesCount items)'
        : 'Matches for "$_activeQuery" ($totalMedicinesCount items)';

    // Pagination Calculations
    final totalPages = (totalMedicinesCount / _pageSize).ceil().clamp(1, 999999);
    final safeCurrentPage = _currentPage > totalPages ? totalPages : _currentPage;
    final startIndex = totalMedicinesCount == 0 ? 0 : (safeCurrentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalMedicinesCount);
    final pagedItems = totalMedicinesCount == 0
        ? <InventoryStatusItem>[]
        : filtered.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= ROW 2: SUMMARY METRICS & DOWNLOAD CSV BUTTON =================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Scope & Medicine Names
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MEDICINE(S)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(
                      scopeLabel,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Stock: $totalStockUnits units total',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Total Purchase Cost
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL PURCHASE COST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(
                      '$currency ${totalPurchaseCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text('Based on active stock', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Total Sale Value
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL SALE PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(
                      '$currency ${totalSaleValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.accent),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Margin: ${overallMargin.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Download as CSV Button (Executed in Background Thread)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isExporting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download, size: 18),
                label: Text(
                  _isExporting ? 'Exporting...' : 'Download as CSV',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: _isExporting || filtered.isEmpty ? null : () => _downloadCsv(filtered, currency),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ================= BREAKDOWN TABLE =================
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    'No medicines matching "$_activeQuery" found in inventory.',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      _searchController.text = 'all';
                      _executeSearch();
                    },
                    child: const Text('Show All Medicines'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: AppColors.surfaceElevated,
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text('MEDICINE & DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('STOCK / BATCHES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('PURCHASE COST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('SALE PRICE (MRP)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                        SizedBox(
                          width: 55,
                          child: Text('MARGIN', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Paginated Items List
                  Expanded(
                    child: ListView.separated(
                      itemCount: pagedItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = pagedItems[index];
                        final p = item.product;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Medicine Info
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            p.brandName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
                                      '${p.genericName} • Shelf: ${p.shelfLocation}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // In-Stock Units & Active Batches
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.activeStock} units',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: item.activeStock > 0 ? AppColors.textPrimary : AppColors.alertCritical,
                                      ),
                                    ),
                                    Text(
                                      '${item.batchCount} active batch${item.batchCount == 1 ? '' : 'es'}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Purchase Cost
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Purchase Cost', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    Text(
                                      '$currency ${item.totalPurchaseCost.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Sale Value
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sale Price (MRP)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    Text(
                                      '$currency ${item.totalSaleValue.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.accent),
                                    ),
                                  ],
                                ),
                              ),

                              // Gross Margin %
                              SizedBox(
                                width: 55,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.grossMargin >= 0
                                          ? AppColors.alertSafe.withValues(alpha: 0.12)
                                          : AppColors.alertCritical.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.grossMargin.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: item.grossMargin >= 0 ? AppColors.alertSafe : AppColors.alertCritical,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ================= PAGINATION FOOTER =================
                  const Divider(height: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: AppColors.surfaceElevated,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Range display & Rows per page selector
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Showing ${totalMedicinesCount == 0 ? 0 : startIndex + 1}–$endIndex of $totalMedicinesCount medicines',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 16),
                                const Text('Rows per page: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                DropdownButton<int>(
                                  value: _pageSize,
                                  isDense: true,
                                  underline: const SizedBox(),
                                  items: const [10, 25, 50, 100].map((size) {
                                    return DropdownMenuItem<int>(
                                      value: size,
                                      child: Text('$size', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    );
                                  }).toList(),
                                  onChanged: (newSize) {
                                    if (newSize != null && newSize != _pageSize) {
                                      setState(() {
                                        _pageSize = newSize;
                                        _currentPage = 1;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right: Pagination Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.first_page, size: 20),
                              tooltip: 'First Page',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: safeCurrentPage > 1
                                  ? () => setState(() => _currentPage = 1)
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 20),
                              tooltip: 'Previous Page',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: safeCurrentPage > 1
                                  ? () => setState(() => _currentPage = safeCurrentPage - 1)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Page $safeCurrentPage of $totalPages',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 20),
                              tooltip: 'Next Page',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: safeCurrentPage < totalPages
                                  ? () => setState(() => _currentPage = safeCurrentPage + 1)
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.last_page, size: 20),
                              tooltip: 'Last Page',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: safeCurrentPage < totalPages
                                  ? () => setState(() => _currentPage = totalPages)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
