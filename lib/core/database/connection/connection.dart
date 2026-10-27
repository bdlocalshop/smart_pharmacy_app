import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../constants/app_constants.dart';

/// Configures and opens a Drift Native SQLite database with WAL mode enabled.
LazyDatabase openConnection({File? customFile}) {
  return LazyDatabase(() async {
    final dbFile = customFile ?? await getDefaultDatabaseFile();

    if (!await dbFile.parent.exists()) {
      await dbFile.parent.create(recursive: true);
    }

    return NativeDatabase.createInBackground(
      dbFile,
      setup: (rawDb) {
        // 1. Write-Ahead Logging (WAL) for high throughput and zero UI stutter
        rawDb.execute('PRAGMA journal_mode = WAL;');
        // 2. Enforce foreign key constraints
        rawDb.execute('PRAGMA foreign_keys = ON;');
        // 3. Normal synchronous mode provides durability with highest WAL performance
        rawDb.execute('PRAGMA synchronous = NORMAL;');
        // 4. Memory cache allocation (~64MB)
        rawDb.execute('PRAGMA cache_size = -64000;');
        // 5. Store temp tables and indices in memory
        rawDb.execute('PRAGMA temp_store = MEMORY;');
      },
    );
  });
}

/// Resolves standard path for the desktop SQLite database file.
Future<File> getDefaultDatabaseFile() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return File(p.join(appDocDir.path, 'SmartPharmacy', AppConstants.databaseFileName));
}

/// Resolves standard path for rolling database backups.
Future<Directory> getDefaultBackupDirectory() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final backupDir = Directory(p.join(appDocDir.path, 'SmartPharmacy', AppConstants.backupDirectoryName));
  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }
  return backupDir;
}

