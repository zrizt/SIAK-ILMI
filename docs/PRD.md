# Final Product Requirements Document (PRD)
## SIAK-ILMI (Sistem Informasi Administrasi dan Keuangan Darul Ilmi)
**Architectural Blueprint for Agentic AI Development (< 14 Days Execution)**

---

## 1. Document & System Metadata

| Parameter | Technical / Operational Specification |
| :--- | :--- |
| **Product Name** | **SIAK-ILMI** (*Sistem Informasi Administrasi dan Keuangan Darul Ilmi*) |
| **Document Version** | 3.0.0 (Final Production Blueprint) |
| **Target Institutions** | SMP IT Darul Ilmi & SD IT Baitul Akbar Parabek |
| **Primary Target Platform** | Mobile Android (Smartphone & Tablet) |
| **Core Framework** | Flutter (Dart) |
| **Architecture Pattern** | Feature-First Clean Architecture (Presentation, Domain, Data) |
| **Local Database Engine** | SQLite via `drift` or `sqflite` (Atomic Transactions) |
| **Sync & Backup Model** | Offline-First with Loosely Coupled Google Drive API Adapter & Fail-Silent Local Fallback |
| **Delivery Constraint** | Strict < 14 Days Development Window via Agentic AI Orchestration |

---

## 2. Agentic AI Execution Directives

To guarantee delivery within the 14-day timeline, AI Agents must strictly adhere to the following development rules:

1. **Opinionated Tech Stack Selection:**
   * **State Management:** `flutter_riverpod` or `flutter_bloc`.
   * **Database & Persistence:** `drift` or `sqflite` for SQLite; `path_provider` for Android storage access.
   * **Parsers:** `excel` and `csv` packages for Dapodik student record imports.
   * **Printing & PDF:** `pdf` for digital receipt rendering; `blue_thermal_printer` or ESC/POS Bluetooth drivers for thermal printers.
   * **Backup Adapter:** `google_sign_in` and `googleapis` (Drive v3 API).
2. **Strict Component Decoupling:**
   * The core application (student directory, billing calculation, transaction processing, receipt generation) MUST function 100% offline with zero reliance on cloud/network modules.
   * The Google Drive Backup Adapter MUST be implemented behind an abstract `BackupService` interface. Network timeouts, OAuth token expirations, or API failures must NEVER bubble up to or interrupt core financial transactions.
3. **Data-Driven Logic over Hardcoding:**
   * All tariffs, promo waves, and custom rates are stored in and driven by relational SQLite tables. Do not hardcode fee values inside Dart logic.

---

## 3. Product Vision & Executive Summary

SIAK-ILMI is a mobile-first student administration and financial management system designed for micro-scale educational institutions (SMP IT Darul Ilmi and SD IT Baitul Akbar Parabek).

The platform eliminates manual bookkeeping errors, simplifies multi-year tuition tracking, automates wave-based admission discounts, and streamlines payment processing. By pairing an intuitive **Checklist POS Cashier Interface** with an **Offline-First SQLite Database**, staff can process payments, issue thermal receipts, and inspect financial summaries instantly without internet access or recurring cloud infrastructure fees.

---

## 4. User Personas & Local Security Matrix

### 4.1 User Personas
1. **Administrative Staff (*Staf Tata Usaha* — Admin Profile):**
   * **Role:** Manages student records, imports Dapodik files, configures custom tariffs, processes payments using the Checklist POS, issues receipts, and triggers database backups.
   * **Key Need:** High-speed transaction entry without manual calculation or typing errors.
2. **Principal / Foundation Chairman (*Kepala Sekolah / Ketua Yayasan* — Viewer/Approver Profile):**
   * **Role:** Monitors real-time cash inflows, inspects active student rosters across SD/SMP levels, and approves fee customizations.
   * **Key Need:** Clear executive dashboards, transparent financial audit trails, and zero risk of accidental data modification.

