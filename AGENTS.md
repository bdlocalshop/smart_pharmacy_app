# Antigravity Specialized Agents

## 1. Database & Systems Architect (`@db-agent`)
- **Focus**: Drift ORM setup, SQLite schema creation, migrations, transaction integrity, and automated rolling backup engine (`backup_manager.dart`).
- **Standard**: Ensures all tables include `pharmacy_uid`, UUID PKs, CDC timestamps, and FEFO sorting queries.

## 2. UI/UX Desktop Engineer (`@ui-agent`)
- **Focus**: Flutter Desktop interface, responsive window sizing, keyboard event listeners, sidebar navigation, dialogs, and dynamic data tables.
- **Standard**: Follows clean spacing, desktop shortcut navigation, and accessible forms with instant field validation.

## 3. Domain & Business Logic Specialist (`@logic-agent`)
- **Focus**: Core business rules—FEFO allocation algorithms, real-profit calculations ($(\text{Selling} - \text{Cost}) \times \text{Qty} - \text{Discount}$), role-based permissions (Owner vs. Manager vs. Salesman), and session persistence.
- **Standard**: 100% unit test coverage for calculation logic and stock deduction.

## 4. Hardware & Export Integration Agent (`@io-agent`)
- **Focus**: Raw thermal receipt generation (80mm/58mm via ESC/POS or PDF printing), Excel export (`excel` package), and text audit summaries (`.txt`).
- **Standard**: Non-blocking asynchronous file operations with proper desktop directory resolution (`path_provider`).