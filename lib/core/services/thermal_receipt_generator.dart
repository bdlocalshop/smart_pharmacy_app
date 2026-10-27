import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Supported thermal paper widths.
enum ThermalReceiptFormat {
  mm80(width: 48, label: '80mm Thermal (Standard)'),
  mm58(width: 32, label: '58mm Thermal (Compact)');

  final int width;
  final String label;
  const ThermalReceiptFormat({required this.width, required this.label});
}

/// Item line on a thermal receipt.
class ReceiptLineItem {
  final String brandName;
  final String genericName;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantity;
  final double unitSellingPrice;
  final double lineTotal;

  ReceiptLineItem({
    required this.brandName,
    required this.genericName,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.unitSellingPrice,
    required this.lineTotal,
  });
}

/// Full invoice receipt dataset.
class ReceiptInvoiceData {
  final String pharmacyName;
  final String? licenseNumber;
  final String contactPhone;
  final String? address;
  final String currencySymbol;
  final String invoiceNumber;
  final DateTime date;
  final String cashierName;
  final String customerName;
  final String? customerPhone;
  final List<ReceiptLineItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalPayable;
  final String paymentMethod;
  final double amountTendered;
  final double changeReturned;

  ReceiptInvoiceData({
    required this.pharmacyName,
    this.licenseNumber,
    required this.contactPhone,
    this.address,
    this.currencySymbol = '\$',
    required this.invoiceNumber,
    required this.date,
    required this.cashierName,
    this.customerName = 'Walk-in Customer',
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    this.taxAmount = 0.0,
    required this.totalPayable,
    required this.paymentMethod,
    required this.amountTendered,
    required this.changeReturned,
  });
}

/// Hardware & Export Integration Agent (@io-agent)
/// Responsible for generating 80mm and 58mm ESC/POS command buffers and monospaced text slips.
class ThermalReceiptGenerator {
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _expFormat = DateFormat('MM/yy');

  /// Formats and pads text to center alignment within [width] columns.
  static String _centerText(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final totalPad = width - text.length;
    final leftPad = totalPad ~/ 2;
    final rightPad = totalPad - leftPad;
    return ' ' * leftPad + text + ' ' * rightPad;
  }

  /// Formats a key-value row with left and right alignment within [width] columns.
  static String _justifyRow(String left, String right, int width) {
    final available = width - right.length;
    if (available <= 0) return '$left $right';
    if (left.length > available - 1) {
      left = left.substring(0, available - 1);
    }
    return left.padRight(available) + right;
  }

