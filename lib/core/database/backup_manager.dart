import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'app_database.dart';
import 'connection/connection.dart';

/// Manages rolling automated startup snapshots, retention pruning (14 days),
/// and one-click database export/import operations.
class DatabaseBackupManager {
  final Directory? customBackupDir;
  final File? customDbFile;

  DatabaseBackupManager({
    this.customBackupDir,
    this.customDbFile,
  });

  /// Executes automated rolling backup on application startup.
  /// Prunes existing backup files older than [retentionDays] (default 14 days).
  Future<BackupResult> runRollingStartupBackup(AppDatabase db) async {
    final dbFile = customDbFile ?? await getDefaultDatabaseFile();
    if (!await dbFile.exists()) {
      return BackupResult(
        success: true,
        backupFile: null,
        prunedFiles: [],
        message: 'No existing database file found to snapshot (fresh initialization).',
      );
    }

    final backupDir = customBackupDir ?? await getDefaultBackupDirectory();
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'backup_smart_pharmacy_$timestamp.sqlite';
    final backupFile = File(p.join(backupDir.path, backupFileName));

    try {
      // 1. Hot snapshot using SQLite VACUUM INTO for 100% WAL consistency
      await _vacuumInto(db, backupFile);

      // 2. Prune old backups older than retention window (14 days)
      final prunedFiles = await pruneOldBackups(
        backupDir: backupDir,
        retentionDays: AppConstants.backupRetentionDays,
      );

      return BackupResult(
        success: true,
        backupFile: backupFile,
        prunedFiles: prunedFiles,
        message: 'Startup rolling backup successfully created: ${backupFile.path}',
      );
    } catch (e) {
      // Fallback: WAL checkpoint then file copy
      try {
        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
        await dbFile.copy(backupFile.path);

        final prunedFiles = await pruneOldBackups(
          backupDir: backupDir,
          retentionDays: AppConstants.backupRetentionDays,
        );

        return BackupResult(
          success: true,
          backupFile: backupFile,
          prunedFiles: prunedFiles,
          message: 'Startup rolling backup created via WAL-checkpoint copy fallback.',
        );
      } catch (fallbackError) {
        throw DatabaseBackupException(
          'Failed to execute startup database backup',
          fallbackError,
        );
      }
    }
  }

  /// Prunes backup snapshots older than [retentionDays].
  Future<List<String>> pruneOldBackups({
    Directory? backupDir,
    int retentionDays = AppConstants.backupRetentionDays,
  }) async {
    final dir = backupDir ?? customBackupDir ?? await getDefaultBackupDirectory();
    if (!await dir.exists()) return [];

    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final pruned = <String>[];

    final entities = dir.listSync();
    for (final entity in entities) {
      if (entity is File &&
          p.basename(entity.path).startsWith('backup_smart_pharmacy_') &&
          entity.path.endsWith('.sqlite')) {
        final stat = entity.statSync();
        if (stat.modified.isBefore(cutoff)) {
          entity.deleteSync();
          pruned.add(entity.path);
        }
      }
    }

    return pruned;
  }

  /// One-click manual export to external path (e.g., USB drive or selected directory).
  Future<File> exportDatabase(AppDatabase db, File destinationFile) async {
    if (!await destinationFile.parent.exists()) {
      await destinationFile.parent.create(recursive: true);
    }

    if (await destinationFile.exists()) {
      await destinationFile.delete();
    }

    try {
      await _vacuumInto(db, destinationFile);
    } catch (_) {
      // Fallback
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      final dbFile = customDbFile ?? await getDefaultDatabaseFile();
      await dbFile.copy(destinationFile.path);
    }

    if (!await destinationFile.exists() || await destinationFile.length() == 0) {
      throw DatabaseBackupException('Exported database file is invalid or empty.');
    }

    return destinationFile;
  }

  /// One-click database import and restoration utility with safety pre-restore backup.
  Future<RestoreResult> restoreDatabase({
    required File backupFile,
    required AppDatabase currentDb,
  }) async {
    if (!await backupFile.exists()) {
      throw DatabaseRestoreException('Selected backup file does not exist: ${backupFile.path}');
    }

    // 1. Verify SQLite Header Magic Bytes: "SQLite format 3\000"
    final isValid = await _verifySqliteHeader(backupFile);
    if (!isValid) {
      throw DatabaseRestoreException('File is not a valid SQLite database archive.');
    }

    final targetDbFile = customDbFile ?? await getDefaultDatabaseFile();
    File? safetyBackupFile;

    // 2. Create emergency pre-restore fallback safety snapshot
    if (await targetDbFile.exists()) {
      final backupDir = customBackupDir ?? await getDefaultBackupDirectory();
      final safetyTimestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      safetyBackupFile = File(p.join(backupDir.path, 'pre_restore_safety_backup_$safetyTimestamp.sqlite'));
      try {
        await _vacuumInto(currentDb, safetyBackupFile);
      } catch (_) {
        await currentDb.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
        await targetDbFile.copy(safetyBackupFile.path);
      }
    }

    // 3. Close current database to release file locks on Windows
    await currentDb.close();

    // 4. Overwrite main SQLite file
    await backupFile.copy(targetDbFile.path);

    // 5. Clean stale WAL & SHM files to prevent state mismatch
    final walFile = File('${targetDbFile.path}-wal');
    final shmFile = File('${targetDbFile.path}-shm');
    if (await walFile.exists()) await walFile.delete();
    if (await shmFile.exists()) await shmFile.delete();

    return RestoreResult(
      restoredFrom: backupFile,
      safetyBackup: safetyBackupFile,
      restoredAt: DateTime.now(),
    );
  }

  /// Executes VACUUM INTO using escaped forward slashes for cross-platform SQLite compatibility.
  Future<void> _vacuumInto(AppDatabase db, File destination) async {
    final sanitizedPath = destination.path.replaceAll(r'\', '/');
    await db.customStatement("VACUUM INTO '$sanitizedPath';");
  }

  /// Verifies SQLite file header signature.
  Future<bool> _verifySqliteHeader(File file) async {
    try {
      final raf = await file.open(mode: FileMode.read);
      final headerBytes = await raf.read(16);
      await raf.close();

      const expectedHeader = [
        0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66,
        0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00,
      ]; // "SQLite format 3\000"

      if (headerBytes.length < 16) return false;
      for (int i = 0; i < 16; i++) {
        if (headerBytes[i] != expectedHeader[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Metadata summary of a backup operation.
class BackupResult {
  final bool success;
  final File? backupFile;
  final List<String> prunedFiles;
  final String message;

  BackupResult({
    required this.success,
    required this.backupFile,
    required this.prunedFiles,
    required this.message,
  });
}

/// Metadata summary of a restore operation.
class RestoreResult {
  final File restoredFrom;
  final File? safetyBackup;
  final DateTime restoredAt;

  RestoreResult({
    required this.restoredFrom,
    required this.safetyBackup,
    required this.restoredAt,
  });
}

