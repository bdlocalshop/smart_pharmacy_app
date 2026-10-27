# Product Requirements Document (PRD)

## Project: Smart Pharmacy Desktop App (Flutter Edition)
- **Document Version:** 2.0.0
- **Target Runtime:** Windows Desktop (Flutter x64, with macOS & Linux cross-compilation support)
- **Local Engine:** SQLite via `drift` + `sqlite3_flutter_libs` with Write-Ahead Logging (WAL)
- **Design Philosophy:** 100% Offline-First with Sync-Ready Bi-Directional CDC (Change Data Capture)
- **Environment:** Google Antigravity Workspace

---

## 1. Executive Summary & Vision

Smart Pharmacy is a high-performance, offline-first desktop application designed specifically for retail pharmacies, medicine shops, and dispensaries. It replaces the legacy Python prototype (`smart_pharmacy.db` / Tkinter/CustomTkinter) with a modern, production-grade **Flutter Desktop** architecture.

The system ensures complete operational autonomy on local machines without internet dependence. However, every record and architectural layer is engineered to be **future-sync-ready**—enabling bi-directional synchronization to a centralized cloud database in Phase 2 without requiring database schema rewrites or data migrations.

---

## 2. Multi-Tenancy, Identity & Future Sync Architecture

### 2.1 Multi-Tenancy Model
* **Pharmacy as an Isolated Tenant:** Each physical machine/installation represents a distinct pharmacy entity.
* **Global Unique Identifier (`pharmacy_uid`):** 
  * Generated on initial onboarding via cryptographic UUIDv4.
  * Every table and record stores this `pharmacy_uid`.
  * Guarantees partition isolation when data from hundreds of pharmacies sync to a single multi-tenant central cloud repository in Phase 2.

### 2.2 Primary Keys & Data Sync Principles
* **Collision-Free UUIDs:** To prevent primary key conflicts when syncing distributed local databases to a centralized server, all tables use **UUIDv4 text strings** as primary keys rather than auto-incrementing integers.
* **Change Data Capture (CDC) Metadata:** Every mutable table contains sync audit columns:
  * `created_at` (ISO 8601 UTC string)
  * `updated_at` (ISO 8601 UTC string)
  * `deleted_at` (Nullable ISO 8601 UTC string for soft deletes)
  * `sync_status` (Enum: `pending_insert`, `pending_update`, `pending_delete`, `synced`)
* **Soft Deletes Only:** No record is physically dropped with `DELETE FROM`. Instead, `deleted_at` is populated so deletions propagate cleanly to the cloud.

---

## 3. User Hierarchy & Role-Based Access Control (RBAC)

### 3.1 Organization Structure
Each pharmacy instance operates with a strict, three-tier user hierarchy:
1. **Owner (1 per pharmacy):** Possesses master administrative control. Responsible for initial setup, system recovery, user creation, and sensitive business intelligence.
2. **Manager (1 or many):** Manages operational routines, inventory additions, supplier ledgers, and return approvals.
3. **Salesman (1 or many):** Dedicated Point of Sale (POS) operators with view-only stock access and billing permissions.

```
       ┌──────────────────────────────┐
       │   PHARMACY (pharmacy_uid)   │
       └──────────────┬───────────────┘
                      │
              ┌───────┴───────┐
              ▼               ▼
      ┌──────────────┐ ┌──────────────┐
      │ 1x OWNER     │ │ SETTINGS     │
      └───────┬──────┘ └──────────────┘
              │
      ┌───────┴───────────────┐
      ▼                       ▼
┌──────────────┐       ┌──────────────┐
│  MANAGERS    │       │  SALESMEN    │
│  (1 or many) │       │  (1 or many) │
└──────────────┘       └──────────────┘
```

### 3.2 Role Permissions Matrix

| Functional Module / Action | Owner | Manager | Salesman |
| :--- | :---: | :---: | :---: |
| Initial Pharmacy Onboarding & License Config | Yes | No | No |
| Create, Edit, or Deactivate Managers & Salesmen | Yes | No | No |
| Financial Reports, Estimated Profit & Cost Prices | Yes | Yes | No |
| Inventory & Batch Entry (Add / Edit / Adjust) | Yes | Yes | View-Only |
| Supplier Master & Due Ledger Management | Yes | Yes | No |
| POS Billing, Cart & Invoice Generation | Yes | Yes | Yes |
| Apply Custom Invoice Discounts | Yes | Yes | Configurable limit |
| Sales Return / Refund Processing | Yes | Yes | Requires Mgr PIN |
| Database Backup, External USB Export & Restore | Yes | No | No |
| Export Audit Reports (Excel, CSV, Text) | Yes | Yes | No |

