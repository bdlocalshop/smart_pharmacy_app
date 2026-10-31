import '../../../../core/network/cloud_license_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/backup_manager.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/language_controller.dart';
import '../controllers/auth_controller.dart';

/// Key for storing custom backup directory preference in secure storage.
const String _kCustomBackupDirKey = 'app_custom_backup_directory';

/// Database maintenance and rolling backup archive management screen.
class DatabaseBackupsView extends ConsumerStatefulWidget {
  const DatabaseBackupsView({super.key});

  @override
  ConsumerState<DatabaseBackupsView> createState() => _DatabaseBackupsViewState();
}

class _DatabaseBackupsViewState extends ConsumerState<DatabaseBackupsView> {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  List<BackupFileInfo> _backups = [];
  String _backupDirPath = '';
  bool _isCustomFolder = false;
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isUploadingCloud = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final manager = ref.read(backupManagerProvider);

      // Restore custom backup directory preference if user previously configured one
      try {
        final savedPath = await _storage.read(key: _kCustomBackupDirKey);
        if (savedPath != null && savedPath.trim().isNotEmpty) {
          final savedDir = Directory(savedPath);
          if (savedDir.existsSync()) {
            manager.setCustomBackupDirectory(savedDir);
            _isCustomFolder = true;
          } else {
            _isCustomFolder = false;
          }
        } else {
          _isCustomFolder = false;
        }
      } catch (_) {
        // Storage not available or mock in test environment
        _isCustomFolder = false;
      }