### 4.2 Local Security & RBAC Matrix
* **Authentication Method:** Local 6-digit numeric PIN (No server-side auth).
* **PIN Profiles:** Distinct "Admin" PIN and "Viewer" PIN.
* **Audit Trail Mandate:** Every transaction creation, manual tariff override, or void operation automatically logs `timestamp`, `user_role`, and `action_type` in a dedicated local audit table.

| Capability / Module | Admin (Staff TU) | Viewer (Principal / Chairman) |
| :--- | :---: | :---: |
| Local 6-Digit PIN Authentication | Full Access | Full Access |
| Dapodik Student Import (`.xlsx` / `.csv`) | Create / Execute | Read-Only |
| Auto-NIS Student Registration | Create / Edit | Read-Only |
| Individual Fee Override Configuration | Create / Update | Review / Approve |
| Checklist POS Payment Processing | Execute Transactions | Read-Only |
| Receipt Printing (Bluetooth ESC/POS & PDF) | Execute | Export PDF |
| Cash Inflow Dashboard & Reports | Full Access | Full Access |
| Database Backup & Drive Synchronization | Execute | View Status |
| Transaction Voiding / Reversals | Admin PIN + Audit Log | Read Audit Log |

---

## 5. Core UI/UX Workflow Paradigms

### 5.1 The 2-Tab Student Detail Screen (Checklist POS)
The cashier module replaces manual text input with an interactive Checklist POS interface:

```
+-----------------------------------------------------------------------+
|  STUDENT DETAIL: Giandra (NIS: 261025 - SD Grade 2)                  |
+---------------------------------------------------+-------------------+
|  [ TAB 1: UNPAID BILLS (POS CHECKLIST) ]          |  TAB 2: HISTORY   |
+---------------------------------------------------+-------------------+
|  Active Arrears Checklist:                                            |
|                                                                       |
|  [X] SPP August 2026 ----------------------------- Rp  150,000      |
|  [X] SPP September 2026 -------------------------- Rp  150,000      |
|  [ ] Building Infaq (Installment 1/2) ------------ Rp  400,000      |
|      └── [✓] Pay Partial Amount: [ Rp 200,000 ]                       |
|                                                                       |
|-----------------------------------------------------------------------|
|  TOTAL PAYMENT: Rp 500,000                                            |
|  Payment Method: (o) Cash   ( ) Bank Transfer                         |
|                                                                       |
|  [ CONFIRM & PRINT RECEIPT ]                                          |
+-----------------------------------------------------------------------+
```

* **Tab 1: Unpaid Bills (POS Checklist):**
  * Renders all active `tagihan_item` rows where `is_lunas = false`.
  * Checking an item adds its `nominal_akhir - terbayar` to the Total Payment.
  * For major fees (e.g., Building Infaq), tapping "Pay Partial" expands an input box to specify an installment amount.
  * Tapping **Confirm & Print Receipt** processes the payment atomically.
* **Tab 2: Payment History:**
  * Renders a chronological list of completed `pembayaran_transaksi` records.
  * Offers options to reprint thermal receipts or export PDF proofs for WhatsApp delivery.

### 5.2 Operator Customization Over Complex Discount Rules
Rather than running complex dynamic discount logic on every render, the system utilizes **Individual Override Configuration**:
* **Standard Case:** System pulls baseline rate from `tarif_master`.
* **Custom Case:** If a student requires a custom rate (e.g., student "Giandra" with a custom SPP of Rp200,000), the operator inputs this override into `skema_pembayaran_siswa`.
* **Resolution Order:** `skema_pembayaran_siswa` (Custom) > `tarif_master` (Standard).
* **Bill Generation Snapshotting:** When a bill is created, the effective price is hardcopied into `tagihan_item`. Future master tariff updates will not alter historical or generated bills.

---

## 6. System Architecture & Isolated Backup Design

