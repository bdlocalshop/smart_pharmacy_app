import 'dart:convert';
import 'package:csv/csv.dart';

/// Single medicine item parsed from CSV ready for catalog insertion.
class ProductImportItem {
  final String brandName;
  final String genericName;
  final String category;
  final String manufacturer;
  final String shelfLocation;
  final String unitType;
  final int minStockAlert;

  const ProductImportItem({
    required this.brandName,
    this.genericName = 'Not Available',
    this.category = 'Not Available',
    this.manufacturer = 'Not Available',
    this.shelfLocation = 'Rack 0-0',
    this.unitType = 'Tablet',
    this.minStockAlert = 50,
  });

  @override
  String toString() {
    return 'ProductImportItem(brandName: $brandName, genericName: $genericName, category: $category, manufacturer: $manufacturer, shelfLocation: $shelfLocation, unitType: $unitType, minStockAlert: $minStockAlert)';
  }
}

/// Result of CSV parsing containing valid products and skipped rows explanation.
class CsvImportResult {
  final List<ProductImportItem> validProducts;
  final int totalRowsParsed;
  final List<String> skippedReasons;

  const CsvImportResult({
    required this.validProducts,
    required this.totalRowsParsed,
    required this.skippedReasons,
  });

  int get importedCount => validProducts.length;
  int get skippedCount => skippedReasons.length;
  bool get hasSkipped => skippedReasons.isNotEmpty;
}

/// Robust CSV parser for medicine catalog imports adhering to pharmacy rules:
/// - Missing Name -> Skipped (row not uploaded)
/// - Missing Shelf Location -> Defaults to 'Rack 0-0'
/// - Missing or invalid Minimum Threshold -> Defaults to 50
/// - Other missing info (Generic, Category, Manufacturer) -> Defaults to 'Not Available'
/// - Missing Unit Type -> Defaults to 'Tablet'
class CsvMedicineImporter {
  static const String defaultShelfLocation = 'Rack 0-0';
  static const int defaultMinStockAlert = 50;
  static const String defaultNotAvailable = 'Not Available';
  static const String defaultUnitType = 'Tablet';

  /// Standard CSV Header Template
  static const List<String> csvHeaders = [
    'Brand / Commercial Name',
    'Generic Formula',
    'Therapeutic Category',
    'Manufacturer / Brand Pharma',
    'Physical Shelf Location',
    'Dispensing Unit Type',
    'Minimum Reorder Alert Threshold',
  ];

  /// Generates a complete ready-to-use CSV template string with example rows.
  static String generateCsvTemplate() {
    final rows = [
      csvHeaders,
      [
        'Panadol 500mg',
        'Paracetamol',
        'Analgesic / Antipyretic',
        'GSK',
        'Rack A-1',
        'Tablet',
        '50',
      ],
      [
        'Amoxil 250mg',
        'Amoxicillin',
        'Antibiotic',
        'GlaxoSmithKline',
        'Rack B-2',
        'Capsule',
        '30',
      ],
      [
        'Napa Extra',
        'Paracetamol + Caffeine',
        'Analgesic',
        'Beximco',
        '', // Empty shelf -> will become 'Rack 0-0'
        'Tablet',
        '', // Empty threshold -> will become 50
      ],
      [
        'Cough Relief Syrup',
        '', // Empty generic -> will become 'Not Available'
        '', // Empty category -> will become 'Not Available'
        '', // Empty manufacturer -> will become 'Not Available'
        'Rack C-3',
        'Syrup',
        '25',
      ],
      [
        'Vitamin C 1000mg',
        'Ascorbic Acid',
        'Vitamins & Supplements',
        'Square Pharmaceuticals',
        '', // Empty shelf -> 'Rack 0-0'
        '', // Empty unit -> 'Tablet'
        '', // Empty threshold -> 50
      ],
    ];

    return Csv().encode(rows);
  }

