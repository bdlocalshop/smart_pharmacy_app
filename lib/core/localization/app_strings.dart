/// Supported application languages
enum AppLanguage {
  en('en', 'English', 'EN'),
  bn('bn', 'বাংলা', 'বাং');

  final String code;
  final String label;
  final String shortLabel;

  const AppLanguage(this.code, this.label, this.shortLabel);
}

/// Comprehensive, strongly-typed localization dictionary for Smart Pharmacy UI.
class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isBn => language == AppLanguage.bn;

  // --- Common Actions ---
  String get save => isBn ? 'সংরক্ষণ করুন' : 'Save';
  String get cancel => isBn ? 'বাতিল' : 'Cancel';
  String get delete => isBn ? 'মুছে ফেলুন' : 'Delete';
  String get edit => isBn ? 'সম্পাদনা' : 'Edit';
  String get clear => isBn ? 'পরিষ্কার' : 'Clear';
  String get search => isBn ? 'অনুসন্ধান' : 'Search';
  String get refresh => isBn ? 'রিফ্রেশ' : 'Refresh';
  String get close => isBn ? 'বন্ধ করুন' : 'Close';
  String get add => isBn ? 'যোগ করুন' : 'Add';
  String get viewDetails => isBn ? 'বিস্তারিত দেখুন' : 'View Details';
  String get loading => isBn ? 'লোড হচ্ছে...' : 'Loading...';
  String get error => isBn ? 'ত্রুটি' : 'Error';
  String get success => isBn ? 'সফল হয়েছে' : 'Success';

  // --- Shell & Navigation ---
  String get navPosBilling => isBn ? 'পিওএস বিলিং' : 'POS Billing';
  String get navPosSubtitle => isBn ? 'ক্যাশিয়ার চেকআউট ও চালান' : 'Cashier checkout & invoices';
  
  String get navMedicineMaster => isBn ? 'মেডিসিন মাস্টার' : 'Medicine Master';
  String get navMedicineSubtitle => isBn ? 'ওষুধ ও ব্যাচ স্টক' : 'Medicines & batch stock';
  
  String get navExpiryRadar => isBn ? 'মেয়াদোত্তীর্ণ রাডার ও অ্যালার্ট' : 'Expiry Radar & Alerts';
  String get navExpirySubtitle => isBn ? 'জরুরি ও কম স্টক রাডার' : 'Urgency & low stock radar';
  
  String get navReports => isBn ? 'আর্থিক ও মুনাফা রিপোর্ট' : 'Financial & Profit Reports';
  String get navReportsSubtitle => isBn ? 'মোট লাভ ও নিরীক্ষা' : 'Gross margins & audit';
  
  String get navStaffManagement => isBn ? 'কর্মী ব্যবস্থাপনা' : 'Staff Management';
  String get navStaffSubtitle => isBn ? 'কর্মী তৈরি ও পরিচালনা' : 'Create & manage staff';
  
  String get navDatabaseBackups => isBn ? 'ডেটাবেস ও ব্যাকআপ' : 'Database & Backups';
  String get navDatabaseSubtitle => isBn ? 'রক্ষণাবেক্ষণ ও এক্সপোর্ট' : 'Maintenance & export';
  
  String get signOut => isBn ? 'সাইন আউট' : 'Sign Out';
  String get offlineModeWal => isBn ? 'এসকিউএলআইটি ওয়াল • অফলাইন মোড' : 'SQLite WAL • Offline Mode';
  String get tenantPrefix => isBn ? 'টেন্যান্ট:' : 'Tenant:';
  String get persistentSecureSession => isBn ? 'সুরক্ষিত স্থায়ী স্টোরেজ সেশন' : 'Persistent Secure Storage Session';

  // --- Roles ---
  String get roleOwner => isBn ? 'মালিক / প্রশাসক' : 'Owner / Administrator';
  String get roleManager => isBn ? 'ম্যানেজার' : 'Manager';
  String get roleSalesman => isBn ? 'পিওএস বিক্রয়কর্মী' : 'POS Salesman';
  String roleLabel(String roleCode) {
    return switch (roleCode.toUpperCase()) {
      'OWNER' => isBn ? 'ভূমিকা: মালিক (OWNER)' : 'Role: Owner / Administrator (OWNER)',
      'MANAGER' => isBn ? 'ভূমিকা: ম্যানেজার (MANAGER)' : 'Role: Manager (MANAGER)',
      'SALESMAN' => isBn ? 'ভূমিকা: বিক্রয়কর্মী (SALESMAN)' : 'Role: POS Salesman (SALESMAN)',
      _ => roleCode,
    };
  }

  // --- Main Shell View Titles ---
  String tabTitle(int index) {
    return switch (index) {
      0 => isBn ? 'পয়েন্ট অব সেল (পিওএস) বিলিং' : 'Point of Sale (POS) Billing',
      1 => isBn ? 'মেডিসিন মাস্টার ক্যাটালগ' : 'Medicine Master Catalog',
      2 => isBn ? 'মেয়াদোত্তীর্ণ রাডার ও স্টক সতর্কতা' : 'Expiry Radar & Stock Alerts',
      3 => isBn ? 'আর্থিক বিশ্লেষণ ও মোট মুনাফা প্রতিবেদন' : 'Financial Analytics & Gross Profit Reporting',
      4 => isBn ? 'ব্যবহারকারী অ্যাকাউন্ট ও কর্মী প্রশাসন (কেবল মালিক)' : 'User Accounts & Staff Management (Owner Only)',
      5 => isBn ? 'ডেটাবেস রক্ষণাবেক্ষণ ও সিস্টেম ব্যাকআপ' : 'Database Maintenance & System Backups',
      _ => isBn ? 'স্মার্ট ফার্মেসি' : 'Smart Pharmacy',
    };
  }

  // --- POS Billing View ---
  String get posSearchHint => isBn
      ? 'ব্র্যান্ড, জেনেরিক বা বারকোড দিয়ে খুঁজুন... (হটকি: F2)'
      : 'Search medicine by Brand, Generic, or Scan Barcode... (Hotkey: F2)';
  String get posHotkeySearch => isBn ? 'F2: অনুসন্ধান' : 'F2: Search';
  String get posVoiceSearch => isBn ? 'ভয়েস দিয়ে খুঁজুন' : 'Voice Search Medicine';
  String get posCartEmptyTitle => isBn ? 'পিওএস কার্ট বর্তমানে খালি আছে' : 'POS Cart is currently empty';
  String get posCartEmptySubtitle => isBn
      ? 'F2 চাপুন অথবা দ্রুত ওষুধ যোগ করতে বারকোড স্ক্যান করুন।'
      : 'Press F2 or scan a barcode to instantly add medicines to this transaction.';
  String get colMedicineShelf => isBn ? 'ওষুধ ও সেল্ফ অবস্থান' : 'Medicine & Shelf Locator';
  String get colBatchExpiry => isBn ? 'ফেফো ব্যাচ ও মেয়াদ' : 'FEFO Batch & Expiry';
  String get colUnitMrp => isBn ? 'একক মূল্য' : 'Unit MRP';
  String get colQuantity => isBn ? 'পরিমাণ' : 'Quantity';
  String get colLineDisc => isBn ? 'পণ্য ছাড়' : 'Line Disc';
  String get colTotal => isBn ? 'মোট' : 'Total';
  String get clearCart => isBn ? 'কার্ট খালি করুন' : 'Clear Cart';
  String lineItemsCount(int items, int units) => isBn
      ? '$items টি আইটেম (মোট $units ইউনিট)'
      : '$items line items ($units total units)';
  String get autoAllocatedFefo => isBn ? 'স্বয়ংক্রিয় ফেফো বরাদ্দ' : 'Auto-Allocated FEFO';
  String get customerDetails => isBn ? 'ক্রেতার বিবরণ' : 'Customer Details';
  String get customerName => isBn ? 'ক্রেতার নাম' : 'Customer Name';
  String get walkInCustomer => isBn ? 'খুচরা ক্রেতা' : 'Walk-in Customer';
  String get mobilePhone => isBn ? 'মোবাইল ফোন' : 'Mobile Phone';
  String get invoiceFinancialSummary => isBn ? 'চালানের আর্থিক সারসংক্ষেপ' : 'Invoice Financial Summary';
  String get cartSubtotal => isBn ? 'কার্ট মোট মূল্য' : 'Cart Subtotal';
  String get lineItemDiscounts => isBn ? 'পণ্যভিত্তিক ছাড়' : 'Line Item Discounts';
  String get invoiceDiscountPrompt => isBn ? 'চালান ছাড় (F6):' : 'Invoice Discount (F6):';
  String get totalNetPayable => isBn ? 'সর্বমোট প্রদেয়:' : 'Total Net Payable:';
  String get paymentMethodTender => isBn ? 'পরিশোধের মাধ্যম ও প্রাপ্ত টাকা' : 'Payment Method & Cash Tender';
  String get cashTenderedF4 => isBn ? 'প্রাপ্ত নগদ টাকা (F4)' : 'Cash Tendered (F4)';
  String get exactCash => isBn ? 'সমপরিমাণ' : 'Exact';
  String get changeToReturn => isBn ? 'ফেরতযোগ্য টাকা:' : 'Change to Return:';
  String get paymentShortfall => isBn ? 'বাকি টাকা:' : 'Payment Shortfall:';
  String get completeSaleButton => isBn ? 'বিক্রয় সম্পন্ন করুন (Ctrl + Enter)' : 'Complete Sale (Ctrl + Enter)';
  String get processingTransaction => isBn ? 'লেনদেন প্রক্রিয়াকরণ হচ্ছে...' : 'Processing Transaction...';
  String get inStock => isBn ? 'স্টকে আছে' : 'in stock';
  String get outOfStock => isBn ? 'স্টক শেষ' : 'Out of Stock';
  String get addEnter => isBn ? 'যোগ করুন (Enter)' : 'Add (Enter)';
  String get payCash => isBn ? 'নগদ' : 'Cash';
  String get payCard => isBn ? 'কার্ড' : 'Card';
  String get payMobile => isBn ? 'মোবাইল' : 'Mobile';
  String get payDue => isBn ? 'বাকি' : 'Due';

  // --- Medicine Master View ---
  String get searchCatalogHint => isBn
      ? 'ব্র্যান্ড, জেনেরিক, ক্যাটাগরি বা সেল্ফ অবস্থান (যেমন "Rack A-1") দিয়ে খুঁজুন...'
      : 'Search by Brand, Generic formula, Category, or Shelf location (e.g. "Rack A-1")...';
  String get addMedicineF3 => isBn ? 'ওষুধ যোগ করুন (F3)' : 'Add Medicine (F3)';
  String get categoryLabel => isBn ? 'ক্যাটাগরি:' : 'Category:';
  String get catAll => isBn ? 'সকল' : 'All';
  String get colMedBrandGeneric => isBn ? 'ওষুধ (ব্র্যান্ড ও জেনেরিক)' : 'Medicine (Brand & Generic)';
  String get colCategoryManufacturer => isBn ? 'ক্যাটাগরি ও প্রস্তুতকারক' : 'Category & Manufacturer';
  String get colShelfLocation => isBn ? 'সেল্ফ অবস্থান' : 'Shelf Location';
  String get colActiveStockFefo => isBn ? 'সক্রিয় স্টক (ফেফো)' : 'Active Stock (FEFO)';
  String get colEarliestExpiry => isBn ? 'নিকটতম মেয়াদ' : 'Earliest Expiry';
  String get colActions => isBn ? 'কার্যক্রম' : 'Actions';
  String get lowStockTag => isBn ? 'কম স্টক' : 'LOW STOCK';
  String get thresholdPrefix => isBn ? 'সতর্কতা সীমা:' : 'Threshold:';
  String expiredCount(int count) => isBn ? '($count টি মেয়াদোত্তীর্ণ)' : '($count expired)';
  String get noBatches => isBn ? 'কোন ব্যাচ নেই' : 'No batches';
  String batchCountLabel(int count) => isBn ? '$count টি ব্যাচ' : '$count Batches';
  String get salesmanViewNotice => isBn
      ? 'বিক্রয়কর্মী মোড: আপনার কেবল ওষুধ, সেল্ফ ও ব্যাচ অনুসন্ধান করার অনুমতি রয়েছে। নতুন ওষুধ যোগ বা সম্পাদনা করতে ম্যানেজার বা মালিকের অনুমতি প্রয়োজন।'
      : 'Salesman View-Only Mode: You have read-only access to search medicines, shelf locations, and batches. Adding or editing catalog items requires Manager or Owner credentials.';

  // --- Expiry Radar View ---
  String get radarExpiredTitle => isBn ? 'মেয়াদোত্তীর্ণ স্টক' : 'Expired Stock';
  String get radarExpiredSub => isBn ? '🔴 পিওএস থেকে ব্লক করা' : '🔴 Hard-blocked from POS';
  String get radarUnder30Title => isBn ? 'মেয়াদ ৩০ দিনের কম' : 'Expiring < 30 Days';
  String get radarUnder30Sub => isBn ? '🟡 অতি জরুরি' : '🟡 Critical urgency';
  String get radar31To60Title => isBn ? 'মেয়াদ ৩১-৬০ দিন' : 'Expiring 31-60 Days';
  String get radar31To60Sub => isBn ? '🟠 প্রাথমিক সতর্কতা' : '🟠 Early warning';
  String get radar61To90Title => isBn ? 'মেয়াদ ৬১-৯০ দিন' : 'Expiring 61-90 Days';
  String get radar61To90Sub => isBn ? '🟡 সাধারণ নোটিশ' : '🟡 Caution radar';
  String get radarLowStockTitle => isBn ? 'কম স্টক সতর্কতা' : 'Low Stock Threshold';
  String get radarLowStockSub => isBn ? '⚠️ পুনরায় অর্ডার প্রয়োজন' : '⚠️ Reorder required';
  String get radarAllAlerts => isBn ? 'সকল সতর্কতা' : 'All Alerts';
  String get radarExpiredFilter => isBn ? '🔴 মেয়াদোত্তীর্ণ স্টক' : '🔴 Expired Stock';
  String get radarUrgentFilter => isBn ? '🟡 জরুরি < ৩০ দিন' : '🟡 Urgent < 30 Days';
  String get radarWarningFilter => isBn ? '🟠 সতর্কতা ৩১-৬০ দিন' : '🟠 Warning 31-60 Days';
  String get radarCautionFilter => isBn ? '🟡 সতর্কতা ৬১-৯০ দিন' : '🟡 Caution 61-90 Days';
  String get radarLowStockFilter => isBn ? '⚠️ কম স্টক অর্ডার' : '⚠️ Low Stock Reorders';
  String get colBatchSupplier => isBn ? 'ব্যাচ ও সরবরাহকারী' : 'Batch # & Supplier';
  String get colStockRemaining => isBn ? 'অবশিষ্ট স্টক' : 'Stock Remaining';
  String get colExpiryDateStatus => isBn ? 'মেয়াদ ও অবস্থা' : 'Expiry Date & Status';
  String get disposeReturn => isBn ? 'বিনষ্ট / ফেরত' : 'Dispose / Return';
  String get inspectBatch => isBn ? 'ব্যাচ পরিদর্শন' : 'Inspect Batch';
  String get procureBatch => isBn ? 'ব্যাচ সংগ্রহ' : 'Procure Batch';
  String get availableActiveStock => isBn ? 'উপলব্ধ সক্রিয় স্টক' : 'Available Active Stock';
  String get reorderThreshold => isBn ? 'পুনরায় অর্ডার সীমা' : 'Reorder Threshold';
  String get shortageCount => isBn ? 'ঘাটতি পরিমাণ' : 'Shortage Count';
  String get medicinesLabel => isBn ? 'ওষুধ' : 'Medicines';
  String get unitsLabel => isBn ? 'ইউনিট' : 'units';
  String unitsCount(int count) => isBn ? '$count ইউনিট' : '$count units';
  String expiredDaysAgo(int days) => isBn ? '🔴 মেয়াদোত্তীর্ণ ($days দিন আগে)' : '🔴 EXPIRED (${days}d ago)';
  String urgentDaysLeft(int days) => isBn ? '🟡 জরুরি ($days দিন বাকি)' : '🟡 Urgent ($days days left)';
  String warningDaysLeft(int days) => isBn ? '🟠 সতর্কতা ($days দিন বাকি)' : '🟠 Warning ($days days left)';
  String cautionDaysLeft(int days) => isBn ? '🟡 নোটিশ ($days দিন বাকি)' : '🟡 Caution ($days days left)';
  String belowMinAlert(int deficit) => isBn ? '-$deficit ইউনিট নিম্নে' : '-$deficit units below min';
  String get noExpiringStockTitle => isBn ? 'এই ক্যাটাগরিতে কোনো মেয়াদোত্তীর্ণ স্টক নেই!' : 'No expiring or expired stock in this category!';
  String get noExpiringStockSub => isBn ? 'সকল ব্যাচ নির্ধারিত সীমার বাইরে নিরাপদে রয়েছে।' : 'All batches are safely beyond the selected threshold.';
  String get allStockAboveReorder => isBn ? 'সকল ওষুধের স্টক সন্তোষজনক অবস্থায় রয়েছে!' : 'All stock levels are above reorder thresholds!';

  // --- Financial & Reports View ---
  String get periodLabel => isBn ? 'সময়কাল:' : 'Period:';
  String get periodToday => isBn ? 'আজ' : 'Today';
  String get periodYesterday => isBn ? 'গতকাল' : 'Yesterday';
  String get periodThisWeek => isBn ? 'এই সপ্তাহ' : 'This Week';
  String get periodThisMonth => isBn ? 'এই মাস' : 'This Month';
  String get customRange => isBn ? 'নির্দিষ্ট সময়কাল' : 'Custom Range...';
  String get exportExcel => isBn ? 'এক্সেল এক্সপোর্ট (.xlsx)' : 'Export Excel (.xlsx)';
  String get exportAuditLog => isBn ? 'অডিট লগ এক্সপোর্ট (.txt)' : 'Export Audit Log (.txt)';
  String get kpiTotalInvoices => isBn ? 'মোট চালান' : 'Total Invoices';
  String get kpiUnitsSold => isBn ? 'বিক্রিত ইউনিট' : 'Units Sold';
  String get kpiGrossRevenue => isBn ? 'মোট আয়' : 'Gross Revenue';
  String get kpiEstimatedProfit => isBn ? 'আনুমানিক আসল লাভ' : 'Estimated Real Profit';
  String get paymentChannels => isBn ? 'পরিশোধের মাধ্যম:' : 'Payment Channels:';
  String get searchInvoicesHint => isBn ? 'চালান নম্বর, ক্রেতা, ফোন বা ক্যাশিয়ার দিয়ে খুঁজুন...' : 'Search by Invoice #, Customer, Phone, or Cashier...';
  String get noSalesInvoices => isBn ? 'নির্বাচিত সময়কালে কোনো বিক্রয় পাওয়া যায়নি।' : 'No sales invoices found for the selected period & filters.';
  String get colInvoiceNo => isBn ? 'চালান #' : 'Invoice #';
  String get colDate => isBn ? 'তারিখ' : 'Date';
  String get colDateTime => isBn ? 'তারিখ ও সময়' : 'Date & Time';
  String get colCustomer => isBn ? 'ক্রেতা' : 'Customer';
  String get colCashier => isBn ? 'ক্যাশিয়ার' : 'Cashier';
  String get colMethod => isBn ? 'পদ্ধতি' : 'Method';
  String get colUnits => isBn ? 'ইউনিট' : 'Units';
  String get colNetPayable => isBn ? 'প্রদেয়' : 'Net Payable';
  String get colTotalPayable => isBn ? 'সর্বমোট প্রদেয়' : 'Total Payable';
  String get colCostPrice => isBn ? 'ক্রয়মূল্য' : 'Cost Price';
  String get colBatchCost => isBn ? 'ব্যাচ ক্রয়মূল্য' : 'Batch Cost';
  String get colRealProfit => isBn ? 'আসল লাভ' : 'Real Profit';
  String get colMargin => isBn ? 'মার্জিন' : 'Margin';
  String get masterOwnerBadge => isBn ? 'মাস্টার ওনার' : 'Master Owner';

  // --- Staff Management View ---
  String get staffAdminTitle => isBn ? 'কর্মী ও ভূমিকা প্রশাসন' : 'Staff & Role Administration';
  String get staffAdminSubtitle => isBn
      ? 'কেবলমাত্র মালিক নতুন কর্মী লগইন তৈরি, নিরীক্ষা ও নিষ্ক্রিয় করতে পারেন।'
      : 'Only the Owner can create, inspect, and deactivate staff logins.';
  String get addStaffUserBtn => isBn ? 'কর্মী যোগ করুন' : 'Add Staff User';
  String get fullName => isBn ? 'পুরো নাম' : 'Full Name';
  String get username => isBn ? 'ব্যবহারকারীর নাম' : 'Username';
  String get password => isBn ? 'পাসওয়ার্ড' : 'Password';
  String get assignedRole => isBn ? 'নির্ধারিত ভূমিকা' : 'Assigned Role';
  String get phoneLabel => isBn ? 'ফোন নম্বর' : 'Phone Number';

  // --- Database Backups View ---
  String get dbMaintenanceTitle => isBn ? 'ডেটাবেস রক্ষণাবেক্ষণ ও ব্যাকআপ' : 'Database Maintenance & Backups';
  String get dbRecoveryRollingBackups => isBn ? 'ডেটাবেস রিকভারি ও রোলিং ব্যাকআপ' : 'Database Recovery & Rolling Backups';
  String get dbRecoverySubtitle => isBn
      ? 'প্রতিটি স্টার্টআপে ১৪ দিনের রোলিং রিটেনশন সহ স্বয়ংক্রিয় স্ন্যাপশট নেওয়া হয়। মালিক হিসেবে আপনি তাৎক্ষণিক স্ন্যাপশট, এক্সপোর্ট বা ডাটাবেস রিস্টোর করতে পারেন।'
      : 'Automated rolling snapshots occur on every startup with 14-day rolling retention. As the Owner, you can perform immediate hot snapshots, USB flash exports, or verified database restorations.';
  String get exportImmediateBackup => isBn ? 'তাৎক্ষণিক ব্যাকআপ তৈরি করুন (.sqlite)' : 'Export Immediate Backup (.sqlite)';
  String get restoreDatabaseArchive => isBn ? 'ডাটাবেস সংরক্ষণাগার রিস্টোর' : 'Restore Database Archive';
  String get openBackupFolder => isBn ? 'ব্যাকআপ ফোল্ডার খুলুন' : 'Open Backup Folder';
  String get backupDirectoryLabel => isBn ? 'ব্যাকআপ ফোল্ডার ডিরেক্টরি:' : 'Backup Directory:';
  String get savedArchivesHeader => isBn ? 'সংরক্ষিত ব্যাকআপ আর্কাইভসমূহ' : 'Saved Backup Archives';
  String get savedArchivesSubtitle => isBn
      ? 'নির্ধারিত ব্যাকআপ ফোল্ডারে উপস্থিত সমস্ত SQLite ব্যাকআপ ফাইল (সাম্প্রতিকটি প্রথমে)।'
      : 'All SQLite database backup archives found in the designated backup directory (newest first).';
  String get noBackupsFound => isBn
      ? 'ব্যাকআপ ফোল্ডারে কোনো ডেটাবেস আর্কাইভ ফাইল পাওয়া যায়নি।'
      : 'No database backup archives found in the designated backup folder.';
  String get refreshBackupsTooltip => isBn ? 'তালিকা রিফ্রেশ করুন' : 'Refresh Backup List';
  String get openInExplorerTooltip => isBn ? 'ফোল্ডারে এই ফাইলটি দেখুন' : 'Show file in Explorer';
  String get restoreThisArchiveTooltip => isBn ? 'এই ব্যাকআপটি রিস্টোর করুন' : 'Restore from this backup';
  String get deleteBackupTooltip => isBn ? 'ব্যাকআপ মুছুন' : 'Delete Backup';
  String get restoreWarningTitle => isBn ? 'ডাটাবেস সংরক্ষণাগার রিস্টোর করবেন?' : 'Restore Database Archive?';
  String get restoreWarningMessage => isBn
      ? 'সতর্কতা: সংরক্ষণাগার থেকে ডাটাবেস রিস্টোর করলে বর্তমান সমস্ত ডেটা মুছে ফেলা হবে এবং ব্যাকআপের ডেটা দ্বারা প্রতিস্থাপিত হবে!\n\nআপনি কি নিশ্চিত যে আপনি এগিয়ে যেতে চান এবং ব্যাকআপ ফাইল নির্বাচন করতে চান?'
      : 'WARNING: Restoring the database will permanently remove and overwrite all existing data (current sales, inventory, and user records) with data from the backup archive!\n\nDo you want to proceed and choose the backup file to restore?';
  String get restoreSpecificWarningMessage => isBn
      ? 'সতর্কতা: এই সংরক্ষণাগারটি রিস্টোর করলে বর্তমান সমস্ত ডেটা মুছে ফেলা হবে এবং প্রতিস্থাপিত হবে!\n\nআপনি কি নিশ্চিত যে আপনি এগিয়ে যেতে চান?'
      : 'WARNING: Restoring this archive will permanently remove and overwrite all existing data!\n\nAre you sure you want to proceed?';
  String get cancelBtn => isBn ? 'বাতিল' : 'Cancel';
  String get okBtn => isBn ? 'ঠিক আছে' : 'OK';
  String get backupCreatedSuccess => isBn ? 'ডাটাবেস ব্যাকআপ সফলভাবে তৈরি হয়েছে:' : 'Database backup created successfully:';
  String get databaseRestoredSuccess => isBn ? 'সংরক্ষণাগার থেকে ডাটাবেস সফলভাবে রিস্টোর হয়েছে!' : 'Database restored successfully from archive!';
  String get creatingBackupWait => isBn ? 'ব্যাকআপ তৈরি করা হচ্ছে...' : 'Creating database backup...';
  String get restoringDatabaseWait => isBn ? 'ডাটাবেস রিস্টোর করা হচ্ছে...' : 'Restoring database archive...';
  String get deleteBackupConfirmTitle => isBn ? 'ব্যাকআপ ফাইলটি মুছবেন?' : 'Delete Backup File?';
  String get deleteBackupConfirmMsg => isBn ? 'আপনি কি নিশ্চিত যে এই ব্যাকআপ ফাইলটি স্থায়ীভাবে মুছে ফেলতে চান?' : 'Are you sure you want to permanently delete this backup file?';
  String get fileNameCol => isBn ? 'ফাইলের নাম' : 'File Name';
  String get createdTimeCol => isBn ? 'তৈরির সময়' : 'Created / Modified';
  String get fileSizeCol => isBn ? 'সাইজ' : 'Size';
  String get actionsCol => isBn ? 'অ্যাকশন' : 'Actions';
  String get createBackupBtn => isBn ? 'এখনই ব্যাকআপ তৈরি করুন' : 'Create Backup Now';
  String get restoreDbBtn => isBn ? 'ডেটাবেস রিস্টোর করুন' : 'Restore Database';
  String get exportDbFileBtn => isBn ? 'ডেটাবেস ফাইল এক্সপোর্ট' : 'Export Database File';
  String get latestBackupBadge => isBn ? 'সাম্প্রতিক' : 'Latest';
  String get changeBackupFolderBtn => isBn ? 'ফোল্ডার পরিবর্তন' : 'Change Folder';
  String get resetToDefaultFolderBtn => isBn ? 'ডিফল্ট ফোল্ডার' : 'Reset to Default';
  String get customFolderBadge => isBn ? 'কাস্টম' : 'Custom';
  String get defaultFolderBadge => isBn ? 'ডিফল্ট' : 'Default';
  String get selectBackupDirectoryTitle => isBn ? 'ব্যাকআপ সংরক্ষণের ফোল্ডার নির্বাচন করুন' : 'Select Backup Storage Directory';
  String get backupFolderChangedSuccess => isBn ? 'ব্যাকআপ ফোল্ডার আপডেট করা হয়েছে:' : 'Backup directory changed to:';
  String get backupFolderResetSuccess => isBn ? 'ডিফল্ট ব্যাকআপ ফোল্ডারে রিসেট করা হয়েছে।' : 'Backup directory reset to default.';

  // --- Login Screen ---
  String get signInToTerminal => isBn ? 'টার্মিনালে সাইন ইন করুন' : 'Sign In to Terminal';
  String get signInSubtitle => isBn
      ? 'আপনার নির্ধারিত কর্মক্ষেত্রে প্রবেশ করতে কর্মী পরিচয় দিন।'
      : 'Enter your staff credentials to access your permitted workspace.';
  String get signInBtn => isBn ? 'সাইন ইন' : 'Sign In';
  String get authenticating => isBn ? 'যাচাই করা হচ্ছে...' : 'Authenticating...';
  String get quickAccountSwitcher => isBn ? 'দ্রুত অ্যাকাউন্ট পরিবর্তন (টেস্টিং):' : 'Quick Account Switcher (Demo / Testing):';
  String get ownerAdminChip => isBn ? 'মালিক (admin)' : 'Owner (admin)';
  String get managerChip => isBn ? 'ম্যানেজার (manager)' : 'Manager (manager)';
  String get salesmanChip => isBn ? 'বিক্রয়কর্মী (salesman)' : 'Salesman (salesman)';
}
