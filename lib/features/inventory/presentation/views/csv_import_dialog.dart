import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../../domain/csv_medicine_importer.dart';

/// Modal dialog for uploading and importing multiple medicines from a CSV file
/// with automatic duplicate checking (Brand Name & Unit Type) and download of unable-to-upload items.
class CsvImportDialog extends ConsumerStatefulWidget {
  const CsvImportDialog({super.key});

  @override
  ConsumerState<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends ConsumerState<CsvImportDialog> {
  String? _selectedFileName;
  CsvImportResult? _importResult;
  bool _isProcessing = false;
  bool _isImporting = false;
  String? _errorMessage;

  // Duplicate metrics evaluated against active database
  int _existingDbDuplicateCount = 0;
  int _newReadyCount = 0;
  List<CsvSkippedItem> _previewSkippedItems = [];

  // Completed upload report
  CsvBatchImportReport? _uploadReport;

  Future<void> _pickCsvFile() async {
    setState(() {
      _errorMessage = null;
      _uploadReport = null;
    });

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (files.isEmpty) {
        return; // User cancelled
      }

      final file = files.first;
      setState(() => _isProcessing = true);

      final bytes = await file.readAsBytes();
      String csvContent;
      // Handle potential UTF-8 BOM
      if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
        csvContent = utf8.decode(bytes.sublist(3));
      } else {
        csvContent = utf8.decode(bytes);
      }

      final session = ref.read(currentUserSessionProvider);
      List<String>? knownUnits;
      if (session != null) {
        final repo = ref.read(inventoryRepositoryProvider);
        knownUnits = await repo.getDistinctUnitTypes(session.pharmacyUid);
      }

      final parsed = CsvMedicineImporter.parseCsv(csvContent, knownUnitTypes: knownUnits);

      // Check against active database records for existing duplicates
      int dbDupes = 0;
      final previewSkipped = List<CsvSkippedItem>.from(parsed.skippedItems);

      if (session != null) {
        final repo = ref.read(inventoryRepositoryProvider);
        final existing = await repo.getActiveProducts(session.pharmacyUid);
        final existingKeys = <String>{};
        for (final ep in existing) {
          existingKeys.add(ProductImportItem.buildDuplicateKey(ep.brandName, ep.unitType));
        }

        for (final p in parsed.validProducts) {
          if (existingKeys.contains(p.duplicateKey)) {
            dbDupes++;
            previewSkipped.add(
              CsvSkippedItem(
                rowNumber: p.sourceRowNumber,
                brandName: p.brandName,
                genericName: p.genericName,
                category: p.category,
                manufacturer: p.manufacturer,
                shelfLocation: p.shelfLocation,
                unitType: p.unitType,
                minStockAlert: p.minStockAlert.toString(),
                reason: 'Already exists in database (Brand: "${p.brandName}", Unit: "${p.unitType}").',
              ),
            );
          }
        }
      }

      previewSkipped.sort((a, b) => a.rowNumber.compareTo(b.rowNumber));
      final newCount = parsed.validProducts.length - dbDupes;

      setState(() {
        _selectedFileName = file.name;
        _importResult = parsed;
        _existingDbDuplicateCount = dbDupes;
        _newReadyCount = newCount;
        _previewSkippedItems = previewSkipped;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to read CSV: $e';
      });
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final template = CsvMedicineImporter.generateCsvTemplate();
      final downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final targetFile = File('${downloadsDir.path}${Platform.pathSeparator}medicines_import_template.csv');
      await targetFile.writeAsString(template);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV Template downloaded to: ${targetFile.path}'),
            backgroundColor: AppColors.alertSafe,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save template: $e'),
            backgroundColor: AppColors.alertCritical,
          ),
        );
      }
    }
  }

  Future<void> _downloadSkippedCsv(List<CsvSkippedItem> skippedItems) async {
    if (skippedItems.isEmpty) return;

    try {
      final csvString = CsvMedicineImporter.generateSkippedItemsCsv(skippedItems);
      final downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final targetFile = File('${downloadsDir.path}${Platform.pathSeparator}unable_to_upload_medicines_$timestamp.csv');
      await targetFile.writeAsString(csvString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to upload list (${skippedItems.length} items) saved to: ${targetFile.path}'),
            backgroundColor: AppColors.alertWarning,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not export skipped list: $e'),
            backgroundColor: AppColors.alertCritical,
          ),
        );
      }
    }
  }

  Future<void> _executeImport() async {
    final result = _importResult;
    if (result == null || _newReadyCount == 0) return;

    final session = ref.read(currentUserSessionProvider);
    if (session == null) return;

    setState(() => _isImporting = true);

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final report = await repo.importMedicinesWithDuplicateCheck(
        pharmacyUid: session.pharmacyUid,
        parsedProducts: result.validProducts,
        initialSkippedItems: result.skippedItems,
      );

      setState(() {
        _isImporting = false;
        _uploadReport = report;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: AppColors.alertCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If upload has completed, render the final Audit & Report screen
    if (_uploadReport != null) {
      return _buildReportDialog(_uploadReport!);
    }

    return _buildUploadDialog();
  }

  Widget _buildUploadDialog() {
    final result = _importResult;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Multiple Medicines (CSV Upload)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'Bulk upload medicines into your master catalog with automatic duplicate detection.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _downloadTemplate,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download CSV Template'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 780,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pharmacy Rules & Duplicate Matching Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rule, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Automatic CSV Processing & Duplicate Checking Rules:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('• Duplicate Detection: Items with matching "Brand Name" AND "Dispensing Unit Type" are automatically identified and skipped.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('• Auto-Normalization & Fuzzy Matching: Shorthand & typos in units are automatically unified (e.g. "tabs" -> "Tablet", "cap" -> "Capsule", "inj" -> "Injection").', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing Brand/Commercial Name: Row is skipped (NOT uploaded).', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing Shelf Location: Automatically assigned to "Rack 0-0".', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing or Invalid Reorder Alert Threshold: Defaults to 50 units.', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Other Missing Information (Generic, Category, Manufacturer): Marked as "Not Available".', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing Dispensing Unit Type: Defaults to "Unknown".', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Upload Action Area
              Center(
                child: InkWell(
                  onTap: _isProcessing || _isImporting ? null : _pickCsvFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withAlpha(100), width: 1.5, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surface,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _selectedFileName != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                          size: 44,
                          color: _selectedFileName != null ? AppColors.alertSafe : AppColors.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _selectedFileName != null
                              ? 'Selected: $_selectedFileName'
                              : 'Click here to Browse & Select your CSV File',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _selectedFileName != null ? AppColors.textPrimary : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Supported format: Comma Separated Values (.csv)',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ],
                  ),
                ),
              ],

              if (_isProcessing) ...[
                const SizedBox(height: 20),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Reading CSV and checking duplicates in database...'),
                    ],
                  ),
                ),
              ],

              // Parsed Statistics & Preview Table
              if (result != null && !_isProcessing) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Ready to Import badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.alertSafe.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.alertSafe.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.alertSafe, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$_newReadyCount Ready to Import', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.alertSafe)),
                                Text('Total rows found: ${result.totalRowsParsed}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Database Duplicates badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _existingDbDuplicateCount > 0 ? Colors.amber.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _existingDbDuplicateCount > 0 ? Colors.amber.shade300 : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, color: _existingDbDuplicateCount > 0 ? Colors.amber.shade800 : Colors.grey, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$_existingDbDuplicateCount In Database', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _existingDbDuplicateCount > 0 ? Colors.amber.shade900 : Colors.grey.shade700)),
                                const Text('Already exists (skip)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Skipped from file badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: result.hasSkipped ? Colors.orange.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: result.hasSkipped ? Colors.orange.shade300 : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(result.hasSkipped ? Icons.warning_amber_rounded : Icons.info_outline, color: result.hasSkipped ? Colors.orange.shade800 : Colors.grey, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${result.skippedCount} Skipped in File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: result.hasSkipped ? Colors.orange.shade900 : Colors.grey.shade700)),
                                const Text('Dupe in file / no name', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_previewSkippedItems.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total ${_previewSkippedItems.length} items will not be uploaded (duplicates or missing name).',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: Colors.orange.shade900,
                          side: BorderSide(color: Colors.orange.shade400),
                        ),
                        icon: const Icon(Icons.download, size: 14),
                        label: const Text('Download Skipped List (.csv)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _downloadSkippedCsv(_previewSkippedItems),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'View Skipped & Duplicate Reasons (${_previewSkippedItems.length} items)',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _previewSkippedItems.length,
                          itemBuilder: (ctx, i) {
                            final item = _previewSkippedItems[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text('• Row ${item.rowNumber} [${item.brandName} - ${item.unitType}]: ${item.reason}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                const Text('Data Preview (First 5 Items):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 40,
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Brand Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Generic Formula', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Manufacturer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Shelf Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Threshold', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      rows: result.validProducts.take(5).map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.brandName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                            DataCell(Text(p.genericName, style: const TextStyle(fontSize: 12))),
                            DataCell(Text(p.category, style: const TextStyle(fontSize: 12))),
                            DataCell(Text(p.manufacturer, style: const TextStyle(fontSize: 12))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.shelfLocation == 'Rack 0-0' ? Colors.amber.shade50 : Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(p.shelfLocation, style: TextStyle(fontSize: 11, color: p.shelfLocation == 'Rack 0-0' ? Colors.amber.shade900 : Colors.teal.shade800, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            DataCell(Text(p.unitType, style: const TextStyle(fontSize: 12))),
                            DataCell(Text('${p.minStockAlert}', style: const TextStyle(fontSize: 12))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: _isImporting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.file_upload, size: 18),
          label: Text(
            _newReadyCount > 0
                ? 'Confirm & Upload ($_newReadyCount New Medicines)'
                : 'Upload Medicines',
          ),
          onPressed: (_isImporting || result == null || _newReadyCount == 0)
              ? null
              : _executeImport,
        ),
      ],
    );
  }

  /// Post-upload comprehensive report dialog
  Widget _buildReportDialog(CsvBatchImportReport report) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.alertSafe.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_outline, color: AppColors.alertSafe, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Database Upload Summary Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'Bulk medicine upload completed. Detailed audit breakdown below:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat KPI Cards
              Row(
                children: [
                  // Newly Inserted
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${report.insertedCount}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                              Icon(Icons.add_task_rounded, color: Colors.green.shade700, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Newly Entered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const Text('Added to catalog database', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Already in Database
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${report.existingDbDuplicateCount}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                              Icon(Icons.copy_rounded, color: Colors.amber.shade700, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Already Existed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const Text('Matched Brand & Unit Type', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // File Skipped / Invalid
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${report.inCsvDuplicateCount + report.skippedMissingCount}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                              Icon(Icons.block_rounded, color: Colors.orange.shade700, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Skipped from File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const Text('File duplicate / no name', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Skipped export action area
              if (report.totalSkipped > 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${report.totalSkipped} items were not uploaded to the database.',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'You can export all skipped rows as a CSV file to review reasons, fix missing values, or modify duplicate entries.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Download Unable to Upload List (.csv)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => _downloadSkippedCsv(report.skippedItems),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          'View Detailed Skipped Breakdown (${report.skippedItems.length} rows)',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: report.skippedItems.length,
                              itemBuilder: (ctx, i) {
                                final item = report.skippedItems[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('Row ${item.rowNumber}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${item.brandName} (${item.unitType}): ${item.reason}',
                                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        if (report.totalSkipped > 0)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: const Text('Export Unable to Upload (.csv)'),
            onPressed: () => _downloadSkippedCsv(report.skippedItems),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context, report.insertedCount),
          child: const Text('Finish & Close', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
