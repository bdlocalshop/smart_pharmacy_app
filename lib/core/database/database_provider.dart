import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'backup_manager.dart';
import 'seed_data.dart';

/// Application database singleton provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

/// Backup manager provider.
final backupManagerProvider = Provider<DatabaseBackupManager>((ref) {
  return DatabaseBackupManager();
});

/// Bootstraps database initialization, rolling backup, and seed data.
final appInitializationProvider = FutureProvider<AppInitializationState>((ref) async {
  final db = ref.read(databaseProvider);
  final backupManager = ref.read(backupManagerProvider);

  // 1. Seed database if first launch (without demo users)
  bool wasSeeded = false;
  try {
    final seeder = DatabaseSeeder(db);
    wasSeeded = await seeder.seedIfEmpty(seedUsers: false);
  } catch (_) {
    // Non-fatal: continue even if seed query throws
  }

  // 2. Run automated rolling startup backup and prune snapshots older than 14 days
  BackupResult backupResult = BackupResult(
    success: false,
    backupFile: null,
    prunedFiles: [],
    message: 'Backup bypassed or pending',
  );
  try {
    backupResult = await backupManager.runRollingStartupBackup(db);
  } catch (_) {
    // Non-fatal: backup failure must never prevent application startup
  }

  // 3. Query pharmacy configuration
  String pharmacyName = 'Smart Pharmacy';
  String pharmacyUid = '';
  int userCount = 0;
  int productCount = 0;
  int batchCount = 0;

  try {
    final pharmacy = await db.select(db.pharmacySettingsTable).getSingleOrNull();
    pharmacyName = pharmacy?.pharmacyName ?? 'Smart Pharmacy';
    pharmacyUid = pharmacy?.pharmacyUid ?? '';
    userCount = (await db.select(db.usersTable).get()).length;
    productCount = (await db.select(db.productsTable).get()).length;
    batchCount = (await db.select(db.productBatchesTable).get()).length;
  } catch (_) {
    // Fallback defaults
  }

  return AppInitializationState(
    isSeeded: wasSeeded,
    pharmacyName: pharmacyName,
    pharmacyUid: pharmacyUid,
    userCount: userCount,
    productCount: productCount,
    batchCount: batchCount,
    backupResult: backupResult,
  );
});

class AppInitializationState {
  final bool isSeeded;
  final String pharmacyName;
  final String pharmacyUid;
  final int userCount;
  final int productCount;
  final int batchCount;
  final BackupResult backupResult;

  AppInitializationState({
    required this.isSeeded,
    required this.pharmacyName,
    required this.pharmacyUid,
    required this.userCount,
    required this.productCount,
    required this.batchCount,
    required this.backupResult,
  });
}