### 6.1 Clean Architecture Layers
```
+-----------------------------------------------------------------------------------+
|                            PRESENTATION LAYER (FLUTTER)                           |
|   [PIN Auth UI]   [Dapodik Import]   [Checklist POS]   [Dashboard]   [Backup UI]  |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                            DOMAIN LAYER (BUSINESS LOGIC)                          |
|   - Auto-NIS Generator Engine                                                     |
|   - Tariff Priority Resolver (Individual Custom Override > Master Tariff)          |
|   - Billing Snapshot Engine & Partial Payment Allocator                           |
|   - Remaining Arrears & Audit Logger                                              |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                                     DATA LAYER                                    |
|   +------------------------------------+   +----------------------------------+   |
|   |   LOCAL PERSISTENCE (PRIMARY)      |   |  ISOLATED BACKUP (LOOSE COUPLED) |   |
|   | - SQLite (`drift` / `sqflite`)     |   | - Local Archiver (`.zip` to      |   |
|   | - Atomic Transactions              |   |   Android Downloads)             |   |
|   | - File Parsers (`excel` / `csv`)   |   | - Google Drive Adapter           |   |
|   | - ESC/POS Printer & PDF Renderers  |   |   (`google_sign_in` / `googleapis`|   |
|   +------------------------------------+   +----------------------------------+   |
+-----------------------------------------------------------------------------------+
```

### 6.2 Isolated Backup & Fallback Strategy

```
                          [ Trigger Backup ]
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │  Create Local SQLite .db  │
                    │   Snapshot & Zip Archive  │
                    └─────────────┬─────────────┘
                                  │
                                  ▼
                   ┌─────────────────────────────┐
                   │ Save .zip to Local Storage  │
                   │  (Android Downloads Folder) │
                   └──────────────┬──────────────┘
                                  │
                                  ▼
                     / Is Drive Adapter Active? \
                    <                            >
                     \  And Network Available?  /
                                  │
                         YES      │      NO
              ┌───────────────────┴───────────────────┐
              ▼                                       ▼
   ┌──────────────────────┐               ┌───────────────────────┐
   │ Attempt Upload via   │               │ Skip Cloud Upload.    │
   │ Google Drive API v3  │               │ Local .zip remains    │
   └──────────┬───────────┘               │ safe. Post UI status. │
              │                           └───────────────────────┘
       SUCCESS│
              ├──────────────────────────────┐
              ▼                              ▼
   ┌──────────────────────┐      ┌────────────────────────┐
   │ Log Successful Sync. │      │ FAIL-SILENT CATCH:     │
   │ Complete Operation.  │      │ Catch API/Network Error│
   └──────────────────────┘      │ Keep Local Zip Intact. │
                                 │ Show Warning Snackbar. │
                                 └────────────────────────┘
```

#### Phase 1: Google Drive API v3 (Primary Cloud Attempt)
* **Authentication:** OAuth 2.0 via `google_sign_in` requesting strictly limited scope (`drive.file` / `drive.appdata`).
* **Execution:** Compress local SQLite database into a password-protected `.zip` archive and upload to the school's Google Drive.
* **Fail-Silent Policy:** If OAuth fails, internet is disconnected, or Drive storage is full, the exception is caught silently. The app displays a non-blocking notification: *"Backup saved locally. Drive upload pending network connection."* Core financial features remain 100% operational.

#### Phase 2: Cloud Fallback Strategy (Roadmap if Drive API Proves Unreliable)
* If Google Drive API experiences persistent token degradation or revocation issues during field testing, the isolated `BackupService` adapter can be swapped with zero impact on the core app:
  * **Fallback Option A:** Supabase Storage / Firebase Cloud Storage bucket upload via REST API.
  * **Fallback Option B:** Automated Local Area Network (LAN) WebDAV / FTP transfer to a school local server.

---

## 7. Epic Specifications & Business Logic Formulas

### Epic 1: Security, Local Auth, and Audit Trail

#### F1.1: Local PIN Profile Authentication
* **Specification:** 6-digit PIN login supporting "Admin" and "Viewer" roles.
* **Rules:** Store verifier hashes (e.g., SHA-256 with salt) locally. Lock UI after 5 minutes of inactivity.