  /// Generates a cleanly formatted monospace text receipt suitable for screen preview,
  /// text export, or plain ASCII thermal printer spooling.
  static String generateTextReceipt(
    ReceiptInvoiceData data, {
    ThermalReceiptFormat format = ThermalReceiptFormat.mm80,
  }) {
    final w = format.width;
    final divDouble = '=' * w;
    final divSingle = '-' * w;
    final divDotted = '.' * w;
    final currency = data.currencySymbol;

    final buffer = StringBuffer();

    // 1. Pharmacy Header
    buffer.writeln(divDouble);
    buffer.writeln(_centerText(data.pharmacyName.toUpperCase(), w));
    if (data.address != null && data.address!.trim().isNotEmpty) {
      buffer.writeln(_centerText(data.address!.trim(), w));
    }
    buffer.writeln(_centerText('Phone: ${data.contactPhone}', w));
    if (data.licenseNumber != null && data.licenseNumber!.trim().isNotEmpty) {
      buffer.writeln(_centerText('Drug Lic: ${data.licenseNumber!.trim()}', w));
    }
    buffer.writeln(divDouble);

    // 2. Invoice Meta Details
    if (format == ThermalReceiptFormat.mm80) {
      buffer.writeln(_justifyRow('Invoice: ${data.invoiceNumber}', _dateFormat.format(data.date), w));
      buffer.writeln(_justifyRow('Cashier: ${data.cashierName}', 'Mode: ${data.paymentMethod}', w));
    } else {
      buffer.writeln('Invoice: ${data.invoiceNumber}');
      buffer.writeln(_justifyRow('Date: ${_dateFormat.format(data.date)}', data.paymentMethod, w));
      buffer.writeln('Cashier: ${data.cashierName}');
    }
    buffer.writeln('Customer: ${data.customerName}');
    if (data.customerPhone != null && data.customerPhone!.trim().isNotEmpty) {
      buffer.writeln('Phone: ${data.customerPhone!.trim()}');
    }
    buffer.writeln(divSingle);

    // 3. Itemized Table
    if (format == ThermalReceiptFormat.mm80) {
      // 80mm (48 chars)
      buffer.writeln(_justifyRow('Item Description', 'Qty   Price   Total', w));
      buffer.writeln(divSingle);

      for (final item in data.items) {
        final expStr = _expFormat.format(item.expiryDate);
        final priceStr = '$currency${item.unitSellingPrice.toStringAsFixed(2)}';
        final totalStr = '$currency${item.lineTotal.toStringAsFixed(2)}';
        final qtyStr = item.quantity.toString().padLeft(3);

        final rightMetrics = '$qtyStr ${priceStr.padLeft(7)} ${totalStr.padLeft(8)}';
        buffer.writeln(_justifyRow(item.brandName, rightMetrics, w));
        buffer.writeln('  Batch: ${item.batchNumber} | Exp: $expStr');
      }
    } else {
      // 58mm (32 chars): Compact Layout
      buffer.writeln(_justifyRow('Item Description', 'Qty x Rate   Total', w));
      buffer.writeln(divSingle);

      for (final item in data.items) {
        final expStr = _expFormat.format(item.expiryDate);
        final priceStr = '$currency${item.unitSellingPrice.toStringAsFixed(2)}';
        final totalStr = '$currency${item.lineTotal.toStringAsFixed(2)}';

        buffer.writeln(item.brandName);
        buffer.writeln(' Batch: ${item.batchNumber} ($expStr)');
        buffer.writeln(_justifyRow(' ${item.quantity} x $priceStr', totalStr, w));
      }
    }

    buffer.writeln(divSingle);

    // 4. Financial Calculations
    buffer.writeln(_justifyRow('Subtotal:', '$currency${data.subtotal.toStringAsFixed(2)}', w));
    if (data.discountAmount > 0) {
      buffer.writeln(
        _justifyRow('Discount:', '-$currency${data.discountAmount.toStringAsFixed(2)}', w),
      );
    }
    if (data.taxAmount > 0) {
      buffer.writeln(_justifyRow('Tax / VAT:', '+$currency${data.taxAmount.toStringAsFixed(2)}', w));
    }
    buffer.writeln(divDotted);
    buffer.writeln(
      _justifyRow('TOTAL PAYABLE:', '$currency${data.totalPayable.toStringAsFixed(2)}', w),
    );
    buffer.writeln(divDotted);
    buffer.writeln(
      _justifyRow('Amount Paid (${data.paymentMethod}):', '$currency${data.amountTendered.toStringAsFixed(2)}', w),
    );
    buffer.writeln(
      _justifyRow('Change Returned:', '$currency${data.changeReturned.toStringAsFixed(2)}', w),
    );
    buffer.writeln(divDouble);

    // 5. Friendly Pharmacy Footer & Legal Notice
    buffer.writeln(_centerText('Thank you for trusting us!', w));
    buffer.writeln(_centerText('Wishing you a speedy recovery!', w));
    buffer.writeln(_centerText('Goods returnable in 3 days with receipt', w));
    buffer.writeln(divDouble);

    return buffer.toString();
  }