### 3.3 Authentication & Session State
* **Local Password Security:** Passwords stored as salted cryptographic hashes (Argon2id or BCrypt).
* **Persistent Session:** Once logged in, the user stays authenticated across app restarts until an explicit **Logout** action is triggered.
* **Session Cache:** Active session metadata (User ID, Role, Pharmacy UID, and Token) stored securely using platform-native desktop keychains via `flutter_secure_storage`.
* **Lock Screen (Optional Fast Switch):** Quick PIN-pad lock screen allowing cashiers to step away without terminating the authenticated session.

---

## 4. Functional Capabilities (Parity with Legacy System & Enhancements)

### 4.1 Multi-Source & Multi-Price Batch Management
* **Decoupled Architecture:** Clean separation between **Medicine Master** (Brand Name, Generic Formula, Category, Manufacturer, Shelf Location, Reorder Threshold) and **Medicine Batches** (Batch #, Purchase Cost, Selling MRP, Expiry Date, Supplier Store, Remaining Units).
* **Multi-Supplier Support:** Procure the same SKU across diverse distributors with distinct cost structures without overriding historical pricing.

### 4.2 Point of Sale (POS) & Rapid Billing
* **Real-Time Stock & Shelf Display:** Instant visual display of non-expired stock and exact physical storage rack/shelf (e.g., `Rack A-1`) during search.
* **Smart FEFO Allocation:** Automatic calculation selecting batches closest to expiry (**First Expired, First Out**), preventing stale inventory build-up.
* **Full Keyboard Navigation:** Global hotkeys for cart focus (`F2`), payment tender (`F4`), discount application (`F6`), and print & complete (`Ctrl+Enter`).
* **Thermal Receipt Engine:** Direct integration with 80mm and 58mm ESC/POS hardware thermal printers, generating clean slips with invoice numbers, itemized batch references, and expiry dates.
* **Dual Cashier Workflow:** Hold cart functionality to serve another customer in parallel.

### 4.3 Expiry Radar & Stock Alerts
* **Color-Coded Expiry Radar:**
  * 🔴 **Expired Stock:** Immediately hard-blocked from POS cart additions; flagged for supplier return/disposal.
  * 🟡 **Expiring in < 30 Days:** Critical urgency banner for priority clearance or supplier buy-back.
  * 🟠 **Expiring in < 60 & < 90 Days:** Early-warning threshold filters.
* **Low Stock & Reorder Warnings:** Real-time triggers when aggregate valid batch stock falls below configured minimum quantities.

### 4.4 Sales Analytics, Profit Calculation & Reporting
* **Dynamic Period Filtering:** Switch across **Today**, **Yesterday**, **This Week**, **This Month**, and **Custom Date** ranges (with presets like *Last 7 Days*, *Last 30 Days*, *This Year*).
* **Dynamic KPIs:** Instant calculation of **Total Invoices**, **Units Sold**, **Gross Revenue**, and **Estimated Gross Profit**.
* **Accurate Batch Profit Logic:**
  $$\text{Profit} = \sum_{i=1}^{n} \left[ (\text{Selling Price}_i - \text{Batch Purchase Cost}_i) \times \text{Quantity}_i \right] - \text{Invoice Discount}$$
* **Dual Sales Report Export:**
  * Formatted **Excel Workbook (`.xlsx`)** detailing itemized transaction line items.
  * Executive **Text Audit Report (`.txt`)** summarising KPIs, payment breakdowns (Cash, Card, MFS, Due), top-performing medicines, and cashier audit trails.
* **Invoice Archive:** Multi-parameter search (Invoice #, Patient Phone, Date Range) with one-click re-print capability.

### 4.5 Data Storage, Backup & Maintenance Center
* **Engine:** Local SQLite using `drift` in Write-Ahead Logging (`PRAGMA journal_mode=WAL`) for high throughput and zero UI thread locking.
* **Automated Rolling Daily Backups:** Creates timestamped database archives in a dedicated local directory upon app initialization, auto-pruning snapshots older than 14 days.
* **One-Click USB / Cloud Sync Export:** Manual hot backup trigger saving `.sqlite` archives to external flash drives or synced folders (Google Drive, OneDrive, Dropbox).
* **Safe Database Restore:** Pre-restore verification that creates a fallback snapshot of the current state before applying historical data.

---

## 5. Relational Database Schema (Drift / SQLite)

```sql
-- 1. Pharmacy Tenant Configuration
CREATE TABLE pharmacy_settings (
    pharmacy_uid TEXT PRIMARY KEY,
    pharmacy_name TEXT NOT NULL,
    license_number TEXT,
    contact_phone TEXT NOT NULL,
    address TEXT,
    currency_symbol TEXT NOT NULL DEFAULT '$',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 2. User Accounts & RBAC
CREATE TABLE users (
    id TEXT PRIMARY KEY,                       -- UUIDv4
    pharmacy_uid TEXT NOT NULL,
    full_name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT CHECK(role IN ('OWNER', 'MANAGER', 'SALESMAN')) NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    FOREIGN KEY (pharmacy_uid) REFERENCES pharmacy_settings (pharmacy_uid)
);

-- 3. Medicine Master Catalog
CREATE TABLE medicines (
    id TEXT PRIMARY KEY,                       -- UUIDv4
    pharmacy_uid TEXT NOT NULL,
    brand_name TEXT NOT NULL,
    generic_name TEXT NOT NULL,
    category TEXT NOT NULL,
    manufacturer TEXT NOT NULL,
    shelf_location TEXT NOT NULL,              -- e.g., 'Rack A-1'
    unit_type TEXT NOT NULL DEFAULT 'Tablet',  -- Tablet, Strip, Syrup, Box
    min_stock_alert INTEGER NOT NULL DEFAULT 10,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    FOREIGN KEY (pharmacy_uid) REFERENCES pharmacy_settings (pharmacy_uid)
);

-- 4. Multi-Price Batches (FEFO Tracked)
CREATE TABLE medicine_batches (
    id TEXT PRIMARY KEY,                       -- UUIDv4
    pharmacy_uid TEXT NOT NULL,
    medicine_id TEXT NOT NULL,
    batch_number TEXT NOT NULL,
    supplier_name TEXT,
    purchase_cost REAL NOT NULL,               -- Batch-specific procurement price
    selling_price REAL NOT NULL,               -- Retail MRP
    initial_quantity INTEGER NOT NULL,
    remaining_units INTEGER NOT NULL,          -- Real-time stock counter
    expiry_date TEXT NOT NULL,                 -- YYYY-MM-DD
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    FOREIGN KEY (medicine_id) REFERENCES medicines (id),
    FOREIGN KEY (pharmacy_uid) REFERENCES pharmacy_settings (pharmacy_uid)
);

-- 5. Sales Invoices
CREATE TABLE sales_invoices (
    id TEXT PRIMARY KEY,                       -- UUIDv4
    pharmacy_uid TEXT NOT NULL,
    invoice_number TEXT NOT NULL UNIQUE,       -- INV-YYYYMMDD-XXXX
    cashier_user_id TEXT NOT NULL,
    customer_name TEXT DEFAULT 'Walk-in Customer',
    customer_phone TEXT,
    subtotal REAL NOT NULL,
    discount_amount REAL NOT NULL DEFAULT 0.0,
    tax_amount REAL NOT NULL DEFAULT 0.0,
    total_payable REAL NOT NULL,
    amount_tendered REAL NOT NULL,
    change_returned REAL NOT NULL,
    payment_method TEXT NOT NULL,              -- Cash, Card, Mobile, Due
    total_cost_price REAL NOT NULL,            -- Summed cost for fast profit reporting
    gross_profit REAL NOT NULL,                -- total_payable - total_cost_price
    created_at TEXT NOT NULL,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    FOREIGN KEY (cashier_user_id) REFERENCES users (id),
    FOREIGN KEY (pharmacy_uid) REFERENCES pharmacy_settings (pharmacy_uid)
);

-- 6. Sales Invoice Line Items (FEFO Audit Ledger)
CREATE TABLE sales_invoice_items (
    id TEXT PRIMARY KEY,                       -- UUIDv4
    pharmacy_uid TEXT NOT NULL,
    invoice_id TEXT NOT NULL,
    medicine_id TEXT NOT NULL,
    batch_id TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_cost_price REAL NOT NULL,             -- Historical cost at moment of sale
    unit_selling_price REAL NOT NULL,          -- Historical selling price
    line_total REAL NOT NULL,
    created_at TEXT NOT NULL,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    FOREIGN KEY (invoice_id) REFERENCES sales_invoices (id),
    FOREIGN KEY (medicine_id) REFERENCES medicines (id),
    FOREIGN KEY (batch_id) REFERENCES medicine_batches (id),
    FOREIGN KEY (pharmacy_uid) REFERENCES pharmacy_settings (pharmacy_uid)
);

-- 7. Audit & Sync Outbox Queue
CREATE TABLE sync_change_log (
    log_id TEXT PRIMARY KEY,                   -- UUIDv4
    pharmacy_uid TEXT NOT NULL,
    target_table TEXT NOT NULL,
    record_id TEXT NOT NULL,
    operation TEXT CHECK(operation IN ('INSERT', 'UPDATE', 'DELETE')) NOT NULL,
    changed_at TEXT NOT NULL,
    is_pushed INTEGER NOT NULL DEFAULT 0
);
```

---

## 6. Recommended Flutter Project Structure

```
smart_pharmacy_flutter/
├── assets/
│   ├── icons/
│   └── images/
├── lib/
│   ├── main.dart                             # Entrypoint, window setup & DI bootstrapper
│   ├── core/
│   │   ├── constants/                        # App colors, styles, dimensions
│   │   ├── database/
│   │   │   ├── app_database.dart             # Drift database definition & migrations
│   │   │   ├── tables.dart                   # Schema definitions
│   │   │   └── connection/native.dart        # SQLite FFI desktop connection loader
│   │   ├── services/
│   │   │   ├── backup_service.dart           # Automated snapshots, USB backup & restore
│   │   │   ├── export_service.dart           # Sync-free Excel (.xlsx) & Text (.txt) reports
│   │   │   ├── printer_service.dart          # Direct ESC/POS 80mm thermal print pipeline
│   │   │   └── secure_storage_service.dart   # Persistent session management
│   │   └── utils/
│   │       ├── fefo_calculator.dart          # Automated batch allocation engine
│   │       └── receipt_formatter.dart
│   ├── features/
│   │   ├── auth/                             # Login view, role guard, first-time setup
│   │   ├── pos/                              # Fast billing, keyboard hooks, checkout sheet
│   │   ├── inventory/                        # Medicines master, batch replenishment
│   │   ├── alerts/                           # Expiry radar (<30, <60, <90 days), low stock
│   │   ├── reports/                          # KPI dashboard, custom date filters, exports
│   │   ├── users/                            # User management (Owner-only view)
│   │   └── settings/                         # Pharmacy setup, printer config, backup center
│   └── shared_widgets/                       # Desktop dialogs, custom data tables, topbars
├── pubspec.yaml                              # Dependencies & assets configuration
└── test/                                     # Unit & widget integration test suite
```

---

## 7. Key Technology Packages

| Responsibility | Package | Rationale |
| :--- | :--- | :--- |
| **Local Database** | `drift` & `sqlite3_flutter_libs` | Type-safe SQL engine, native WAL performance, reactive UI streams, zero UI stutter. |
| **State Management** | `flutter_riverpod` | Predictable dependency injection, reactive state binding, desktop-scale testability. |
| **Secure Token Storage**| `flutter_secure_storage` | Cross-platform desktop keychain abstraction for persistent session retention. |
| **Excel Export** | `syncfusion_flutter_xlsio` or `excel` | Native `.xlsx` binary spreadsheet generation without external Excel runtimes. |
| **Thermal Printing** | `esc_pos_utils_plus` / `flutter_pos_printer_platform` | Direct 80mm/58mm raw receipt rasterization and serial/USB ESC/POS generation. |
| **Window Management** | `window_manager` | Controls desktop window dimensions, full-screen POS mode, and title-bar controls. |
| **Cryptographic Hashing**| `cryptography` / `dbcrypt` | Secure password hashing preventing clear-text exposure in local databases. |

---

## 8. Migration Path (Python to Flutter)

1. **Schema Equivalency:** The Drift SQLite schema is fully backwards-compatible with the fields in `smart_pharmacy.db`.
2. **Data Ingestion Script:** A one-time SQLite migration routine can read existing `smart_pharmacy.db` rows and populate the new UUID-based Flutter schema, generating a single `pharmacy_uid` for the existing installation and tagging legacy transactions as `synced` or `pending_insert`.
3. **Future Cloud Integration (Phase 2):** When the cloud backend (REST or WebSocket) is provisioned, the client will merely register an HTTP client to push entries from `sync_change_log` where `is_pushed = 0` and update them upon server acknowledgement.