#### F1.2: Automatic Audit Trail Logging
* **Specification:** Every write, update, void, or override operation MUST record an entry in `audit_log`.
* **Logged Fields:** `id`, `user_role`, `action_type`, `entity_affected`, `entity_id`, `timestamp_iso`, `details`.

---

### Epic 2: Auto-NIS Generation & Student Management

#### F2.1: Auto-NIS Generation Engine
* **Formula:**
  $$\text{NIS} = [\text{YY}] + [\text{SchoolCode}] + [\text{Sequence}]$$
  * `YY`: 2-digit entry year (e.g., `26` for 2026).
  * `SchoolCode`: `1` for SD IT Baitul Akbar Parabek; `2` for SMP IT Darul Ilmi.
  * `Sequence`: 3-digit auto-incrementing integer padded with zeros (`001` to `999`), scoped per school and year.
  * *Example:* The 25th SD student registered in 2026 receives NIS **`261025`**. The 12th SMP student registered in 2026 receives NIS **`262012`**.

#### F2.2: Dapodik & PPDB Import Parser
* **Specification:** Read `.xlsx` or `.csv` files using `excel`/`csv` packages.
* **Mandatory Column Mapping:** Name, NISN (optional), Gender, Class/Grade, Guardian Phone.
* **Deduplication:** Check incoming `nisn` against existing records. If `nisn` matches, flag row as duplicate and skip auto-insertion.

#### F2.3: Student Status & Lifecycle Management
* **Specification:** Support lifecycle statuses: `AKTIF`, `LULUS`, `PINDAH`, `DROP_OUT`.
* **Rules:** Inactive students (`LULUS`, `PINDAH`, `DROP_OUT`) are excluded from active cashier checklists and new bill generation routines while retaining all historical bills and transaction records.

---

### Epic 3: Master Tariffs, Customization Overrides, and Snapshotting

#### F3.1: Tariff Priority Resolution Logic
When generating a bill for a student and fee category, the system evaluates:

$$\text{Effective Base Tariff} = \begin{cases} \text{nominal\_kustom}, & \text{if } \texttt{skema\_pembayaran\_siswa.nominal\_kustom} \text{ exists} \\ \text{nominal\_standar}, & \text{otherwise (fallback to } \texttt{tarif\_master}\text{)} \end{cases}$$

#### F3.2: PPDB Wave Promotional Discount Matrix (Academic Year 2026/2027)
Promotional discounts are calculated during new student enrollment based on registration dates:

| Registration Date Range | Admission Wave | Registration Fee (*Pendaftaran*) | Building Infaq (*Infaq Gedung*) | 1st Month SPP (*SPP Bulan 1*) |
| :--- | :--- | :--- | :--- | :--- |
| **Oct 1 – Dec 31, 2026** | Wave 1 | **100% Free** (-Rp100,000) | **100% Free** (-Rp400,000) | **100% Free** (-Rp150,000) |
| **Jan 1 – Mar 31, 2027** | Wave 2 | **100% Free** (-Rp100,000) | **50% Discount** (-Rp200,000) | **50% Discount** (-Rp75,000) |
| **Apr 1 – Jun 30, 2027** | Wave 3 | **100% Free** (-Rp100,000) | **50% Discount** (-Rp200,000) | **Normal 100%** (Rp150,000) |

* **Formula:**
  $$\text{nominal\_akhir} = \text{max}\left(0, \text{Effective Base Tariff} - \text{nominal\_diskon}\right)$$

#### F3.3: Bill Generation & Hardcopy Snapshotting (CRITICAL)
When `tagihan_siswa` and `tagihan_item` rows are generated:
1. System resolves `Effective Base Tariff` and applicable `nominal_diskon`.
2. System computes `nominal_akhir`.
3. System writes `nominal_awal`, `nominal_diskon`, and `nominal_akhir` directly into `tagihan_item`.
4. **Snapshot Guarantee:** Modifying `tarif_master` or `skema_pembayaran_siswa` in the future MUST NOT alter existing `tagihan_item` values.

