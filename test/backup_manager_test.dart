import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/backup_manager.dart';
import 'package:smart_pharmacy_app/core/database/seed_data.dart';

void main() {
  late Directory tempDir;
  late Directory backupDir;
  late File dbFile;
  late AppDatabase db;
  late DatabaseBackupManager backupManager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pharmacy_backup_test_');
    backupDir = Directory(p.join(tempDir.path, 'backups'))..createSync();
    dbFile = File(p.join(tempDir.path, 'test_pharmacy.sqlite'));

    // Create real file-backed SQLite database for file/backup testing
    db = AppDatabase(NativeDatabase(dbFile));
    final seeder = DatabaseSeeder(db);
    await seeder.seedIfEmpty();

    backupManager = DatabaseBackupManager(
      customBackupDir: backupDir,
      customDbFile: dbFile,
    );
  });

  tearDown(() async {
    try {
      await db.close();
    } catch (_) {}
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DatabaseBackupManager Tests', () {
    test('runRollingStartupBackup creates a valid SQLite backup archive', () async {
      final result = await backupManager.runRollingStartupBackup(db);

      expect(result.success, isTrue);
      expect(result.backupFile, isNotNull);
      expect(result.backupFile!.existsSync(), isTrue);
      expect(result.backupFile!.lengthSync(), greaterThan(0));
    });

    test('pruneOldBackups deletes backups older than 14 days and preserves recent ones', () async {
      final oldBackup = File(p.join(backupDir.path, 'backup_smart_pharmacy_20200101_120000.sqlite'));
      oldBackup.writeAsStringSync('dummy old content');
      // Set modification time to 20 days ago
      oldBackup.setLastModifiedSync(DateTime.now().subtract(const Duration(days: 20)));

      final freshBackup = File(p.join(backupDir.path, 'backup_smart_pharmacy_20261024_120000.sqlite'));
      freshBackup.writeAsStringSync('dummy fresh content');
      freshBackup.setLastModifiedSync(DateTime.now());

      final pruned = await backupManager.pruneOldBackups(backupDir: backupDir, retentionDays: 14);

      expect(pruned.length, equals(1));
      expect(oldBackup.existsSync(), isFalse);
      expect(freshBackup.existsSync(), isTrue);
    });

    test('exportDatabase copies database to designated target file', () async {
      final exportTarget = File(p.join(tempDir.path, 'usb_export', 'manual_export.sqlite'));
      final exported = await backupManager.exportDatabase(db, exportTarget);

      expect(exported.existsSync(), isTrue);
      expect(exported.lengthSync(), greaterThan(0));
    });

    test('restoreDatabase creates safety backup and restores target file', () async {
      // 1. Create a known backup file to restore from
      final backupResult = await backupManager.runRollingStartupBackup(db);
      final sourceBackup = backupResult.backupFile!;

      // 2. Perform restoration
      final restoreResult = await backupManager.restoreDatabase(
        backupFile: sourceBackup,
        currentDb: db,
      );

      expect(restoreResult.restoredFrom.path, equals(sourceBackup.path));
      expect(restoreResult.safetyBackup, isNotNull);
      expect(restoreResult.safetyBackup!.existsSync(), isTrue);
      expect(dbFile.existsSync(), isTrue);

      // Reopen db to verify integrity
      final reopenedDb = AppDatabase(NativeDatabase(dbFile));
      final users = await reopenedDb.select(reopenedDb.usersTable).get();
      expect(users.isNotEmpty, isTrue);
      await reopenedDb.close();
    });
  });
}