      final dir = await manager.getBackupDirectory();
      final list = await manager.listBackups();
      if (mounted) {
        setState(() {
          _backupDirPath = dir.path;
          _backups = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSelectBackupFolder() async {
    final strings = ref.read(appStringsProvider);
    final manager = ref.read(backupManagerProvider);

    try {
      final String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: strings.selectBackupDirectoryTitle,
        initialDirectory: _backupDirPath.isNotEmpty ? _backupDirPath : null,
      );

      if (selectedDirectory == null || selectedDirectory.trim().isEmpty) {
        return; // User cancelled
      }

      final chosenDir = Directory(selectedDirectory);
      if (!chosenDir.existsSync()) {
        chosenDir.createSync(recursive: true);
      }

      await _storage.write(key: _kCustomBackupDirKey, value: selectedDirectory);
      manager.setCustomBackupDirectory(chosenDir);
      _isCustomFolder = true;

      await _loadBackups();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertSafe,
            duration: const Duration(seconds: 4), // Auto dismiss within 4 seconds (well under 10s)
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${strings.backupFolderChangedSuccess} ${p.normalize(selectedDirectory)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertCritical,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Text('Failed to select directory: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handleResetToDefaultFolder() async {
    final strings = ref.read(appStringsProvider);
    final manager = ref.read(backupManagerProvider);

    try {
      await _storage.delete(key: _kCustomBackupDirKey);
      manager.setCustomBackupDirectory(null);
      _isCustomFolder = false;

      await _loadBackups();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertSafe,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.backupFolderResetSuccess,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {}
  }

  
  Future<void> _handleUploadToCloud([File? fileToUpload]) async {
    if (_isUploadingCloud) return;

    File? target = fileToUpload;
    if (target == null) {
      if (_backups.isNotEmpty) {
        target = _backups.first.file;
      } else {
        final manager = ref.read(backupManagerProvider);
        final db = ref.read(databaseProvider);
        target = await manager.createTimestampedBackup(db);
        await _loadBackups();
      }
    }

    if (!target.existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No backup archive available to upload.')),
        );
      }
      return;
    }

    setState(() => _isUploadingCloud = true);

    try {
      final cloudService = ref.read(cloudLicenseServiceProvider);
      final res = await cloudService.uploadCloudBackup(
        backupFile: target,
        notes: 'Desktop upload: ${p.basename(target.path)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: res.success ? AppColors.accent : AppColors.alertCritical,
            duration: const Duration(seconds: 4),
            content: Text(
              res.success
                  ? 'Backup archived in cloud successfully! (ID: ${res.backupId ?? "OK"})'
                  : 'Cloud upload failed: ${res.message ?? "Unknown error"}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.alertCritical, content: Text('Cloud upload error: ')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingCloud = false);
    }
  }

  Future<void> _handleCreateBackup() async {
    if (_isBackingUp || _isRestoring) return;
    setState(() => _isBackingUp = true);

    final strings = ref.read(appStringsProvider);
    final manager = ref.read(backupManagerProvider);
    final db = ref.read(databaseProvider);

    try {
      final createdFile = await manager.createTimestampedBackup(db);
      await _loadBackups();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertSafe,
            duration: const Duration(seconds: 4), // Auto dismiss within 4 seconds (well under 10s)
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${strings.backupCreatedSuccess} ${p.basename(createdFile.path)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertCritical,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Text('Failed to create backup: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _handleRestoreDatabaseArchive() async {
    if (_isBackingUp || _isRestoring) return;

    final strings = ref.read(appStringsProvider);

    // 1. Show warning confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.alertCritical, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.restoreWarningTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          strings.restoreWarningMessage,
          style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(strings.cancelBtn, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertCritical,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(strings.okBtn),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 2. Open File Picker
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Select SQLite Database Backup Archive to Restore',
        type: FileType.custom,
        allowedExtensions: ['sqlite', 'db'],
      );

      if (files.isEmpty) {
        return; // User cancelled file picker
      }

      final selectedPath = files.first.path;
      if (selectedPath == null || selectedPath.isEmpty) return;

      await _executeRestore(File(selectedPath));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertCritical,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Text('File selection error: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handleRestoreSpecificFile(BackupFileInfo item) async {
    if (_isBackingUp || _isRestoring) return;

    final strings = ref.read(appStringsProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.alertCritical, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.restoreWarningTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          '${strings.restoreSpecificWarningMessage}\n\n📁 ${item.fileName} (${item.formattedSize})',
          style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(strings.cancelBtn, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertCritical,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(strings.okBtn),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeRestore(item.file);
    }
  }

  Future<void> _executeRestore(File backupFile) async {
    setState(() => _isRestoring = true);
    final strings = ref.read(appStringsProvider);
    final manager = ref.read(backupManagerProvider);
    final db = ref.read(databaseProvider);

    try {
      await manager.restoreDatabase(
        backupFile: backupFile,
        currentDb: db,
      );

      // Refresh application providers and session silently
      ref.invalidate(appInitializationProvider);
      await ref.read(authControllerProvider.notifier).reloadAfterRestore();
      await _loadBackups();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertSafe,
            duration: const Duration(seconds: 4), // Auto dismiss within 4 seconds (well under 10s)
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.databaseRestoredSuccess,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.alertCritical,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            content: Text('Database restoration failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Future<void> _handleDeleteBackup(BackupFileInfo item) async {
    final strings = ref.read(appStringsProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(strings.deleteBackupConfirmTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '${strings.deleteBackupConfirmMsg}\n\n${item.fileName}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(strings.cancelBtn),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertCritical,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(strings.deleteBackupTooltip),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final manager = ref.read(backupManagerProvider);
      await manager.deleteBackup(item.file);
      await _loadBackups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final manager = ref.watch(backupManagerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card: Recovery & Immediate Actions
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.security, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.dbRecoveryRollingBackups,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.dbRecoverySubtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_backups.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withAlpha(60)),
                          ),
                          child: Text(
                            '${_backups.length} ${strings.isBn ? 'সংরক্ষিত ব্যাকআপ' : 'Archives'}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action buttons row (Only Export and Restore per remove-1.png)
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isBackingUp
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_alt, size: 18),
                        label: Text(_isBackingUp ? strings.creatingBackupWait : strings.exportImmediateBackup),
                        onPressed: _isBackingUp || _isRestoring ? null : _handleCreateBackup,
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.alertCritical,
                          side: const BorderSide(color: AppColors.alertCritical),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isRestoring
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.alertCritical),
                              )
                            : const Icon(Icons.restore, size: 18),
                        label: Text(_isRestoring ? strings.restoringDatabaseWait : strings.restoreDatabaseArchive),
                        onPressed: _isBackingUp || _isRestoring ? null : _handleRestoreDatabaseArchive,
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isUploadingCloud
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: Text(_isUploadingCloud ? 'Uploading to Cloud...' : 'Upload to Cloud Backup'),
                        onPressed: _isUploadingCloud || _isBackingUp || _isRestoring ? null : () => _handleUploadToCloud(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Bottom Card: Saved Backup Archives List & Storage Directory Selector
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.accentCyan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.savedArchivesHeader,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.savedArchivesSubtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        tooltip: strings.refreshBackupsTooltip,
                        onPressed: _isLoading ? null : _loadBackups,
                      ),
                    ],
                  ),
                  if (_backupDirPath.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_special_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            strings.backupDirectoryLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isCustomFolder ? AppColors.accentPurple.withAlpha(25) : Colors.grey.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isCustomFolder ? strings.customFolderBadge : strings.defaultFolderBadge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isCustomFolder ? AppColors.accentPurpleDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              p.normalize(_backupDirPath),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Option to select custom folder to save backups (per image-3.png)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.drive_file_move_outlined, size: 14),
                            label: Text(
                              strings.changeBackupFolderBtn,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            onPressed: _handleSelectBackupFolder,
                          ),
                          if (_isCustomFolder) ...[
                            const SizedBox(width: 6),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.restore_page_outlined, size: 14),
                              label: Text(
                                strings.resetToDefaultFolderBtn,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: _handleResetToDefaultFolder,
                            ),
                          ],
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                            tooltip: strings.openInExplorerTooltip,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => manager.openBackupDirectoryInExplorer(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 8),

                  // Backups List View
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_backups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.folder_off_outlined, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              strings.noBackupsFound,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _backups.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final item = _backups[index];
                        final isLatest = index == 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: isLatest
                              ? BoxDecoration(
                                  color: AppColors.primary.withAlpha(8),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isLatest
                                      ? AppColors.primary.withAlpha(30)
                                      : Colors.grey.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.storage_rounded,
                                  color: isLatest ? AppColors.primary : AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.fileName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isLatest) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              strings.latestBackupBadge,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 13, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.formattedDate,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.data_usage, size: 13, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.formattedSize,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Item Actions
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.folder_open, size: 20, color: AppColors.primary),
                                    tooltip: strings.openInExplorerTooltip,
                                    onPressed: () => manager.openBackupDirectoryInExplorer(item.file),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cloud_upload_outlined, size: 20, color: AppColors.primary),
                                    tooltip: 'Upload this archive to cloud backup',
                                    onPressed: _isUploadingCloud ? null : () => _handleUploadToCloud(item.file),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.restore, size: 20, color: AppColors.alertCritical),
                                    tooltip: strings.restoreThisArchiveTooltip,
                                    onPressed: _isRestoring ? null : () => _handleRestoreSpecificFile(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textSecondary),
                                    tooltip: strings.deleteBackupTooltip,
                                    onPressed: () => _handleDeleteBackup(item),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
