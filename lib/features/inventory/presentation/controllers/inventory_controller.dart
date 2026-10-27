import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../../data/inventory_repository.dart';
import '../../domain/inventory_repository_interface.dart';

/// Inventory repository provider.
final inventoryRepositoryProvider = Provider<IInventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepository(db);
});

/// Search text query state for catalog filtering.
class MedicineSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String value) => super.state = value;
  void setQuery(String query) => super.state = query;
}

final medicineSearchQueryProvider =
    NotifierProvider<MedicineSearchQueryNotifier, String>(MedicineSearchQueryNotifier.new);

/// Selected category filter (e.g., 'All', 'Antibiotic', etc.)
class SelectedCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  @override
  set state(String value) => super.state = value;
  void setCategory(String category) => super.state = category;
}

final selectedCategoryFilterProvider =
    NotifierProvider<SelectedCategoryFilterNotifier, String>(SelectedCategoryFilterNotifier.new);

/// Reactive stream of medicines with aggregated stock counts and expiry warnings.
final productsWithStockProvider = StreamProvider<List<ProductWithAggregateStock>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);
  final search = ref.watch(medicineSearchQueryProvider);

  if (session == null) return const Stream.empty();

  return repo.watchProducts(session.pharmacyUid, searchQuery: search.isEmpty ? null : search);
});

/// Stream of all batches for a specific medicine.
final productBatchesProvider = StreamProvider.family<List<ProductBatch>, String>((ref, productId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);

  if (session == null) return const Stream.empty();

  return repo.watchBatchesForProduct(session.pharmacyUid, productId);
});

// --- Expiry Radar Providers ---

/// Stream of strictly expired batches (critical alert - blocked from POS cart additions).
final expiredBatchesProvider = StreamProvider<List<BatchWithProductInfo>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);

  if (session == null) return const Stream.empty();

  return repo.watchExpiredBatches(session.pharmacyUid);
});

/// Stream of batches expiring within the urgent 0-30 days window.
final urgentExpiringBatchesProvider = StreamProvider<List<BatchWithProductInfo>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);

  if (session == null) return const Stream.empty();

  return repo.watchExpiringBatches(session.pharmacyUid, minDays: 0, maxDays: 30);
});

/// Stream of batches expiring in the warning 31-60 days window.
final warningExpiringBatchesProvider = StreamProvider<List<BatchWithProductInfo>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);

  if (session == null) return const Stream.empty();

  return repo.watchExpiringBatches(session.pharmacyUid, minDays: 31, maxDays: 60);
});

/// Stream of batches expiring in the caution 61-90 days window.
final cautionExpiringBatchesProvider = StreamProvider<List<BatchWithProductInfo>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  final session = ref.watch(currentUserSessionProvider);

  if (session == null) return const Stream.empty();

  return repo.watchExpiringBatches(session.pharmacyUid, minDays: 61, maxDays: 90);
});

/// Stream of medicines whose active non-expired stock has breached the configured reorder threshold.
final lowStockProductsProvider = Provider<List<ProductWithAggregateStock>>((ref) {
  final productsAsync = ref.watch(productsWithStockProvider);
  return productsAsync.maybeWhen(
    data: (list) => list.where((p) => p.isLowStock).toList(),
    orElse: () => [],
  );
});
