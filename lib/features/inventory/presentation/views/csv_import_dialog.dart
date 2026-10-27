import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../../domain/csv_medicine_importer.dart';

/// Modal dialog for uploading and importing multiple medicines from a CSV file.
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

  Future<void> _pickCsvFile() async {
    setState(() {
      _errorMessage = null;
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

      final parsed = CsvMedicineImporter.parseCsv(csvContent);

      setState(() {
        _selectedFileName = file.name;
        _importResult = parsed;
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

  Future<void> _executeImport() async {
    final result = _importResult;
    if (result == null || result.validProducts.isEmpty) return;

    final session = ref.read(currentUserSessionProvider);
    if (session == null) return;

    setState(() => _isImporting = true);

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final count = await repo.addMultipleProducts(
        pharmacyUid: session.pharmacyUid,
        products: result.validProducts,
      );

      if (mounted) {
        Navigator.pop(context, count);
      }
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
                  'Bulk upload medicines into your master catalog using a CSV file.',
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
        width: 750,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pharmacy Rules Banner
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
                        Text('Automatic CSV Processing Rules:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('• Missing Brand/Commercial Name: Row is skipped (NOT uploaded).', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing Shelf Location: Automatically assigned to "Rack 0-0".', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing / Invalid Reorder Alert Threshold: Defaults to 50 units.', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Other Missing Information (Generic, Category, Manufacturer): Marked as "Not Available".', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    Text('• Missing Dispensing Unit Type: Defaults to "Tablet".', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
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
                      Text('Reading and parsing CSV data...'),
                    ],
                  ),
                ),
              ],

              // Parsed Statistics & Preview Table
              if (result != null && !_isProcessing) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Valid count badge
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
                                Text('${result.importedCount} Ready to Import', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.alertSafe)),
                                Text('Total rows found: ${result.totalRowsParsed}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Skipped count badge
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
                                Text(
                                  '${result.skippedCount} Rows Skipped',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: result.hasSkipped ? Colors.orange.shade900 : Colors.grey.shade700),
                                ),
                                const Text('Name missing / invalid', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (result.hasSkipped) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'View Skipped Rows Details (${result.skippedCount})',
                      style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: result.skippedReasons.length,
                          itemBuilder: (ctx, i) => Text('• ${result.skippedReasons[i]}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
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
            result != null && result.validProducts.isNotEmpty
                ? 'Confirm & Upload (${result.validProducts.length} Items)'
                : 'Upload Medicines',
          ),
          onPressed: (_isImporting || result == null || result.validProducts.isEmpty)
              ? null
              : _executeImport,
        ),
      ],
    );
  }
}
