# Smart Pharmacy - Antigravity Workspace Rules

## 1. Architectural Integrity
- Framework: Flutter Desktop (Windows target first, cross-platform structure).
- State Management: Riverpod (prefer Code Generation via `@riverpod`).
- Local Storage: Drift (SQLite) with Write-Ahead Logging (WAL) enabled.
- Data Identity: Every table must use UUIDv4 string primary keys and include `pharmacy_uid`.
- Offline-First: All reads/writes must target local SQLite. Do not make any blocking network calls.

## 2. Code Quality & Modularity
- Follow Clean Architecture:
  - `lib/core/` (constants, theme, errors, db singleton, utils)
  - `lib/features/<feature>/data/` (Drift DAOs, repositories, local data sources)
  - `lib/features/<feature>/domain/` (entities, value objects, business logic)
  - `lib/features/<feature>/presentation/` (widgets, screens, Riverpod controllers)
- Avoid massive single files: Break views into modular presentation components.
- Do not hardcode currency symbols, date formats, or magic numbers. Use `core/constants/`.

## 3. Database & Sync Discipline
- Never use auto-incrementing integer IDs for sync-sensitive entities (`users`, `medicines`, `batches`, `sales`, `sale_items`).
- Always record `created_at`, `updated_at`, `deleted_at`, and `sync_status`.
- Batch deductions in the POS must use database transactions (`db.transaction(...)`) to avoid race conditions and negative inventory.

## 4. UI/UX & Desktop Standards
- Desktop First: Ensure proper layout scaling for 1366x768 and 1920x1080 screens.
- Keyboard First: Add shortcuts (`Enter` to submit, `F1`-`F5` for tabs, `Esc` to clear/close modals).
- Use fluent/modern desktop aesthetics (Teal/Emerald accents, clean neutral background, clear contrast).