---

### Epic 4: POS Checklist Cashier & Installment Engine

#### F4.1: Checklist Payment Execution
1. Operator selects active student $\rightarrow$ App loads unpaid `tagihan_item` records (`is_lunas = false`).
2. Operator checks boxes for items being paid.
3. For full payments, allocated amount = `nominal_akhir - terbayar`.
4. For partial payments (installments), operator enters partial amount $A$, where $0 < A \le (\text{nominal\_akhir} - \text{terbayar})$.
5. System sums all allocated amounts into `total_bayar`.
6. Tapping **Confirm Payment** executes an **Atomic SQLite Transaction**:
   * Creates one `pembayaran_transaksi` header row.
   * Creates corresponding `alokasi_pembayaran` detail rows linking `transaksi_id` to each `tagihan_item_id`.
   * Increments `terbayar` on each `tagihan_item` by its allocated amount.
   * Updates `tagihan_item.is_lunas = true` if `terbayar == nominal_akhir`.
   * Updates `tagihan_siswa.is_lunas = true` if all child items are settled.

#### F4.2: Remaining Arrears Formula
For any `tagihan_item`, the remaining arrears displayed on UI and receipts is computed as:

$$\text{Remaining Arrears} = \text{nominal\_akhir} - \text{terbayar}$$

---

### Epic 5: Reporting & Receipt Printing

#### F5.1: Dual Receipt Output (ESC/POS Thermal & PDF)
Immediately following a successful payment transaction:
* **ESC/POS Bluetooth Thermal Printing:** Send formatted commands via Bluetooth containing: Institution Name, Receipt Number, Date, Student Name/NIS, Itemized Payment List, Amount Paid per Item, and Remaining Arrears.
* **PDF Digital Receipt Export:** Render a vector PDF document with matching details for one-tap sharing to parents via WhatsApp.

#### F5.2: Executive Cash Inflow Dashboard
* **Metrics Displayed:** Today's Total Collection, This Month's Total Collection, Active Student Count (SD & SMP), Outstanding Arrears Total.
* **Filtering:** Instant toggle between All Units, SD IT Baitul Akbar Parabek, and SMP IT Darul Ilmi.

---

## 8. Final SQLite Database Schema (DDL Blueprint)

AI Agents MUST implement the exact SQLite schema defined below:

