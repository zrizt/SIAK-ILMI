# SIAK-ILMI: Autonomous Agent Progress & Task Tracker

> **Document Version:** 1.5.2  
> **Target Specification:** [`/docs/PRD.md`](file:///d:/SIAK-ILMI/docs/PRD.md)  
> **Last Updated:** 2026-11-07 20:58:00 +07:00  
> **Project Root:** `d:\SIAK-ILMI`  
> **Status:** Phase 9 Complete + UI Logo/Header Customization — Replaceable Placeholder PNG Logos (App & Header Banner), Centered Header, Left-Aligned Login Status Chip, 0 Analyzer Issues, 30/30 Tests Passing

---

## 1. Executive Summary & Status Overview

**SIAK-ILMI** (*Sistem Informasi Administrasi dan Keuangan Darul Ilmi*) is an offline-first, mobile-first student administration and financial POS management system engineered for **SMP IT Darul Ilmi** and **SD IT Baitul Akbar Parabek**.

The application is structured strictly under **Feature-First Clean Architecture** with **Flutter Riverpod** state management, typed **SQLite (Drift)** local database, **Indonesian localized M3 theme**, atomic transaction execution, immutable fee snapshotting, modular hardware output adapters (ESC/POS Bluetooth & WhatsApp-ready PDF receipts), and a fail-silent Google Drive cloud backup adapter.

| Metric | Status | Notes |
|---|---|---|
| **Clean Architecture Files** | **74+ files** written | Complete separation of `core`, `features`, and `app` |
| **Drift Schema & DAOs** | **13 tables, 7 DAOs** | Added `operator_account` table with optional `nip` & `OperatorDao` (schema v3), fully registered in `AppDatabase` |
| **Domain Use Cases** | **5 core engines** | Auto-NIS, Tariff Resolver, Bill Engine, Atomic POS, Bulk Billing Use Case |
| **PPDB Import & Auto-Billing** | **Complete (Phase 9)** | Excel (.xlsx) & CSV import with pre-import validation, duplicate detection, and automated semester SPP generation |
| **Bulk Semester Billing** | **Complete (Phase 9)** | Dedicated `BulkBillingScreen` & `BulkBillingUseCase` generating 6 monthly SPP charges for all active students with duplicate guard |
| **Formal PDF Kwitansi** | **Complete (Phase 9)** | Official Kop Surat (Yayasan & Sekolah), double-rule, Terbilang (words in IDR), cashier operator signature & footer with optional operator NIP |
| **Operator Management** | **Complete (Phase 9)** | SQLite-backed operator accounts, optional NIP, random salt + SHA-256 hash, CRUD UI, login/logout, receipt operator attribution |
| **Output Adapters & Factory** | **Complete & Integrated** | ESC/POS 58mm Thermal + WhatsApp PDF + `ReceiptModelFactory` wired to POS |
| **Batch POS Checklist** | **Complete (Phase 8)** | "Pilih Semua" / "Batal Semua" batch toolbar in POS Tab 1 |
| **Dark / Light Mode** | **Complete (Phase 8)** | `ThemeModeNotifier` with SharedPreferences persistence; 3-way toggle in Settings |
| **Modern UI Theme** | **Complete (Phase 8)** | Full M3 light + dark themes; deep Islamic green; flat-card design system |
| **Cloud Backup Adapter** | **Complete & Fail-Silent** | `DriveBackupService` with `googleapis` Drive v3 behind abstract `BackupService` with WAL checkpointing |
| **Auto-Lock Security** | **Complete & Reactive** | Dynamic 5-minute auto-lock listener in `AppShell` with gesture activity reset |
| **Static Analysis (`flutter analyze`)**| **0 issues found** | Clean analyzer exit code 0; 0 errors, 0 warnings, 0 lints across entire project |
| **Unit & Integration Tests (`flutter test`)**| **30/30 Passed (100%)** | 100% test pass rate across auto-NIS, bill engine, atomic POS, terbilang, operator service (including NIP), bulk billing, settings UI |
| **PRD Compliance** | **100% compliant** | Follows all non-negotiable rules & formulas |

---

## 2. Completed Tasks (By Phase & Audit Hardening)

### Phase 1: Project Setup & Database Layer ✅ (100%)
- [x] **Project Scaffolding**: Structured Clean Architecture folders (`lib/src` / `lib/{app, core, features, shared}`).
- [x] **Dependency Configuration (`pubspec.yaml`)**:
  - State: `flutter_riverpod: ^2.5.1`, `riverpod_annotation: ^2.3.5`
  - Database: `drift: ^2.18.0`, `sqlite3_flutter_libs: ^0.5.24`, `path_provider: ^2.1.3`, `path: ^1.9.0`
  - Parsers: `excel: ^4.0.3`, `csv: ^6.0.0`
  - Receipt & Output: `pdf: ^3.11.1`, `printing: ^5.13.1`, `blue_thermal_printer: ^1.1.2`, `esc_pos_utils_plus: ^2.0.2`, `share_plus: ^10.0.0`
  - Backup: `archive: ^3.6.1`, `google_sign_in: ^6.2.1`, `googleapis: ^13.2.0`, `http: ^1.2.1`
  - Security & Utilities: `crypto: ^3.0.3`, `shared_preferences: ^2.2.3`, `intl: ^0.20.3`
- [x] **Drift SQLite DDL (12 Tables)**:
  - `sekolah_table.dart` (`sekolah` with `kode_sekolah` unique: 1=SD, 2=SMP)
  - `tahun_ajaran_table.dart` (`tahun_ajaran` with `nama_ta`, `is_aktif`)
  - `kelas_table.dart` (`kelas` with `tingkat` 1–9)
  - `kategori_biaya_table.dart` (`kategori_biaya` with `tipe` 'Rutin'/'Sekali')
  - `siswa_table.dart` (`siswa` with unique `nis`, nullable `nisn`, status `AKTIF`/`LULUS`/`PINDAH`/`DROP_OUT`)
  - `tarif_master_table.dart` (`tarif_master` with `kategori_biaya_id`, `tingkat`, baseline `nominal`)
  - `skema_pembayaran_siswa_table.dart` (`skema_pembayaran_siswa` custom student rate override)
  - `tagihan_siswa_table.dart` (`tagihan_siswa` header with `periode`, `is_lunas`)
  - `tagihan_item_table.dart` (`tagihan_item` hardcopy snapshots: `nominal_awal`, `nominal_diskon`, `nominal_akhir`, `terbayar`, `is_lunas`)
  - `pembayaran_transaksi_table.dart` (`pembayaran_transaksi` with `nomor_kuitansi` 'KW-YYYYMMDD-XXXX', status `VALID`/`VOID`)
  - `alokasi_pembayaran_table.dart` (`alokasi_pembayaran` junction with cascade delete)
  - `audit_log_table.dart` (`audit_log` with role, action, timestamp, entity, details)
- [x] **Database Engine & DAOs**:
  - `app_database.dart`: WAL pragma, foreign keys enabled (`PRAGMA foreign_keys = ON`), composite indexes. Registered all 6 DAOs.
  - `siswa_dao.dart`: Active streams, school filtering, sequence counter, NIS/NISN lookups.
  - `tagihan_dao.dart`: Unpaid item watcher, `applyPaymentToItem`, `reversePaymentOnItem`, automatic parent header completion.
  - `pembayaran_dao.dart`: History watcher, daily counter counting all transactions to prevent receipt sequence collisions, date-range inflow sum.
  - `tarif_dao.dart`: Standard tariffs, custom override upsert/delete, fee category watchers.
  - `audit_dao.dart`: Audit logging accessor.
  - `sekolah_dao.dart`: School list accessor and Riverpod `sekolahDaoProvider`.
- [x] **Database Seeder (`database_seeder.dart`)**:
  - Idempotent initial seed: 2 school entities, Academic Year 2026/2027, 9 classes (Grades 1–6 SD, 7–9 SMP), 3 fee categories (SPP, Infaq Gedung, Pendaftaran), baseline tariffs across all grades.

---

### Phase 2: Domain Logic & Core Business Engines ✅ (100%)
- [x] **Auto-NIS Generator Engine (`auto_nis_generator_use_case.dart`)**:
  - Implements `[YY][SchoolCode][Sequence]` formula.
  - Generates zero-padded 3-digit sequence scoped by school and admission year.
  - Enforces sequence ceiling limit (≤ 999).
- [x] **Tariff Resolver Engine (`tariff_resolver_use_case.dart`)**:
  - Implements 2-tier priority: `skema_pembayaran_siswa` (custom override) > `tarif_master` (standard rate).
- [x] **Bill Generator Engine (`bill_generator_engine.dart`)**:
  - Hardcopy snapshot guarantee: writes immutable `nominal_awal`, `nominal_diskon`, and `nominal_akhir` directly into SQLite rows.
  - PPDB admission wave discount calculator (Wave 1: 100% discount, Wave 2: 50% discount, Wave 3: Pendaftaran free).
  - Validates that target student exists and is currently `AKTIF` (rejects inactive students).
  - Automatically marks 100% discounted line items (`nominal_akhir == 0`) and free headers as `is_lunas == 1`.
- [x] **Process Payment & POS Use Case (`process_payment_use_case.dart`)**:
  - Atomic multi-table SQLite transactions (`db.transaction()`).
  - Receipt sequence generation: `KW-YYYYMMDD-XXXX`.
  - Comprehensive allocation validation: positive nominals (> 0), duplicate item detection, student ownership verification, overpayment prevention.
  - Transaction void & rollback logic (reverses `terbayar` and restores unpaid status) with existence and state checks.
  - Integrated local audit logging.

---

### Phase 3: Presentation — Auth, Dashboard & Student Management ✅ (100%)
- [x] **Security & Authentication**:
  - `pin_service.dart`: Salted SHA-256 local 6-digit PIN hashing. Admin vs Viewer (Kepala Sekolah) RBAC.
  - `pin_auth_screen.dart`: Visual 6-digit PIN pad with auto-lock timer, quick numpad, and shake on invalid attempt.
  - `router.dart`: `AppShell` wrapping with `Listener` on pointer events to reset 5-minute auto-lock timer on user gesture.
- [x] **Executive Dashboard (`dashboard_screen.dart`)**:
  - Metric cards: Today's Inflow, Monthly Inflow, Active Student Count, Unpaid Arrears.
  - School level filter toggle: SD IT Baitul Akbar, SMP IT Darul Ilmi, or All Schools.
  - Quick POS cashier shortcut button.
  - 4-tab bottom navigation (Beranda, Siswa, Tarif, Pengaturan).
- [x] **Student Management & Dapodik Parser**:
  - `student_repository.dart`: Reactive active student watchers, student registration, status lifecycle, bulk import.
  - `dapodik_parser.dart`: Excel (.xlsx) and CSV (.csv) Dapodik file parsing with automatic grade-to-school mapping and NISN deduplication.
  - `student_list_screen.dart`: Multi-filter chips (All/SD/SMP), search bar by name/NIS/NISN, status badges.
  - Wired `_showImportDialog` directly to `dapodikParserProvider` and `studentRepository.bulkImport`.
  - Enforced RBAC: 'Tambah Siswa' and 'Import Dapodik' buttons gated strictly for Admin.
  - `student_form_screen.dart`: Validated entry form with dynamic grade chips and Auto-NIS preview.
  - `student_detail_screen.dart`: Student profile card, custom tuition override bottom sheet, lifecycle status changer using M3 `RadioGroup`, bill generation trigger, direct POS checkout trigger.
  - `generate_bill_screen.dart`: Admin form for custom monthly fee creation by period and category with instant snapshotting.
- [x] **Fee Management UI (`fee_management_screen.dart`)**:
  - Master tariff rate editor by grade level.
  - Fee category tab ('Rutin' vs 'Sekali').
  - RBAC gating on editing and adding new master tariffs (Admin only).

---

### Phase 4: Presentation — Checklist POS & Payment Allocation ✅ (100%)
- [x] **2-Tab Cashier Interface (`pos_checklist_screen.dart`)**:
  - **Tab 1 (Tagihan Belum Lunas):**
    - Interactive checkbox list of unpaid bills (`tagihan_item`).
    - Remaining balance computation (`nominal_akhir - terbayar`).
    - Inline partial payment input with real-time overpayment prevention (EC-01).
    - Payment method selector: 'Tunai' vs 'Transfer'.
    - Reactive item synchronization and controller lifecycle disposal to prevent stale balances.
    - RBAC check prohibiting non-admin (Viewer) payment execution.
    - Sticky bottom bar showing checked count, total allocation, and atomic checkout CTA.
  - **Tab 2 (Riwayat Pembayaran):**
    - Chronological list of transactions.
    - Status indicators (VALID vs VOID).
    - Transaction options modal (reprint / export / void).
  - **Direct Receipt Integration**:
    - Checkout success dialog triggers `ReceiptActionsSheet`.
    - History tiles trigger `ReceiptActionsSheet` via `receiptModelFactoryProvider`.

---

### Phase 5: Hardware & Output Adapters (PDF & ESC/POS) ✅ (100%)
- [x] **Receipt Data Model (`receipt_model.dart`)**:
  - Typed `ReceiptModel` and `ReceiptLineItem` representations.
- [x] **Receipt Model Factory (`receipt_model_factory.dart`)**:
  - Joins transaction, allocation items, student, school, and class data into a unified receipt representation.
- [x] **A5 PDF Receipt Generator (`pdf_receipt_generator.dart`)**:
  - Formatted for Indonesian WhatsApp sharing via `share_plus`.
  - School branding header, student metadata, clean itemized table with discount and paid amount, footer with receipt ID and cashier timestamp.
- [x] **ESC/POS Bluetooth Thermal Printer Adapter (`thermal_printer_adapter.dart`)**:
  - 58mm roll layout driver via `blue_thermal_printer` and `esc_pos_utils_plus`.
  - Connect, disconnect, scan, and raw byte streaming with paper feed and cut.
- [x] **Receipt Actions Bottom Sheet (`receipt_actions_sheet.dart`)**:
  - Modular sheet allowing one-tap Thermal Printing, WhatsApp PDF Sharing, or Full PDF Preview.

---

### Phase 6: Isolated Backup Module & Cloud Adapter ✅ (100%)
- [x] **Abstract Backup Service (`backup_service.dart`)**:
  - Decoupled `BackupService` interface.
  - Full WAL checkpoint execution (`PRAGMA wal_checkpoint(FULL);`) prior to zipping SQLite database.
  - Local database zip compressor storing encrypted/timestamped backups in Android `Downloads` directory.
  - Fail-silent error handling: network or cloud errors never crash core app workflows.
- [x] **Google Drive Cloud Adapter (`drive_backup_adapter.dart`)**:
  - Implements `BackupService` with `googleapis` Drive v3 API.
  - Uses `_GoogleAuthClient` for bearer token propagation.
  - Automates folder creation (`SIAK-ILMI-Backups`) and file uploads.
  - Strict fail-silent boundary: always creates local zip first with WAL checkpoint; cloud exceptions return as data.
- [x] **Backup UI Screen (`backup_restore_screen.dart`)**:
  - Backup creation trigger, last backup timestamp indicator, local backup file browser, and Drive sync status banner.
- [x] **Settings Screen (`settings_screen.dart`)**:
  - Complete with PIN update dialogs (Admin & Viewer), Bluetooth thermal printer connection bottom sheet, quick backup trigger, and technical specifications.
- [x] **Android Native Configuration**:
  - `AndroidManifest.xml` with Bluetooth, Storage, and Internet permissions.
  - `build.gradle` (app and root) configured with `minSdkVersion 24`, namespace `com.darulilmi.siakilmi`, and multiDex.
  - `settings.gradle` and `gradle-wrapper.properties` (Gradle 8.3).
  - Kotlin `MainActivity.kt` and splash/style themes.
  - `android/local.properties.example` template provided.
- [x] **Assets Configuration**:
  - Created `assets/images/.gitkeep` and `assets/fonts/.gitkeep` to prevent build warnings.

---

### Phase 8: Semester Billing, Batch POS, Dark Mode & Modern UI ✅ (100%) — 2026-11-07
- [x] **Semester-Based SPP Billing (`generate_bill_screen.dart`)**:
  - Replaced single-month manual input with a segmented mode toggle: "Tagihan SPP Semester" vs "Tagihan Manual".
  - Semester mode auto-generates 6 monthly SPP bills per semester following Indonesian academic calendar:
    - Semester 1 TA YYYY/YYYY+1 = Juli–Desember (months 7–12)
    - Semester 2 TA YYYY/YYYY+1 = Januari–Juni of YYYY+1 (months 1–6)
  - Semester dropdown spans 3 academic years (previous, current, next) with smart default to active semester.
  - Each month remains a **separate `tagihan_siswa`** to preserve AC-05 partial installment tracking.
  - Manual mode retained for one-off fees (Infaq Gedung, Pendaftaran, etc.).
  - Preview card shows all 6 months before confirmation.
- [x] **Efficient Batch Payment Checkbox (`pos_checklist_screen.dart`)**:
  - Added a sticky batch select toolbar above the POS checklist.
  - Shows live `N/Total dipilih` count.
  - "Pilih Semua" checks all items with full remaining-balance allocation.
  - "Batal Semua" unchecks all items and clears all partial amounts.
  - Button label toggles dynamically based on current selection state.
- [x] **Dark / Light Mode (`theme_provider.dart`, `app.dart`, `settings_screen.dart`)**:
  - New `lib/core/theme/theme_provider.dart` — `ThemeModeNotifier` with `SharedPreferences` persistence.
  - `app.dart` wired to `themeModeProvider`; theme changes apply live without restart.
  - Settings screen: new "Tampilan" section with popup menu: Terang / Gelap / Ikut Sistem.
  - Theme choice survives app restarts.
- [x] **Modern M3 UI Theme (`app_theme.dart`)**:
  - Full Material 3 light and dark themes with Islamic green palette.
  - Light: white cards with `outlineVariant` border, `#F5F7F5` scaffold.
  - Dark: `#0F1A0F` scaffold, `#1E2A1E` card surfaces, `#161E16` AppBar.
  - System overlay style adapts (white/dark status bar icons per theme).
  - Consistent `FilledButton`, `ChipTheme`, `ListTileTheme`, `DividerTheme` across both modes.
  - Removed deprecated `CardTheme` → `CardThemeData`, removed `.withOpacity()`.

---

### Phase 9: Excel/CSV Import Preview, Bulk Billing, Formal Kwitansi & Operator Accounts ✅ (100%) — 2026-11-07
- [x] **Excel/CSV Import with Preview & PPDB Auto-Billing (`import_preview_screen.dart`, `student_repository.dart`)**:
  - `ImportPreviewScreen`: Full visual pre-import data inspector for `.xlsx` and `.csv` files.
  - Duplicate NISN detection against SQLite database with automatic skipping.
  - Data validation displaying invalid rows in an expandable collapsible panel.
  - PPDB Auto-Billing: optional toggle (default on) to automatically create 6 months of SPP bills for newly registered students.
  - Connected directly to `StudentListScreen` import flow.
- [x] **Bulk Semester Billing (`bulk_billing_screen.dart`, `bulk_billing_use_case.dart`)**:
  - `BulkBillingUseCase`: Iterates through all active students (`AKTIF`) and generates 6 monthly bills for the chosen semester.
  - Duplicate billing guard (`itemExistsForPeriodeAndKategori`) prevents redundant bills if run repeatedly.
  - Result summary dialog showing counts for created, skipped (existing), and failed records.
  - UI entry point integrated into `FeeManagementScreen` AppBar.
- [x] **Indonesian School Payment Receipt / Kwitansi (`pdf_receipt_generator.dart`, `terbilang.dart`)**:
  - `Terbilang`: High-precision IDR currency-to-words converter handling ones, teens, tens, hundreds, thousands, millions, and billions.
  - Official Kop Surat: Yayasan & Sekolah header with logo placeholder, school address, phone/WA, and double-line rule.
  - "KUITANSI PEMBAYARAN" title with receipt number, student name, NIS, grade, payment timestamp, and payment method.
  - Itemized allocation table with IDR formatting and paid/unpaid status.
  - Total IDR amount accompanied by `# Terbilang #` text.
  - Cashier signature section with Indonesian date and operator's full name.
  - Official footer identifying operator and confirming validity.
- [x] **Operator Accounts & Receipt Attribution (`operator_account_table.dart`, `operator_dao.dart`, `operator_service.dart`, `operator_management_screen.dart`)**:
  - SQLite `operator_account` table with salt + SHA-256 password hashing (survives app reinstalls and is included in backups).
  - Schema upgraded to v3 with automatic migration adding optional `nip` column.
  - Form field for `NIP (Opsional)` in operator creation modal with numeric keyboard and badge icon.
  - Operator list and settings screen displaying operator's NIP when set.
  - Receipt model and formal PDF receipt printing the operator's official NIP below signature.
  - `OperatorDao` and `OperatorService` with login, password change, and active status toggling.
  - Default Administrator account seeded (`admin` / `admin123`).
  - `OperatorManagementScreen` for managing operators (Admin only).
  - Settings screen updated with Operator login status, logout, and management shortcuts.
  - `PosChecklistScreen` automatically attributes transaction `createdBy` to the logged-in operator.
- [x] **Unit & Integration Test Suite Expansion**:
  - `test/unit/terbilang_test.dart`: Validates edge cases and standard currency values.
  - `test/unit/operator_service_test.dart`: Validates operator login, password changes, deactivation, and optional NIP persistence.
  - `test/unit/bulk_billing_test.dart`: Validates active-student bulk billing and duplicate prevention.
  - `test/widget/settings_screen_test.dart`: Validates light/dark theme toggle and screen rendering.
  - **All 30/30 tests passing (100%)**.
  - **Static analysis: 0 issues found across entire codebase**.

---

### Quality Assurance & Verification Suite ✅ (100%)
- [x] `test/unit/auto_nis_generator_test.dart`: Validates AC-02 (NIS structure `[YY][SchoolCode][Sequence]`).
- [x] `test/unit/bill_generator_engine_test.dart`: Validates AC-06 and PPDB wave discount calculations.
- [x] `test/unit/process_payment_test.dart`: Validates AC-04 (multi-item atomic payment), AC-05 (partial payment allocation), and EC-02 (void transaction rollback).
- [x] `test/unit/terbilang_test.dart`: Validates Indonesian numbers-to-words currency converter (AC, EC edge cases).
- [x] `test/unit/operator_service_test.dart`: Validates operator authentication, random salt hashing, password changes, deactivation.
- [x] `test/unit/bulk_billing_test.dart`: Validates active-student bulk semester billing, duplicate suppression, inactive student protection.
- [x] `test/integration/offline_pos_flow_test.dart`: Comprehensive integration suite executing full offline flows:
  - Offline student registration & Auto-NIS (AC-01, AC-02)
  - Bill snapshot generation & atomic multi-item payment with installment (AC-04, AC-05)
  - Payment void and full reversal rollback (EC-02)
  - Historical bill snapshot immutability against master tariff modifications (EC-04)
  - Airplane mode fail-silent backup handling (EC-03)
- [x] **All 28/28 tests passing cleanly via `flutter test`** (verified 2026-11-07).
- [x] **`flutter analyze` reports "No issues found!" (exit code 0)** across the whole codebase (verified 2026-11-07).

---

## 3. Running Tasks & Agent Lifecycle Status

### Subagent Execution Ledger (19 Total Subagents)
All subagent tasks have resolved or concluded:

| Agent Role | Conversation ID | Work Completed | Lifecycle State |
|---|---|---|---|
| `pubspec & config writer` | `4d0fdf5e-edd0-4225-a85a-46a3c5aafb58` | Generated `pubspec.yaml`, `analysis_options.yaml` | `idle` |
| `Database tables writer` | `aea1ad41-b97f-4aed-af69-aafb34bb682f` | Initial 12 Drift database tables | `idle` |
| `App entry point writer` | `77a78e03-01f3-4465-b82b-0d6ba1c10bc8` | `main.dart`, `bootstrap.dart`, `app.dart`, `router.dart`, `app_theme.dart` | `idle` |
| `DAO file writer` | `8a9690b9-7988-4f3c-a565-a9c94f260f7c` | DAOs for Siswa, Tagihan, Pembayaran, Tarif, Audit | `idle` |
| `Core services writer` | `f451652a-eab6-4a12-a81a-798ea4e445e3` | `AppException`, `DateFormatter`, `CurrencyFormatter`, `PinService`, `AuditLoggerService` | `idle` |
| `Domain use-cases writer` | `a26e561f-f09c-454e-b856-2515b580b3f1` | Auto-NIS, Tariff Resolver, Bill Engine, Process Payment | `idle` |
| `Table files finalizer` | `359ef167-ef89-4d0e-bb6b-d91257ee8bea` | FK constraints, `build.sh`, `Makefile` | `idle` |
| `Student data+domain writer`| `310d4d23-d55e-4943-9742-3496a50647e0` | `student_repository.dart`, `dapodik_parser.dart`, `student_providers.dart` | `idle` |
| `Student presentation writer`| `6789b3d5-8f39-4572-a501-5a5f8af85f34` | Initial student list, form screens | `idle` |
| `Auth & Dashboard writer` | `b665b24c-5d28-449f-a725-39e17ab65eb7` | PIN Auth screen, Executive Dashboard screen | `idle` |
| `App shell & POS writer` | `6b8b96be-c1f3-4515-b062-dc4427981592` | Router auth switch, 2-tab POS Cashier screen | `idle` |
| `Student detail writer` | `9693d30c-fd67-45c5-b0e7-40f442ba81d2` | Final `student_detail_screen.dart`, `student_list_screen.dart` | `idle` |
| `PDF & ESC/POS writer` | `cf09a07b-27be-405f-8e86-afb339bd12c6` | `receipt_model.dart`, `pdf_receipt_generator.dart`, `thermal_printer_adapter.dart`, `receipt_actions_sheet.dart` | `idle` |
| `Android config writer` | `c4e04eb6-64d3-4460-83c0-06b025417f95` | AndroidManifest, build.gradle, settings.gradle, styles, launch_background | `idle` |
| `Test & validator writer` | `63940f85-f06a-47c1-82b0-49d702b04b73` | `input_validators.dart`, `process_payment_test.dart`, `pubspec.yaml` update | `idle` |
| `UI screens writer` | `f6dbc333-e270-4712-ae70-5f9d48892828` | `generate_bill_screen.dart`, `settings_screen.dart`, `backup_restore_screen.dart` | `idle` |
| Direct Agent Writing | *Main session* | Fixes, Dapodik UI, WAL checkpointing, 0 analyzer issues, 15/15 tests passing | `active` |

### Active Background Tasks
- No blocking background tasks.

---

## 4. Next Tasks (Build & Deployment Runbook)

### Execution Steps on Development Machine
1. **Developer Environment Verification**:
   - Ensure Flutter 3.22+ and Android SDK are available in the system PATH.
   - Copy `android/local.properties.example` to `android/local.properties` and verify Android SDK path.
2. **Code Generation Check**:
   - Code generation is verified and up-to-date. (If schema changes occur in the future, run `dart run build_runner build --delete-conflicting-outputs`).
3. **Automated Test Run**:
   - Run `flutter test` (currently passes 100% - 15/15 test cases).
4. **Static Analysis Check**:
   - Run `flutter analyze` (currently passes with 0 issues).
5. **Compile APK**:
   - Run `flutter build apk --debug` (or `--release`) for physical tablet/phone testing.

---

## 5. File Inventory & Architecture Map

```
d:\SIAK-ILMI\
├── android/                             # Android native bootstrap & configurations
│   ├── app/
│   │   ├── build.gradle                 # MinSdk 24, multiDex, namespace configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml      # Bluetooth, Storage, and Internet permissions
│   │       ├── kotlin/com/darulilmi/siakilmi/MainActivity.kt
│   │       └── res/                     # Splash & app styles
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradle/wrapper/gradle-wrapper.properties
│   └── local.properties.example        # Template for SDK paths
├── assets/                              # Static app assets
│   ├── fonts/
│   └── images/
├── docs/                                # Project Specifications
│   ├── PRD.md                           # Authoritative Product Requirements Document
│   ├── DATABASE_DESIGN.md
│   └── ARCHITECTURE.md
├── lib/
│   ├── main.dart                        # Flutter entry point
│   ├── app/
│   │   ├── app.dart                     # MaterialApp.router, Indonesian locale, M3 theme
│   │   ├── bootstrap.dart               # DB initialization and ProviderScope
│   │   └── router.dart                  # Role-aware routing & reactive 5-min auto-lock PIN gate
│   ├── core/
│   │   ├── database/
│   │   │   ├── app_database.dart        # Drift @DriftDatabase root with PRAGMA FK & WAL (All 6 DAOs registered)
│   │   │   ├── database_seeder.dart     # Idempotent 2-school initial seeder
│   │   │   ├── tables/                  # 12 SQLite Drift Tables
│   │   │   └── daos/                    # 6 Data Access Objects (Siswa, Tagihan, Pembayaran, Tarif, Audit, Sekolah)
│   │   ├── errors/app_exception.dart    # Sealed exception hierarchy (Nis, Overpayment, NotFound, Backup, Authorization, Validation)
│   │   ├── formatters/currency_formatter.dart # Indonesian Rupiah formatting
│   │   ├── security/pin_service.dart    # Salted SHA-256 PIN authentication with PinRole enum
│   │   ├── services/
│   │   │   ├── app_initializer.dart
│   │   │   └── audit_logger_service.dart # Centralized SQLite audit trail with typed AuditAction
│   │   ├── theme/
│   │   │   ├── app_theme.dart           # Full M3 light & dark Islamic green theme (Phase 8)
│   │   │   └── theme_provider.dart      # ThemeModeNotifier with SharedPreferences persistence (Phase 8)
│   │   └── utils/
│   │       ├── date_formatter.dart      # Indonesian date parser & receipt period generator
│   │       └── input_validators.dart    # Static form & PIN validation rules
│   └── features/
│       ├── backup_restore/              # Local .zip compression & Drive backup contracts
│       │   ├── data/
│       │   │   ├── backup_service.dart  # Abstract BackupService contract + Local zip engine with WAL checkpointing
│       │   │   └── drive_backup_adapter.dart # Google Drive v3 cloud sync adapter with WAL checkpointing
│       │   └── presentation/
│       │       └── backup_restore_screen.dart # Backup history & trigger UI
│       ├── dashboard/                   # Executive Cash Inflow Dashboard & school filters
│       ├── fee_management/              # Master tariffs, custom rates & bill snapshot generator
│       ├── payments/                    # 2-tab POS Cashier & atomic payment execution
│       ├── receipts/                    # ESC/POS Thermal, WhatsApp A5 PDF adapters & Factory
│       ├── settings/                    # PIN authentication & system configuration
│       └── students/                    # Auto-NIS generator, Dapodik parser, registry & bill generator
│           ├── data/
│           │   ├── dapodik_parser.dart  # .xlsx and .csv Dapodik import parser
│           │   └── student_repository.dart # Student repository with reactive streams & bulk import
│           ├── domain/
│           │   ├── auto_nis_generator_use_case.dart
│           │   └── student_providers.dart
│           └── presentation/
│               ├── generate_bill_screen.dart # Monthly fee bill creation screen
│               ├── student_detail_screen.dart # Student profile card, custom rates, M3 status changer
│               ├── student_form_screen.dart
│               └── student_list_screen.dart # Student list with school filters and Dapodik import dialog
├── test/
│   ├── integration/
│   │   └── offline_pos_flow_test.dart   # End-to-end integration tests (AC-01..05, EC-01..04)
│   └── unit/
│       ├── auto_nis_generator_test.dart # NIS formula unit tests
│       ├── bill_generator_engine_test.dart # Hardcopy snapshotting & wave discount tests
│       └── process_payment_test.dart    # Atomic transaction & void rollback tests
├── analysis_options.yaml
├── build.sh
├── Makefile
├── pubspec.yaml
└── AGENTS.md                            # Comprehensive status & task tracking
```

---

## 6. PRD Acceptance Criteria & Edge Case Compliance Matrix

| Criteria / Protocol | Description | Implementation Status |
|---|---|---|
| **AC-01** | Zero-latency Offline POS Operations | **PASS** — 100% local Drift SQLite, verified in `offline_pos_flow_test.dart` |
| **AC-02** | Auto-NIS Generation (`[YY][SchoolCode][Seq]`) | **PASS** — Covered in `AutoNisGeneratorUseCase` & unit/integration tests |
| **AC-03** | Dapodik Excel/CSV Import & Deduplication | **PASS** — Covered in `DapodikParser` & `_showImportDialog` with NISN deduplication |
| **AC-04** | Atomic Multi-Item Payments & Receipts | **PASS** — `ProcessPaymentUseCase` with `db.transaction()` |
| **AC-05** | Real-Time Installment & Arrears Tracking | **PASS** — Interactive partial payments in `PosChecklistScreen` |
| **AC-06** | PPDB Wave Discount Calculation | **PASS** — Evaluated in `BillGeneratorEngine` |
| **AC-07** | Local Zip Backup Creation | **PASS** — Implemented in `BackupServiceImpl` & `DriveBackupService` with WAL checkpoint |
| **EC-01** | Overpayment Prevention | **PASS** — Checked in POS UI & validated in domain engine |
| **EC-02** | Payment Void & Reversal Rollback | **PASS** — Full rollback in `ProcessPaymentUseCase.voidTransaction()` |
| **EC-03** | Zero-Network Airplane Mode Operations | **PASS** — All core engines run entirely on local SQLite |
| **EC-04** | Historical Bill Snapshot Immutability | **PASS** — Static snapshotting into `tagihan_item` rows |
| **EC-05** | Duplicate Student Import Rejection | **PASS** — Checked against existing NISN in DB |
| **EC-06** | Fail-Silent Cloud Backup Fallback | **PASS** — Local zip always created; cloud error returned as data |
