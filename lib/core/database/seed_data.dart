import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/password_hasher.dart';
import 'app_database.dart';

/// Database seeding engine for initial onboarding and developmental demo data.
class DatabaseSeeder {
  final AppDatabase db;
  static const _uuid = Uuid();

  DatabaseSeeder(this.db);

  /// Seeds default pharmacy settings, administrative accounts, and medicines with batches.
  /// Skips execution if database has already been initialized.
  Future<bool> seedIfEmpty({bool seedUsers = true}) async {
    final existingSettings = await db.select(db.pharmacySettingsTable).get();
    if (existingSettings.isNotEmpty) {
      // Auto-migrate previous default demo phone to user's phone number
      final existing = existingSettings.first;
      if (existing.contactPhone == '+1 (800) 555-0199' || existing.contactPhone.isEmpty) {
        await (db.update(db.pharmacySettingsTable)
              ..where((tbl) => tbl.pharmacyUid.equals(existing.pharmacyUid)))
            .write(
          const PharmacySettingsTableCompanion(
            contactPhone: Value('+880 1717-449639'),
          ),
        );
      }
      return false; // Already seeded
    }

    await db.transaction(() async {
      final now = DateTime.now();
      final pharmacyUid = _uuid.v4();

      // 1. Pharmacy Settings
      await db.into(db.pharmacySettingsTable).insert(
            PharmacySettingsTableCompanion(
              pharmacyUid: Value(pharmacyUid),
              pharmacyName: const Value('Smart Pharmacy & Healthcare'),
              licenseNumber: const Value('LIC-PHARM-2026-904'),
              contactPhone: const Value('+880 1717-449639'),
              address: const Value('742 Evergreen Terrace, Medical District, Suite 100'),
              mapPinUrl: const Value('https://maps.google.com/?q=23.8103,90.4125'),
              currencySymbol: const Value(AppConstants.defaultCurrencySymbol),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 2. Users (OWNER, MANAGER, SALESMAN) - Optional
      final ownerId = _uuid.v4();
      final managerId = _uuid.v4();
      final salesmanId = _uuid.v4();

      if (seedUsers) {
        await db.into(db.usersTable).insert(
              UsersTableCompanion(
                id: Value(ownerId),
                pharmacyUid: Value(pharmacyUid),
                fullName: const Value('Dr. Sarah Jenkins (Owner)'),
                username: const Value('admin'),
                passwordHash: Value(PasswordHasher.hashPassword('admin123')),
                role: const Value(AppConstants.roleOwner),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value(AppConstants.syncSynced),
              ),
            );

        await db.into(db.usersTable).insert(
              UsersTableCompanion(
                id: Value(managerId),
                pharmacyUid: Value(pharmacyUid),
                fullName: const Value('Marcus Vance (Manager)'),
                username: const Value('manager'),
                passwordHash: Value(PasswordHasher.hashPassword('manager123')),
                role: const Value(AppConstants.roleManager),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value(AppConstants.syncSynced),
              ),
            );

        await db.into(db.usersTable).insert(
              UsersTableCompanion(
                id: Value(salesmanId),
                pharmacyUid: Value(pharmacyUid),
                fullName: const Value('Alex Rivera (Salesman)'),
                username: const Value('salesman'),
                passwordHash: Value(PasswordHasher.hashPassword('sales123')),
                role: const Value(AppConstants.roleSalesman),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value(AppConstants.syncSynced),
              ),
            );
      }

      // 3. Products (Medicines Master) & Batches
      // Product 1: Paracetamol 500mg
      final prod1Id = _uuid.v4();
      await db.into(db.productsTable).insert(
            ProductsTableCompanion(
              id: Value(prod1Id),
              pharmacyUid: Value(pharmacyUid),
              brandName: const Value('Panadol 500mg'),
              genericName: const Value('Paracetamol / Acetaminophen'),
              category: const Value('Analgesic / Antipyretic'),
              manufacturer: const Value('Haleon Healthcare'),
              shelfLocation: const Value('Rack A-1'),
              unitType: const Value('Tablet'),
              minStockAlert: const Value(50),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      // Batches for Product 1 (FEFO showcase: one expiring in 22 days, one in 400 days)
      final batch1Id = _uuid.v4();
      final batch2Id = _uuid.v4();
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch1Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod1Id),
              batchNumber: const Value('PAN-2026-01'),
              supplierName: const Value('MediGlobal Supplies'),
              purchasePrice: const Value(1.10),
              sellingPrice: const Value(2.50),
              initialQuantity: const Value(100),
              currentStock: const Value(40), // Expiring soon (<30 days)
              expiryDate: Value(now.add(const Duration(days: 22))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch2Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod1Id),
              batchNumber: const Value('PAN-2027-02'),
              supplierName: const Value('MediGlobal Supplies'),
              purchasePrice: const Value(1.15),
              sellingPrice: const Value(2.50),
              initialQuantity: const Value(200),
              currentStock: const Value(200),
              expiryDate: Value(now.add(const Duration(days: 400))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      // Product 2: Amoxicillin 500mg
      final prod2Id = _uuid.v4();
      await db.into(db.productsTable).insert(
            ProductsTableCompanion(
              id: Value(prod2Id),
              pharmacyUid: Value(pharmacyUid),
              brandName: const Value('Amoxil 500mg'),
              genericName: const Value('Amoxicillin Trihydrate'),
              category: const Value('Antibiotic'),
              manufacturer: const Value('GlaxoSmithKline'),
              shelfLocation: const Value('Rack A-2'),
              unitType: const Value('Capsule'),
              minStockAlert: const Value(30),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      final batch3Id = _uuid.v4();
      final batch4Id = _uuid.v4();
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch3Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod2Id),
              batchNumber: const Value('AMX-2026-01'),
              supplierName: const Value('Apex Pharma Logistics'),
              purchasePrice: const Value(4.20),
              sellingPrice: const Value(7.50),
              initialQuantity: const Value(60),
              currentStock: const Value(25), // Expiring <60 days
              expiryDate: Value(now.add(const Duration(days: 50))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch4Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod2Id),
              batchNumber: const Value('AMX-2027-02'),
              supplierName: const Value('Apex Pharma Logistics'),
              purchasePrice: const Value(4.40),
              sellingPrice: const Value(7.50),
              initialQuantity: const Value(120),
              currentStock: const Value(120),
              expiryDate: Value(now.add(const Duration(days: 550))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      // Product 3: Omeprazole 20mg (Demonstrating expired batch)
      final prod3Id = _uuid.v4();
      await db.into(db.productsTable).insert(
            ProductsTableCompanion(
              id: Value(prod3Id),
              pharmacyUid: Value(pharmacyUid),
              brandName: const Value('Losec 20mg'),
              genericName: const Value('Omeprazole'),
              category: const Value('Gastrointestinal / PPI'),
              manufacturer: const Value('AstraZeneca'),
              shelfLocation: const Value('Rack B-1'),
              unitType: const Value('Capsule'),
              minStockAlert: const Value(20),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      final batch5Id = _uuid.v4();
      final batch6Id = _uuid.v4();
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch5Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod3Id),
              batchNumber: const Value('OMP-EXPIRED-01'),
              supplierName: const Value('PharmaCare Direct'),
              purchasePrice: const Value(2.50),
              sellingPrice: const Value(5.00),
              initialQuantity: const Value(30),
              currentStock: const Value(12), // Expired 10 days ago!
              expiryDate: Value(now.subtract(const Duration(days: 10))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch6Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod3Id),
              batchNumber: const Value('OMP-2027-02'),
              supplierName: const Value('PharmaCare Direct'),
              purchasePrice: const Value(2.60),
              sellingPrice: const Value(5.00),
              initialQuantity: const Value(100),
              currentStock: const Value(95),
              expiryDate: Value(now.add(const Duration(days: 360))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      // Product 4: Cetirizine 10mg (Demonstrating Low Stock Alert)
      final prod4Id = _uuid.v4();
      await db.into(db.productsTable).insert(
            ProductsTableCompanion(
              id: Value(prod4Id),
              pharmacyUid: Value(pharmacyUid),
              brandName: const Value('Zyrtec 10mg'),
              genericName: const Value('Cetirizine Hydrochloride'),
              category: const Value('Antihistamine'),
              manufacturer: const Value('Johnson & Johnson'),
              shelfLocation: const Value('Rack B-2'),
              unitType: const Value('Tablet'),
              minStockAlert: const Value(25), // Threshold 25
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      final batch7Id = _uuid.v4();
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch7Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod4Id),
              batchNumber: const Value('CET-2027-01'),
              supplierName: const Value('MediGlobal Supplies'),
              purchasePrice: const Value(1.80),
              sellingPrice: const Value(3.80),
              initialQuantity: const Value(50),
              currentStock: const Value(8), // Low Stock Alert! 8 < 25
              expiryDate: Value(now.add(const Duration(days: 300))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      // Product 5: Azithromycin 500mg
      final prod5Id = _uuid.v4();
      await db.into(db.productsTable).insert(
            ProductsTableCompanion(
              id: Value(prod5Id),
              pharmacyUid: Value(pharmacyUid),
              brandName: const Value('Zithromax 500mg'),
              genericName: const Value('Azithromycin'),
              category: const Value('Antibiotic / Macrolide'),
              manufacturer: const Value('Pfizer'),
              shelfLocation: const Value('Rack C-1'),
              unitType: const Value('Tablet'),
              minStockAlert: const Value(15),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      final batch8Id = _uuid.v4();
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion(
              id: Value(batch8Id),
              pharmacyUid: Value(pharmacyUid),
              productId: Value(prod5Id),
              batchNumber: const Value('AZT-2026-01'),
              supplierName: const Value('Apex Pharma Logistics'),
              purchasePrice: const Value(12.00),
              sellingPrice: const Value(22.00),
              initialQuantity: const Value(40),
              currentStock: const Value(35), // Expiring <90 days
              expiryDate: Value(now.add(const Duration(days: 82))),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );

      // 4. Sample Completed Sale (Only if users were seeded, references salesmanId)
      if (seedUsers) {
        final saleId = _uuid.v4();
        const invoiceNumber = 'INV-20261024-0001';
        final saleTime = now.subtract(const Duration(hours: 2));

        // Items: 2 x Panadol ($2.50 selling, $1.10 cost) + 1 x Amoxil ($7.50 selling, $4.20 cost)
        // Subtotal = $5.00 + $7.50 = $12.50, Discount = $1.00, Tax = $0.00
        // Total Payable = $11.50
        // Total Cost = (2 * 1.10) + (1 * 4.20) = $2.20 + $4.20 = $6.40
        // Gross Profit = $11.50 - $6.40 = $5.10
        await db.into(db.salesTable).insert(
              SalesTableCompanion(
                id: Value(saleId),
                pharmacyUid: Value(pharmacyUid),
                invoiceNumber: const Value(invoiceNumber),
                cashierUserId: Value(salesmanId),
                customerName: const Value('Jane Doe (Walk-in)'),
                customerPhone: const Value('+1 (555) 234-5678'),
                subtotal: const Value(12.50),
                discountAmount: const Value(1.00),
                taxAmount: const Value(0.00),
                totalPayable: const Value(11.50),
                amountTendered: const Value(20.00),
                changeReturned: const Value(8.50),
                paymentMethod: const Value(AppConstants.paymentCash),
                totalCostPrice: const Value(6.40),
                grossProfit: const Value(5.10),
                createdAt: Value(saleTime),
                syncStatus: const Value(AppConstants.syncSynced),
              ),
            );

        await db.into(db.saleItemsTable).insert(
              SaleItemsTableCompanion(
                id: Value(_uuid.v4()),
                pharmacyUid: Value(pharmacyUid),
                saleId: Value(saleId),
                productId: Value(prod1Id),
                batchId: Value(batch1Id),
                quantity: const Value(2),
                unitCostPrice: const Value(1.10),
                unitSellingPrice: const Value(2.50),
                lineTotal: const Value(5.00),
                createdAt: Value(saleTime),
                syncStatus: const Value(AppConstants.syncSynced),
              ),
            );

        await db.into(db.saleItemsTable).insert(
              SaleItemsTableCompanion(
                id: Value(_uuid.v4()),
                pharmacyUid: Value(pharmacyUid),
                saleId: Value(saleId),
                productId: Value(prod2Id),
                batchId: Value(batch3Id),
                quantity: const Value(1),
                unitCostPrice: const Value(4.20),
                unitSellingPrice: const Value(7.50),
                lineTotal: const Value(7.50),
                createdAt: Value(saleTime),
                syncStatus: const Value(AppConstants.syncSynced),
              ),
            );
      }
    });

    return true;
  }
}