```sql
-- 1. School Entity Table
CREATE TABLE sekolah (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_sekolah TEXT NOT NULL,
    kode_sekolah INTEGER NOT NULL UNIQUE, -- 1 for SD, 2 for SMP
    jenjang TEXT NOT NULL                 -- 'SD' or 'SMP'
);

-- 2. Academic Year Table
CREATE TABLE tahun_ajaran (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_ta TEXT NOT NULL,                -- e.g., '2026/2027'
    is_aktif INTEGER NOT NULL DEFAULT 1  -- 1 = True, 0 = False
);

-- 3. Class/Grade Table
CREATE TABLE kelas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sekolah_id INTEGER NOT NULL REFERENCES sekolah(id),
    tingkat INTEGER NOT NULL,             -- 1..6 for SD, 7..9 for SMP
    nama_kelas TEXT NOT NULL
);

-- 4. Fee Categories Table
CREATE TABLE kategori_biaya (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_biaya TEXT NOT NULL,             -- 'SPP', 'Infaq Gedung', 'Pendaftaran', etc.
    tipe TEXT NOT NULL                    -- 'Rutin' or 'Sekali'
);

-- 5. Student Master Table
CREATE TABLE siswa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sekolah_id INTEGER NOT NULL REFERENCES sekolah(id),
    nis TEXT NOT NULL UNIQUE,             -- Auto-generated: e.g., '262015'
    nisn TEXT UNIQUE,                     -- Optional Dapodik NISN
    nama_lengkap TEXT NOT NULL,
    jenis_kelamin TEXT NOT NULL,          -- 'L' or 'P'
    kelas_id INTEGER NOT NULL REFERENCES kelas(id),
    tahun_masuk INTEGER NOT NULL,         -- e.g., 2026
    kontak_wali TEXT,
    status TEXT NOT NULL DEFAULT 'AKTIF'  -- 'AKTIF', 'LULUS', 'PINDAH', 'DROP_OUT'
);

-- 6. Master Tariff Table (Standard Rates)
CREATE TABLE tarif_master (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    kategori_biaya_id INTEGER NOT NULL REFERENCES kategori_biaya(id),
    tingkat INTEGER NOT NULL,             -- Target Grade Level (1..9)
    nominal INTEGER NOT NULL              -- Baseline Price in IDR
);

-- 7. Student Payment Scheme (Operator Customization Overrides)
CREATE TABLE skema_pembayaran_siswa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    siswa_id INTEGER NOT NULL REFERENCES siswa(id),
    kategori_biaya_id INTEGER NOT NULL REFERENCES kategori_biaya(id),
    nominal_kustom INTEGER NOT NULL,       -- Overrides tarif_master
    catatan TEXT
);

-- 8. Student Bill Header Table
CREATE TABLE tagihan_siswa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    siswa_id INTEGER NOT NULL REFERENCES siswa(id),
    periode TEXT NOT NULL,                -- e.g., 'Juli 2026' or 'PPDB 2026/2027'
    is_lunas INTEGER NOT NULL DEFAULT 0   -- 1 = True, 0 = False
);

-- 9. Student Bill Item Detail Table (Checklist & Snapshot Core)
CREATE TABLE tagihan_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tagihan_id INTEGER NOT NULL REFERENCES tagihan_siswa(id) ON DELETE CASCADE,
    kategori_biaya_id INTEGER NOT NULL REFERENCES kategori_biaya(id),
    nama_item TEXT NOT NULL,              -- Snapshotted Title e.g., 'SPP Juli 2026'
    nominal_awal INTEGER NOT NULL,        -- Snapshotted Base Price
    nominal_diskon INTEGER NOT NULL DEFAULT 0, -- Snapshotted Discount
    nominal_akhir INTEGER NOT NULL,       -- Snapshotted Final Net (awal - diskon)
    terbayar INTEGER NOT NULL DEFAULT 0,  -- Accumulated Paid Amount
    is_lunas INTEGER NOT NULL DEFAULT 0   -- 1 = True (when terbayar == nominal_akhir)
);

-- 10. Payment Transaction Header Table
CREATE TABLE pembayaran_transaksi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nomor_kuitansi TEXT NOT NULL UNIQUE,  -- Format: 'KW-YYYYMMDD-XXXX'
    siswa_id INTEGER NOT NULL REFERENCES siswa(id),
    tanggal_bayar TEXT NOT NULL,          -- ISO8601 String e.g. '2026-10-29T10:15:00'
    total_bayar INTEGER NOT NULL,         -- Total Cash Inflow Amount
    metode_bayar TEXT NOT NULL,           -- 'Tunai' or 'Transfer'
    status TEXT NOT NULL DEFAULT 'VALID', -- 'VALID' or 'VOID'
    created_by TEXT NOT NULL              -- 'Admin' or 'Kepala Sekolah'
);

-- 11. Payment Allocation Bridge Table
CREATE TABLE alokasi_pembayaran (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaksi_id INTEGER NOT NULL REFERENCES pembayaran_transaksi(id) ON DELETE CASCADE,
    tagihan_item_id INTEGER NOT NULL REFERENCES tagihan_item(id),
    nominal_dialokasikan INTEGER NOT NULL -- Amount routed to this specific checklist item
);

-- 12. Local Audit Log Table
CREATE TABLE audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_role TEXT NOT NULL,              -- 'Admin' or 'Kepala Sekolah'
    action_type TEXT NOT NULL,            -- 'INSERT_PAYMENT', 'VOID_TRANSACTION', etc.
    entity_affected TEXT NOT NULL,
    entity_id INTEGER,
    timestamp_iso TEXT NOT NULL,
    details TEXT
);

-- INDEXES FOR PERFORMANCE OPTIMIZATION
CREATE INDEX idx_siswa_sekolah ON siswa(sekolah_id);
CREATE INDEX idx_siswa_kelas ON siswa(kelas_id);
CREATE INDEX idx_tagihan_item_tagihan ON tagihan_item(tagihan_id);
CREATE INDEX idx_alokasi_transaksi ON alokasi_pembayaran(transaksi_id);
CREATE INDEX idx_pembayaran_siswa ON pembayaran_transaksi(siswa_id);
```