  /// Generates standard ESC/POS command sequences (binary) ready to be sent
  /// directly to an 80mm or 58mm hardware thermal receipt printer (USB, COM, or Network).
  static Uint8List generateEscPosBytes(
    ReceiptInvoiceData data, {
    ThermalReceiptFormat format = ThermalReceiptFormat.mm80,
  }) {
    final bytes = <int>[];

    // Helper functions for ESC/POS commands
    void raw(List<int> cmd) => bytes.addAll(cmd);
    void line(String s) {
      bytes.addAll(latin1.encode(s));
      bytes.add(0x0A); // LF
    }

    // Initialize printer: ESC @ (1B 40)
    raw([0x1B, 0x40]);

    // Center alignment: ESC a 1 (1B 61 01)
    raw([0x1B, 0x61, 0x01]);

    // Double height + double width for pharmacy name: GS ! 17 (1D 21 11)
    raw([0x1D, 0x21, 0x11]);
    line(data.pharmacyName.toUpperCase());

    // Normal text size: GS ! 0 (1D 21 00)
    raw([0x1D, 0x21, 0x00]);

    if (data.address != null && data.address!.trim().isNotEmpty) {
      line(data.address!.trim());
    }
    line('Phone: ${data.contactPhone}');
    if (data.licenseNumber != null && data.licenseNumber!.trim().isNotEmpty) {
      line('Lic: ${data.licenseNumber!.trim()}');
    }

    // Divider
    line('=' * format.width);

    // Left alignment: ESC a 0 (1B 61 00)
    raw([0x1B, 0x61, 0x00]);

    if (format == ThermalReceiptFormat.mm80) {
      line(_justifyRow('Invoice: ${data.invoiceNumber}', _dateFormat.format(data.date), format.width));
      line(_justifyRow('Cashier: ${data.cashierName}', 'Method: ${data.paymentMethod}', format.width));
    } else {
      line('Invoice: ${data.invoiceNumber}');
      line(_justifyRow('Date: ${_dateFormat.format(data.date)}', data.paymentMethod, format.width));
      line('Cashier: ${data.cashierName}');
    }
    line('Customer: ${data.customerName}');
    if (data.customerPhone != null && data.customerPhone!.trim().isNotEmpty) {
      line('Phone: ${data.customerPhone!.trim()}');
    }
    line('-' * format.width);

    // Items table
    final currency = data.currencySymbol;
    for (final item in data.items) {
      final expStr = _expFormat.format(item.expiryDate);
      final priceStr = '$currency${item.unitSellingPrice.toStringAsFixed(2)}';
      final totalStr = '$currency${item.lineTotal.toStringAsFixed(2)}';

      // Bold item brand name: ESC E 1 (1B 45 01)
      raw([0x1B, 0x45, 0x01]);
      line(item.brandName);
      // Bold off: ESC E 0 (1B 45 00)
      raw([0x1B, 0x45, 0x00]);

      final batchLine = ' Batch: ${item.batchNumber} (Exp: $expStr)';
      final qtyPriceTotal = '${item.quantity} x $priceStr = $totalStr';
      line(_justifyRow(batchLine, qtyPriceTotal, format.width));
    }

    line('-' * format.width);

    // Financial calculations
    line(_justifyRow('Subtotal:', '$currency${data.subtotal.toStringAsFixed(2)}', format.width));
    if (data.discountAmount > 0) {
      line(_justifyRow('Discount:', '-$currency${data.discountAmount.toStringAsFixed(2)}', format.width));
    }
    if (data.taxAmount > 0) {
      line(_justifyRow('Tax / VAT:', '+$currency${data.taxAmount.toStringAsFixed(2)}', format.width));
    }

    // Emphasize Total Payable
    line('.' * format.width);
    raw([0x1B, 0x45, 0x01]); // Bold on
    line(_justifyRow('TOTAL PAYABLE:', '$currency${data.totalPayable.toStringAsFixed(2)}', format.width));
    raw([0x1B, 0x45, 0x00]); // Bold off
    line('.' * format.width);

    line(_justifyRow('Paid (${data.paymentMethod}):', '$currency${data.amountTendered.toStringAsFixed(2)}', format.width));
    line(_justifyRow('Change:', '$currency${data.changeReturned.toStringAsFixed(2)}', format.width));
    line('=' * format.width);

    // Footer - Centered
    raw([0x1B, 0x61, 0x01]);
    line('Thank you for trusting Smart Pharmacy!');
    line('Get Well Soon!');
    line('Return within 3 days with receipt & intact seal');

    // Feed lines and paper cut: GS V 66 03 (1D 56 42 03)
    raw([0x1B, 0x64, 0x04]); // ESC d 4: Feed 4 lines
    raw([0x1D, 0x56, 0x41, 0x03]); // GS V A 3: Full cut with feed

    return Uint8List.fromList(bytes);
  }

  /// Asynchronously exports and saves the receipt text to the user's Documents or custom directory.
  static Future<File> saveReceiptToFile(
    ReceiptInvoiceData data, {
    ThermalReceiptFormat format = ThermalReceiptFormat.mm80,
    String? customDirectory,
  }) async {
    final Directory baseDir;
    if (customDirectory != null) {
      baseDir = Directory(customDirectory);
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      baseDir = Directory(p.join(docDir.path, 'SmartPharmacy', 'Receipts'));
    }

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final sanitizedInvoice = data.invoiceNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    final filePath = p.join(baseDir.path, 'Receipt_${sanitizedInvoice}_${format.name}.txt');
    final receiptContent = generateTextReceipt(data, format: format);

    final file = File(filePath);
    await file.writeAsString(receiptContent, flush: true);
    return file;
  }
}