  /// Parses raw CSV content string into a structured [CsvImportResult].
  static CsvImportResult parseCsv(String rawCsvContent) {
    if (rawCsvContent.trim().isEmpty) {
      return const CsvImportResult(
        validProducts: [],
        totalRowsParsed: 0,
        skippedReasons: ['CSV file is empty.'],
      );
    }

    // Strip UTF-8 BOM if present
    var sanitized = rawCsvContent;
    if (sanitized.startsWith('\uFEFF')) {
      sanitized = sanitized.substring(1);
    }

    final csvCodec = Csv(dynamicTyping: false);
    final List<List<dynamic>> rows = csvCodec.decode(sanitized);
    if (rows.isEmpty) {
      return const CsvImportResult(
        validProducts: [],
        totalRowsParsed: 0,
        skippedReasons: ['No rows found in CSV file.'],
      );
    }

    // Determine header column mappings
    final headerRow = rows.first;
    int nameIdx = -1;
    int genericIdx = -1;
    int categoryIdx = -1;
    int manufacturerIdx = -1;
    int shelfIdx = -1;
    int unitIdx = -1;
    int thresholdIdx = -1;

    bool hasHeader = false;
    for (int i = 0; i < headerRow.length; i++) {
      final h = headerRow[i].toString().trim().toLowerCase();
      // Check manufacturer first so "Manufacturer / Brand Pharma" doesn't get consumed by "brand"
      if (h.contains('manufacturer') || h.contains('pharma') || h.contains('company') || h.contains('brand pharma') || h.contains('producer')) {
        manufacturerIdx = i;
        hasHeader = true;
      } else if (h.contains('brand') || h.contains('commercial name') || h.contains('medicine name') || h.contains('product name') || h == 'name' || h == 'brand name') {
        nameIdx = i;
        hasHeader = true;
      } else if (h.contains('generic') || h.contains('formula')) {
        genericIdx = i;
        hasHeader = true;
      } else if (h.contains('category') || h.contains('therapeutic') || h.contains('group')) {
        categoryIdx = i;
        hasHeader = true;
      } else if (h.contains('shelf') || h.contains('rack') || h.contains('location')) {
        shelfIdx = i;
        hasHeader = true;
      } else if (h.contains('unit') || h.contains('dispensing') || h.contains('type')) {
        unitIdx = i;
        hasHeader = true;
      } else if (h.contains('threshold') || h.contains('alert') || h.contains('reorder') || (h.contains('min') && h.contains('stock'))) {
        thresholdIdx = i;
        hasHeader = true;
      }
    }

    // If no header matches were found, fallback to positional indices:
    // 0: Brand, 1: Generic, 2: Category, 3: Manufacturer, 4: Shelf, 5: Unit, 6: Threshold
    if (!hasHeader) {
      nameIdx = 0;
      genericIdx = 1;
      categoryIdx = 2;
      manufacturerIdx = 3;
      shelfIdx = 4;
      unitIdx = 5;
      thresholdIdx = 6;
    }

    final validProducts = <ProductImportItem>[];
    final skippedReasons = <String>[];
    final startIndex = hasHeader ? 1 : 0;
    int totalDataRows = 0;

    for (int r = startIndex; r < rows.length; r++) {
      final row = rows[r];
      // Skip completely empty lines
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue;
      }

      totalDataRows++;
      final rowNumber = r + 1; // 1-based index for user-facing messages

      final rawName = _getValue(row, nameIdx);
      if (rawName == null || rawName.trim().isEmpty) {
        skippedReasons.add('Row $rowNumber: Skipped because Brand / Commercial Name is missing.');
        continue;
      }

      // Check if row accidentally repeats header text
      if (hasHeader && rawName.trim().toLowerCase() == 'brand / commercial name') {
        continue;
      }

      final brandName = rawName.trim();

      // Generic Formula: if missing -> "Not Available"
      final rawGeneric = _getValue(row, genericIdx);
      final genericName = (rawGeneric != null && rawGeneric.trim().isNotEmpty)
          ? rawGeneric.trim()
          : defaultNotAvailable;

      // Category: if missing -> "Not Available"
      final rawCategory = _getValue(row, categoryIdx);
      final category = (rawCategory != null && rawCategory.trim().isNotEmpty)
          ? rawCategory.trim()
          : defaultNotAvailable;

      // Manufacturer: if missing -> "Not Available"
      final rawManufacturer = _getValue(row, manufacturerIdx);
      final manufacturer = (rawManufacturer != null && rawManufacturer.trim().isNotEmpty)
          ? rawManufacturer.trim()
          : defaultNotAvailable;

      // Shelf Location: if missing -> "Rack 0-0"
      final rawShelf = _getValue(row, shelfIdx);
      final shelfLocation = (rawShelf != null && rawShelf.trim().isNotEmpty)
          ? rawShelf.trim()
          : defaultShelfLocation;

      // Unit Type: if missing -> "Tablet"
      final rawUnit = _getValue(row, unitIdx);
      final unitType = (rawUnit != null && rawUnit.trim().isNotEmpty)
          ? rawUnit.trim()
          : defaultUnitType;

      // Minimum Reorder Alert Threshold: if missing or invalid -> 50
      final rawThreshold = _getValue(row, thresholdIdx);
      int minStockAlert = defaultMinStockAlert;
      if (rawThreshold != null && rawThreshold.trim().isNotEmpty) {
        final parsed = int.tryParse(rawThreshold.trim());
        if (parsed != null && parsed >= 0) {
          minStockAlert = parsed;
        }
      }

      validProducts.add(
        ProductImportItem(
          brandName: brandName,
          genericName: genericName,
          category: category,
          manufacturer: manufacturer,
          shelfLocation: shelfLocation,
          unitType: unitType,
          minStockAlert: minStockAlert,
        ),
      );
    }

    return CsvImportResult(
      validProducts: validProducts,
      totalRowsParsed: totalDataRows,
      skippedReasons: skippedReasons,
    );
  }

  static bool _matches(String text, List<String> patterns) {
    final clean = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim().toLowerCase();
    return patterns.any((p) => clean.contains(p.toLowerCase()));
  }

  static String? _getValue(List<dynamic> row, int index) {
    if (index >= 0 && index < row.length) {
      final val = row[index];
      return val?.toString();
    }
    return null;
  }
}
