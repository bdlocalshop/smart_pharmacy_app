import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/services/thermal_receipt_generator.dart';

void main() {
  late ReceiptInvoiceData sampleReceipt;

  setUp(() {
    sampleReceipt = ReceiptInvoiceData(
      pharmacyName: 'Smart Pharmacy & Healthcare',
      licenseNumber: 'DRUG-LIC-78902',
      contactPhone: '+1 (555) 019-2834',
      address: '742 Evergreen Terrace, Suite 100',
      currencySymbol: '\$',
      invoiceNumber: 'INV-20261024-0001',
      date: DateTime(2026, 10, 24, 14, 30),
      cashierName: 'Dr. Sarah Jenkins',
      customerName: 'Robert Vance',
      customerPhone: '+1 (555) 0987',
      items: [
        ReceiptLineItem(
          brandName: 'Panadol 500mg',
          genericName: 'Paracetamol',
          batchNumber: 'PAN-2026-01',
          expiryDate: DateTime(2026, 6, 30),
          quantity: 2,
          unitSellingPrice: 5.00,
          lineTotal: 10.00,
        ),
        ReceiptLineItem(
          brandName: 'Amoxicillin 500mg',
          genericName: 'Amoxicillin Trihydrate',
          batchNumber: 'AMX-2027-05',
          expiryDate: DateTime(2027, 5, 15),
          quantity: 1,
          unitSellingPrice: 15.00,
          lineTotal: 15.00,
        ),
      ],
      subtotal: 25.00,
      discountAmount: 2.00,
      taxAmount: 0.00,
      totalPayable: 23.00,
      paymentMethod: 'Cash',
      amountTendered: 30.00,
      changeReturned: 7.00,
    );
  });

  group('Thermal Receipt Generation Tests (80mm & 58mm)', () {
    test('generateTextReceipt produces compliant 80mm layout with batches and expiries', () {
      final receipt80 = ThermalReceiptGenerator.generateTextReceipt(
        sampleReceipt,
        format: ThermalReceiptFormat.mm80,
      );

      // Verify header & width
      expect(receipt80.contains('SMART PHARMACY & HEALTHCARE'), isTrue);
      expect(receipt80.contains('DRUG-LIC-78902'), isTrue);
      expect(receipt80.contains('+1 (555) 019-2834'), isTrue);
      expect(receipt80.contains('Invoice: INV-20261024-0001'), isTrue);

      // Verify line items, batches, and expiries
      expect(receipt80.contains('Panadol 500mg'), isTrue);
      expect(receipt80.contains('Batch: PAN-2026-01'), isTrue);
      expect(receipt80.contains('Exp: 06/26'), isTrue);
      expect(receipt80.contains('Amoxicillin 500mg'), isTrue);
      expect(receipt80.contains('Batch: AMX-2027-05'), isTrue);
      expect(receipt80.contains('Exp: 05/27'), isTrue);

      // Verify financial summary
      expect(receipt80.contains('Subtotal:'), isTrue);
      expect(receipt80.contains('\$25.00'), isTrue);
      expect(receipt80.contains('Discount:'), isTrue);
      expect(receipt80.contains('-\$2.00'), isTrue);
      expect(receipt80.contains('TOTAL PAYABLE:'), isTrue);
      expect(receipt80.contains('\$23.00'), isTrue);
      expect(receipt80.contains('Amount Paid (Cash):'), isTrue);
      expect(receipt80.contains('\$30.00'), isTrue);
      expect(receipt80.contains('Change Returned:'), isTrue);
      expect(receipt80.contains('\$7.00'), isTrue);

      // Verify lines respect 80mm width (48 characters)
      final lines = receipt80.split('\n');
      for (final line in lines) {
        if (line.isNotEmpty) {
          expect(line.length, lessThanOrEqualTo(48));
        }
      }
    });

    test('generateTextReceipt produces compliant 58mm compact layout', () {
      final receipt58 = ThermalReceiptGenerator.generateTextReceipt(
        sampleReceipt,
        format: ThermalReceiptFormat.mm58,
      );

      expect(receipt58.contains('SMART PHARMACY & HEALTHCARE'), isTrue);
      expect(receipt58.contains('INV-20261024-0001'), isTrue);
      expect(receipt58.contains('PAN-2026-01'), isTrue);
      expect(receipt58.contains('AMX-2027-05'), isTrue);
      expect(receipt58.contains('\$23.00'), isTrue);

      // Verify lines respect 58mm width (32 characters)
      final lines = receipt58.split('\n');
      for (final line in lines) {
        if (line.isNotEmpty) {
          expect(line.length, lessThanOrEqualTo(32));
        }
      }
    });

    test('generateEscPosBytes generates standard hardware control sequences', () {
      final escPosBytes = ThermalReceiptGenerator.generateEscPosBytes(
        sampleReceipt,
        format: ThermalReceiptFormat.mm80,
      );

      expect(escPosBytes.isNotEmpty, isTrue);

      // 1. Check ESC @ (Initialize printer: 0x1B, 0x40)
      expect(escPosBytes[0], equals(0x1B));
      expect(escPosBytes[1], equals(0x40));

      // 2. Check Paper cut command at end: GS V (0x1D, 0x56)
      final len = escPosBytes.length;
      expect(escPosBytes[len - 4], equals(0x1D));
      expect(escPosBytes[len - 3], equals(0x56));
      expect(escPosBytes[len - 2], equals(0x41)); // Full cut
    });

    test('saveReceiptToFile writes receipt to disk asynchronously', () async {
      final tempDir = Directory.systemTemp.createTempSync('receipt_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final file = await ThermalReceiptGenerator.saveReceiptToFile(
        sampleReceipt,
        format: ThermalReceiptFormat.mm80,
        customDirectory: tempDir.path,
      );

      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(content.contains('INV-20261024-0001'), isTrue);
      expect(content.contains('Panadol 500mg'), isTrue);
    });
  });
}

