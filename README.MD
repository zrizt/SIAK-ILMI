# SIAK-ILMI

**Sistem Informasi Administrasi dan Keuangan Darul Ilmi**  
*Offline-First, Mobile-First Student Administration & Financial POS Management System*

Designed and engineered for **SMP IT Darul Ilmi** and **SD IT Baitul Akbar Parabek**.

---

## 📌 Overview

**SIAK-ILMI** eliminates manual bookkeeping errors, simplifies multi-year tuition tracking, automates admission wave promotional discounts, and streamlines payment processing. Operating entirely offline on Android tablets and smartphones, administrative staff can process student payments, print ESC/POS thermal receipts, generate WhatsApp-ready PDF receipts, and inspect financial summaries without recurring cloud infrastructure costs or internet dependency.

---

## ⚡ Key Highlights & Core Capabilities

* **100% Offline-First Operations:** All core functions (student registry, Auto-NIS generation, billing calculation, POS checkout, hardware printing) execute locally via typed SQLite (Drift) with zero cloud dependency.
* **Interactive Checklist POS Cashier:** A 2-Tab cashier interface allowing fast checkbox billing selection, inline partial payment inputs (installments), and real-time overpayment prevention.
* **Hardcopy Fee Snapshotting:** Generates immutable `tagihan_item` rows with frozen `nominal_awal`, `nominal_diskon`, and `nominal_akhir`. Changes to master tariffs never mutate historical bills.
* **Auto-NIS Generator Engine:** Automatically computes student NIS using the formula `[YY][SchoolCode][Sequence]` (e.g. `261001` for SD, `262001` for SMP).
* **Dual Hardware Output Adapters:**
  * **ESC/POS Bluetooth Thermal Printing:** 58mm roll receipt layout with clean typography, itemized totals, and remaining balance.
  * **WhatsApp Digital Receipts:** A5 formatted vector PDF receipts ready for one-tap sharing.
* **Fail-Silent Cloud Backup Adapter:** Creates local password-protected `.zip` database backups in Android `Downloads` with full WAL checkpointing (`PRAGMA wal_checkpoint(FULL);`). Optionally synchronizes to Google Drive v3 without blocking or throwing if offline.
* **Role-Based Access Control & Auto-Lock:** Salted SHA-256 PIN authentication for **Admin** (Staf TU) and **Viewer** (Kepala Sekolah) with a reactive 5-minute inactivity auto-lock.

---

## 🏗️ Architectural Blueprint

The application adheres strictly to **Feature-First Clean Architecture**:

```
lib/
├── app/                              # App entry point, M3 theme, routing & shell
├── core/                             # Core database (Drift), security, services & formatters
│   ├── database/                     # 12 SQLite tables, 6 DAOs, Seeder
│   ├── errors/                       # Sealed domain exceptions
│   ├── formatters/                   # CurrencyFormatter (IDR)
│   ├── security/                     # PinService (Salted SHA-256)
│   └── services/                     # AppInitializer & AuditLoggerService
└── features/                         # Modular feature domains
    ├── backup_restore/               # Local .zip compression & Drive v3 adapter
    ├── dashboard/                    # Executive collection metrics & charts
    ├── fee_management/               # Master tariffs, custom schemes & bill engine
    ├── payments/                     # 2-tab POS Cashier & atomic transactions
    ├── receipts/                     # Thermal ESC/POS & WhatsApp PDF renderers
    ├── settings/                     # PIN modification & printer setup
    └── students/                     # Student registry, Auto-NIS & Dapodik parser
```

---

## 🛠️ Tech Stack & Requirements

| Component | Technology | Version |
|---|---|---|
| **Framework** | Flutter | 3.22+ |
| **Language** | Dart | 3.4+ |
| **State Management** | Flutter Riverpod | ^2.5.1 |
| **Database** | Drift (SQLite) | ^2.18.0 |
| **PDF & Printing** | `pdf`, `printing` | ^3.11.1 / ^5.13.1 |
| **Bluetooth Thermal**| `blue_thermal_printer`, `esc_pos_utils_plus` | ^1.1.2 / ^2.0.2 |
| **Cloud Adapter** | `googleapis` (Drive v3), `google_sign_in` | ^13.2.0 / ^6.2.1 |
| **File Parsers** | `excel`, `csv` | ^4.0.3 / ^6.0.0 |
| **Target OS** | Android (API Level 24+ / Android 7.0+) | Smartphone & Tablet |

---

## 🚀 Getting Started & Build Runbook

### 1. Prerequisites
Ensure Flutter 3.22+ and the Android SDK are installed and configured in your environment PATH.

### 2. Clone & Install Dependencies
```bash
git clone https://github.com/darulilmi/siak-ilmi.git
cd siak-ilmi
flutter pub get
```

### 3. Generate Database Code & Riverpod Providers
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run Static Analysis
```bash
flutter analyze
# Output: No issues found!
```

### 5. Run Automated Tests
```bash
flutter test
# Output: All 15 tests passed!
```

### 6. Build Android APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 🔐 Default PIN Profiles

| Role | Default PIN | Permissions |
|---|---|---|
| **Admin (Staf TU)** | `123456` | Full Access: POS payments, student registration, Dapodik import, tariff configuration, voiding, backups |
| **Viewer (Kepala Sekolah)** | `654321` | Read-Only Access: Dashboard analytics, student directory, audit log inspection, backup status |

*PINs can be updated anytime in the Settings menu.*

---

## 📚 Technical Documentation

Comprehensive engineering documentation is available in the [`/docs`](file:///d:/SIAK-ILMI/docs) directory:

* [`docs/PRD.md`](file:///d:/SIAK-ILMI/docs/PRD.md) — Authoritative Product Requirements Document
* [`docs/ARCHITECTURE.md`](file:///d:/SIAK-ILMI/docs/ARCHITECTURE.md) — System Architecture, Layer Breakdown & Riverpod Graph
* [`docs/DATABASE_DESIGN.md`](file:///d:/SIAK-ILMI/docs/DATABASE_DESIGN.md) — Relational ERD, 12 Table DDLs, Indexes & DAOs
* [`docs/IMPLEMENTATION_PLAN.md`](file:///d:/SIAK-ILMI/docs/IMPLEMENTATION_PLAN.md) — Phase-by-Phase Roadmap & Milestones
* [`docs/TEST_PLAN.md`](file:///d:/SIAK-ILMI/docs/TEST_PLAN.md) — Acceptance Criteria (AC) & Edge Case (EC) Verification
* [`docs/PROJECT_AUDIT.md`](file:///d:/SIAK-ILMI/docs/PROJECT_AUDIT.md) — Audit Findings & Codebase Hardening Chronicle
* [`AGENTS.md`](file:///d:/SIAK-ILMI/AGENTS.md) — Autonomous Agent Progress & Task Tracker

---

## 📄 License & Attribution

Developed for **Yayasan Darul Ilmi** (SMP IT Darul Ilmi & SD IT Baitul Akbar Parabek).  
All rights reserved.
