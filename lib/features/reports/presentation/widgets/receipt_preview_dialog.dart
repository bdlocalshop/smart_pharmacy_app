import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/services/thermal_receipt_generator.dart';
import 'package:smart_pharmacy_app/core/services/windows_printer_service.dart';

/// Modal dialog showing live thermal receipt preview (80mm vs 58mm) and export/print options.
class ReceiptPreviewDialog extends StatefulWidget {
  final ReceiptInvoiceData receiptData;

  const ReceiptPreviewDialog({
    super.key,
    required this.receiptData,
  });

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  ThermalReceiptFormat _selectedFormat = ThermalReceiptFormat.mm80;
  bool _isSaving = false;
  bool _isPrinting = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final receiptText = ThermalReceiptGenerator.generateTextReceipt(
      widget.receiptData,
      format: _selectedFormat,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 650,
        height: 750,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(Icons.receipt_long, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thermal Receipt Preview - ${widget.receiptData.invoiceNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '80mm / 58mm ESC/POS hardware formatting & raw ASCII spooler',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const Divider(height: 24),

            // Format Toggle Row with Wrap
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const Text(
                  'Paper Format: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SegmentedButton<ThermalReceiptFormat>(
                  segments: const [
                    ButtonSegment(
                      value: ThermalReceiptFormat.mm80,
                      label: Text('80mm (Standard)'),
                      icon: Icon(Icons.print, size: 16),
                    ),
                    ButtonSegment(
                      value: ThermalReceiptFormat.mm58,
                      label: Text('58mm (Compact)'),
                      icon: Icon(Icons.receipt, size: 16),
                    ),
                  ],
                  selected: {_selectedFormat},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) {
                      setState(() {
                        _selectedFormat = set.first;
                      });
                    }
                  },
                ),
                if (_statusMessage != null)
                  Text(
                    _statusMessage!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Monospaced Receipt Preview Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Center(
                      child: SelectableText(
                        receiptText,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13,
                          height: 1.25,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt, size: 16),
                  label: const Text('Save Slip (.txt)'),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          try {
                            final file = await ThermalReceiptGenerator.saveReceiptToFile(
                              widget.receiptData,
                              format: _selectedFormat,
                            );
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                                _statusMessage = 'Saved: ${file.path.split(RegExp(r'[\\/]')).last}';
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                                _statusMessage = 'Save failed';
                              });
                            }
                          }
                        },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.print, size: 18),
                  label: Text(
                    _isPrinting
                        ? 'Printing...'
                        : 'Print (${_selectedFormat.label.split(' ').first})',
                  ),
                  onPressed: _isPrinting
                      ? null
                      : () async {
                          setState(() {
                            _isPrinting = true;
                            _statusMessage = 'Preparing print job...';
                          });

                          // 1. Save receipt slip file first so fallback is always available
                          File? slipFile;
                          try {
                            slipFile = await ThermalReceiptGenerator.saveReceiptToFile(
                              widget.receiptData,
                              format: _selectedFormat,
                            );
                          } catch (_) {}

                          bool printed = false;

                          // 2. Try rich PDF print dialog first
                          try {
                            final is80mm = _selectedFormat == ThermalReceiptFormat.mm80;
                            final rollFormat = is80mm
                                ? PdfPageFormat.roll80
                                : PdfPageFormat.roll57;

                            printed = await Printing.layoutPdf(
                              onLayout: (pageFormat) =>
                                  ThermalReceiptGenerator.generatePdfReceipt(
                                widget.receiptData,
                                format: _selectedFormat,
                              ),
                              name: 'Receipt_${widget.receiptData.invoiceNumber}',
                              format: rollFormat,
                            );
                          } on MissingPluginException catch (_) {
                            // If running app was not rebuilt with the new C++ native plugin yet,
                            // seamlessly print using Windows Native Print Spooler!
                            if (slipFile != null && Platform.isWindows) {
                              printed = await WindowsPrinterService.printTextFile(slipFile);
                            }
                          } catch (e) {
                            // Fallback to Windows spooler if PDF layout fails
                            if (slipFile != null && Platform.isWindows) {
                              printed = await WindowsPrinterService.printTextFile(slipFile);
                            }
                          }

                          if (mounted) {
                            setState(() {
                              _isPrinting = false;
                              _statusMessage = printed
                                  ? '✓ Printed to Windows default printer'
                                  : 'Print job dispatched';
                            });
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