---

## 9. Edge Cases, Fail-Safe Protocols, and Data Integrity Rules

| Scenario ID | Edge Case Description | System Handling & Protocol |
| :--- | :--- | :--- |
| **EC-01** | **Overpayment Attempt** | The Checklist POS UI enforces validation: Allocated amount $A$ cannot exceed `nominal_akhir - terbayar`. The Confirm button is disabled if $A > \text{Remaining Arrears}$. |
| **EC-02** | **Transaction Voiding / Reversal** | To preserve financial audit trails, transactions are NEVER deleted via `SQL DELETE`. Setting `status = 'VOID'` deducts allocated amounts back from `tagihan_item.terbayar`, resets `is_lunas = 0`, and logs a full audit entry. |
| **EC-03** | **Google Drive OAuth Expiration** | The `BackupService` catches 401/OAuth exceptions silently. Local SQLite `.zip` export completes successfully to device storage; UI shows a subtle warning indicator in the Backup tab. |
| **EC-04** | **Power Loss During Payment Commit** | All payment writes (`pembayaran_transaksi`, `alokasi_pembayaran`, `tagihan_item` updates) are wrapped inside a single atomic SQLite transaction (`db.transaction()`). Uncommitted writes automatically roll back if interrupted. |
| **EC-05** | **Database Restore Conflict** | Database restoration is blocked if there are active, unbacked-up payment transactions created on the current calendar day. |
| **EC-06** | **Master Tariff Modifications** | Updating a baseline rate in `tarif_master` updates future bill generation only. Existing `tagihan_item` records retain their snapshotted nominal values. |

---

## 10. Acceptance Criteria & Verification Checklist for AI Agents

To pass Automated Quality Assurance, the compiled Flutter application must satisfy:

* [ ] **AC-01 (Offline Execution):** Complete workflow (Student Creation $\rightarrow$ Bill Generation $\rightarrow$ Checklist POS Cashier Payment $\rightarrow$ ESC/POS Bluetooth Printing $\rightarrow$ Local Backup) operates with Airplane Mode enabled.
* [ ] **AC-02 (Auto-NIS Integrity):** Creating a new SMP student in 2026 generates NIS `262001`. Creating the next SMP student generates `262002`.
* [ ] **AC-03 (Tariff Override Priority):** Setting a custom rate of Rp200,000 for student "Giandra" results in a generated bill of Rp200,000, while class peers receive the standard Rp150,000 rate from `tarif_master`.
* [ ] **AC-04 (Checklist POS Allocation):** Checking two items (SPP Rp150,000 and Partial Infaq Rp200,000) generates a single `pembayaran_transaksi` of Rp350,000 and two distinct `alokasi_pembayaran` records.
* [ ] **AC-05 (Arrears Accuracy):** After paying Rp200,000 towards a Rp400,000 Building Infaq bill, the receipt and UI display remaining arrears of exactly Rp200,000.
* [ ] **AC-06 (Snapshot Immutability):** Changing `tarif_master` SPP rate from Rp150,000 to Rp180,000 does NOT alter previously generated `tagihan_item` nominals.
* [ ] **AC-07 (Isolated Drive Backup):** Triggering backup with network disconnected successfully creates a password-protected `.zip` file in Android `Downloads` without crashing or throwing unhandled exceptions.

---

**[END OF PRODUCT REQUIREMENTS DOCUMENT]**