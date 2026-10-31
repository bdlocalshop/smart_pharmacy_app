import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/backup_manager.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/core/database/seed_data.dart';
import 'package:smart_pharmacy_app/core/localization/app_strings.dart';
import 'package:smart_pharmacy_app/core/localization/language_controller.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/database_backups_view.dart';

class _MockLanguageNotifier extends LanguageNotifier {
  final AppLanguage initial;
  _MockLanguageNotifier(this.initial);

  @override
  AppLanguage build() => initial;
}

void main() {
  late Directory tempDir;
  late Directory backupDir;
  late File dbFile;
  late AppDatabase db;
  late DatabaseBackupManager backupManager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('db_backup_view_test_');
    backupDir = Directory(p.join(tempDir.path, 'backups'))..createSync();
    dbFile = File(p.join(tempDir.path, 'test_db.sqlite'));

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

  Widget buildTestWidget({bool isBangla = false}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        backupManagerProvider.overrideWithValue(backupManager),
        appLanguageProvider.overrideWith(() => _MockLanguageNotifier(isBangla ? AppLanguage.bn : AppLanguage.en)),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DatabaseBackupsView(),
        ),
      ),
    );
  }

  group('DatabaseBackupsView Tests', () {
    testWidgets('renders recovery header and action buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text('Database Recovery & Rolling Backups'), findsOneWidget);
      expect(find.text('Export Immediate Backup (.sqlite)'), findsOneWidget);
      expect(find.text('Restore Database Archive'), findsOneWidget);
      expect(find.text('Change Folder'), findsOneWidget);
    });

    testWidgets('displays discovered backups with newest on top', (tester) async {
      tester.view.physicalSize = const Size(1920, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Create two fake backup files
      final oldBackup = File(p.join(backupDir.path, 'backup_smart_pharmacy_20261020_120000.sqlite'));
      oldBackup.writeAsStringSync('old');
      oldBackup.setLastModifiedSync(DateTime.now().subtract(const Duration(days: 2)));

      final newBackup = File(p.join(backupDir.path, 'backup_smart_pharmacy_20261028_120000.sqlite'));
      newBackup.writeAsStringSync('new');
      newBackup.setLastModifiedSync(DateTime.now());

      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text('backup_smart_pharmacy_20261028_120000.sqlite'), findsOneWidget);
      expect(find.text('backup_smart_pharmacy_20261020_120000.sqlite'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
    });

    testWidgets('tapping Restore Database Archive opens warning popup with Cancel and OK', (tester) async {
      tester.view.physicalSize = const Size(1920, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Restore Database Archive button
      await tester.tap(find.text('Restore Database Archive'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Warning popup must appear
      expect(find.text('Restore Database Archive?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap Cancel -> dialog closes
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Restore Database Archive?'), findsNothing);
    });

    testWidgets('supports Bangla localization toggle', (tester) async {
      tester.view.physicalSize = const Size(1920, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(isBangla: true));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text('ডেটাবেস রিকভারি ও রোলিং ব্যাকআপ'), findsOneWidget);
      expect(find.text('তাৎক্ষণিক ব্যাকআপ তৈরি করুন (.sqlite)'), findsOneWidget);
      expect(find.text('ডাটাবেস সংরক্ষণাগার রিস্টোর'), findsOneWidget);
      expect(find.text('ফোল্ডার পরিবর্তন'), findsOneWidget);
    });
  });
}
