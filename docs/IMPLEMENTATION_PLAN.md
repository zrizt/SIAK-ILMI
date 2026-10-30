# SIAK-ILMI: Implementation Plan & Delivery Roadmap

> **Document Version:** 1.0.0  
> **Target Delivery:** Agentic AI Development (< 14 Days Execution)  
> **Status:** All Phases Completed, Hardened & Verified  
> **Target Institutions:** SMP IT Darul Ilmi & SD IT Baitul Akbar Parabek

---

## 1. Roadmap Overview & Timeline

| Phase | Milestone Description | Target Timeline | Status |
|---|---|---|---|
| **Phase 1** | Project Setup, Dependencies & Drift Database Layer | Days 1–2 | ✅ Completed |
| **Phase 2** | Domain Logic, Core Business Engines & Snapshotting | Days 3–4 | ✅ Completed |
| **Phase 3** | Authentication, Executive Dashboard & Student Module | Days 5–6 | ✅ Completed |
| **Phase 4** | POS Checklist Cashier & Atomic Payment Allocation | Days 7–8 | ✅ Completed |
| **Phase 5** | Hardware Adapters (Bluetooth Thermal & WhatsApp PDF) | Days 9–10 | ✅ Completed |
| **Phase 6** | Isolated Cloud Backup & Drive v3 Adapter | Days 11–12 | ✅ Completed |
| **Phase 7** | System Audit, Security Hardening & Automated Testing | Days 13–14 | ✅ Completed |

---

## 2. Phase-by-Phase Deliverables

### Phase 1: Project Setup & Database Layer
* **Scaffolding:** Feature-First Clean Architecture structure (`lib/{app, core, features}`).
* **Dependencies:** Configured Riverpod 2.5, Drift 2.18, Path Provider, Archive, Excel, CSV, PDF, Printing, Blue Thermal Printer, Googleapis.
* **12 Drift SQLite Tables:** Matching PRD Section 8 with composite indexes and cascade delete rules.
* **6 Data Access Objects (DAOs):** Modular accessors for Siswa, Tagihan, Pembayaran, Tarif, Audit, and Sekolah.
* **Idempotent Seeder:** Seeds 2 schools, Academic Year 2026/2027, 9 classes (Grades 1–6 SD, 7–9 SMP), 3 fee categories, and baseline tariffs.

### Phase 2: Domain Logic & Business Engines
* **Auto-NIS Generator Engine:** Evaluates `[YY][SchoolCode][Sequence]` formula scoped per institution and admission year.
* **Tariff Resolver Engine:** 2-tier priority: Custom student scheme (`skema_pembayaran_siswa`) overrides standard tariff (`tarif_master`).
* **Bill Generator & Snapshot Engine:** Hardcopies `nominal_awal`, `nominal_diskon`, and `nominal_akhir` directly into SQLite rows; evaluates PPDB promotional waves (Wave 1: 100%, Wave 2: 50%, Wave 3: free registration).
* **Process Payment Use Case:** Atomic multi-table SQLite transactions (`db.transaction()`), sequence generation `KW-YYYYMMDD-XXXX`, overpayment rejection, and transaction void reversal logic.

### Phase 3: Auth, Dashboard & Student Management
* **PIN Authentication:** Salted SHA-256 PIN validation for Admin and Viewer roles with dynamic 5-minute auto-lock inactivity listener.
* **Executive Dashboard:** Inflow KPI cards (Today, Month, Active Students, Unpaid Arrears) with school filter toggle.
* **Student Management:** Roster with school filters, student registration form with Auto-NIS preview, and student profile detail screen.
* **Dapodik Parser & Bulk Import:** Excel/CSV parser with deduplication by NISN and automatic class-to-school grade resolution.

### Phase 4: POS Checklist Cashier & Allocation Engine
* **Tab 1 (Unpaid Bills Checklist):** Reactive checklist of `tagihan_item` where `is_lunas == 0`, inline partial payment input with real-time overpayment prevention.
* **Tab 2 (Payment History):** Chronological transaction list with VALID vs VOID status badges and action sheet.
* **Atomic Checkout:** Writes transaction header, allocations, item updates, and audit trail in a single database transaction.

### Phase 5: Hardware & Output Adapters
* **Unified Receipt Model:** Typed `ReceiptModel` assembled by `ReceiptModelFactory`.
* **ESC/POS 58mm Thermal Printer:** Bluetooth adapter with connect, scan, disconnect, and raw ESC/POS formatting.
* **WhatsApp A5 PDF Generator:** Styled Indonesian receipt layout ready for instant digital sharing.

### Phase 6: Isolated Cloud Backup & Drive v3 Adapter
* **Fail-Silent Contract:** Isolated behind abstract `BackupService` interface. Network timeouts or OAuth errors never throw or block local workflows.
* **Local Archiver:** Compresses SQLite database to `.zip` in Android `Downloads` directory.
* **WAL Checkpoint:** Executes `PRAGMA wal_checkpoint(FULL);` before compression to guarantee all committed transactions are captured.
* **Google Drive v3 Cloud Adapter:** Silent OAuth sign-in and automated folder creation (`SIAK-ILMI-Backups`).

### Phase 7: Audit, Hardening & Quality Assurance
* **Full Static Analysis:** Clean `flutter analyze` exit code 0 (0 errors, 0 warnings, 0 lints).
* **Automated Test Suite:** 15/15 tests passing across unit and integration test suites:
  * AC-01: Offline POS execution
  * AC-02: Auto-NIS structure `[YY][SchoolCode][Sequence]`
  * AC-03: Dapodik file parsing and deduplication
  * AC-04: Atomic multi-item payment transactions
  * AC-05: Real-time arrears and installment accuracy
  * AC-06: Hardcopy snapshot immutability against master tariff changes
  * AC-07: Offline fail-silent backup generation
  * EC-01..EC-04: Overpayment prevention, void reversals, and airplane mode operation.
