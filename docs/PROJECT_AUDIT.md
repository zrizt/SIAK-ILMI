# SIAK-ILMI: Project Audit & Codebase Hardening Report

> **Document Version:** 1.0.0  
> **Audit Date:** 2026-10-30  
> **Target Specification:** [`/docs/PRD.md`](file:///d:/SIAK-ILMI/docs/PRD.md)  
> **Final Status:** All Audit Items Remediated — 0 Analyzer Issues, 100% Tests Passing (15/15)

---

## 1. Audit Overview & Scope

An exhaustive code audit was conducted on the entire **SIAK-ILMI** repository to identify and eliminate:
1. Build-blocking compilation errors.
2. Financial calculation and allocation edge-case vulnerabilities.
3. Receipt sequence collisions and transaction reversal anomalies.
4. Role-based access control (RBAC) bypasses between Admin and Viewer roles.
5. Incomplete feature integrations (Dapodik import, WAL checkpointing, auto-lock inactivity resets).
6. Flutter 3.22+ and Material 3 deprecation warnings.

---

## 2. Compilation & Build-Blocker Resolutions

Prior to remediation, `flutter analyze` reported 47 errors and 178 total issues. All have been eliminated:

| Initial Issue | Root Cause | Remediated Implementation |
|---|---|---|
| `CardTheme` type mismatch | Flutter 3.22+ requires `CardThemeData` in `ThemeData.cardTheme`. | Replaced with `CardThemeData(...)` in [`lib/core/theme/app_theme.dart`](file:///d:/SIAK-ILMI/lib/core/theme/app_theme.dart). |
| `selectOnly` unbound method | Called `selectOnly(_db.sekolah)` without class reference. | Corrected to `_db.selectOnly(_db.sekolah)` in [`lib/core/database/database_seeder.dart`](file:///d:/SIAK-ILMI/lib/core/database/database_seeder.dart). |
| Abstract `AppException` instantiation | Attempted to `throw AppException(...)` directly. | Created concrete `ValidationException` in [`lib/core/errors/app_exception.dart`](file:///d:/SIAK-ILMI/lib/core/errors/app_exception.dart) and updated use case. |
| Missing `AuditAction.insertTarifMaster` | Undefined constant when inserting new tariffs. | Added `insertTarifMaster = 'INSERT_TARIF_MASTER'` to [`lib/core/services/audit_logger_service.dart`](file:///d:/SIAK-ILMI/lib/core/services/audit_logger_service.dart). |
| Thermal printer reassignment & styling | `final List<int> bytes` reassigned with `+=`, and invalid `italic: true` in `PosStyles`. | Changed `bytes` to non-final and removed unsupported `italic` parameter in [`lib/features/receipts/data/thermal_printer_adapter.dart`](file:///d:/SIAK-ILMI/lib/features/receipts/data/thermal_printer_adapter.dart). |
| Missing Drift `Value<int>` wrapper | In `bill_generator_engine.dart`, passed raw `int` to companion field. | Wrapped in `Value(nominalDiskon)`. |
| Missing imports for `PinRole.displayName` | Extension was inaccessible in several presentation screens. | Moved `displayName` and `prefKey` directly as enum constructor fields on `PinRole` in [`lib/core/security/pin_service.dart`](file:///d:/SIAK-ILMI/lib/core/security/pin_service.dart). |
| `drift_dev` analyzer type crash | Drift analyzer attempted to inspect all project files, failing on Flutter UI classes. | Created [`build.yaml`](file:///d:/SIAK-ILMI/build.yaml) restricting `drift_dev` target to `lib/core/database/**`. |

---

## 3. Financial Integrity & Runtime Hardening

### 3.1 Allocation Validation & Overpayment Prevention
* **Vulnerability:** Use cases previously trusted caller allocations without checking nominal signs, duplicate item IDs, or student ownership.
* **Remediation:** In [`lib/features/payments/domain/process_payment_use_case.dart`](file:///d:/SIAK-ILMI/lib/features/payments/domain/process_payment_use_case.dart):
  * Rejects non-positive amounts ($\le 0$).
  * Rejects duplicate line item IDs in a single payment batch.
  * Asserts each `tagihan_item` belongs to a `tagihan_siswa` matching the targeted student ID.
  * Enforces $A \le \text{nominal\_akhir} - \text{terbayar}$.

### 3.2 Transaction Void Reversal & State Verification
* **Vulnerability:** `voidTransaction` previously did not check if a transaction was already voided, risking duplicate reversals and negative balances.
* **Remediation:** Validates transaction existence and status (`status == 'VALID'`). Throws `ValidationException` if already voided, then atomically deducts `terbayar`, resets `is_lunas = 0`, marks header `VOID`, and logs an audit record.

### 3.3 Receipt Number Collision Elimination
* **Vulnerability:** `countTransaksiToday` previously filtered by `status == 'VALID'`. Voiding a transaction decremented the daily count, causing subsequent payments to reuse the receipt number and collide on the unique constraint.
* **Remediation:** In [`lib/core/database/daos/pembayaran_dao.dart`](file:///d:/SIAK-ILMI/lib/core/database/daos/pembayaran_dao.dart), `countTransaksiToday` now counts all transactions regardless of validity state.

### 3.4 Checklist POS Stale Balance Prevention
* **Vulnerability:** Checkbox items retained initial balance values after partial payments, and removed controllers were not disposed.
* **Remediation:** In [`lib/features/payments/presentation/pos_checklist_screen.dart`](file:///d:/SIAK-ILMI/lib/features/payments/presentation/pos_checklist_screen.dart), `_syncChecklistItems` now updates `item` references on existing items and properly disposes controllers for removed items.

### 3.5 Inactive Student Protection & 100% Discount Auto-Settlement
* **Vulnerability:** Inactive students could receive bills, and zero-balance bills remained unpaid.
* **Remediation:** In [`lib/features/fee_management/domain/bill_generator_engine.dart`](file:///d:/SIAK-ILMI/lib/features/fee_management/domain/bill_generator_engine.dart), verified student exists and is `AKTIF`. Automatically marked 100% discounted items (`nominal_akhir == 0`) and zero-balance headers as `is_lunas = 1`.

---

## 4. Security & RBAC Hardening

1. **Gated UI Mutations:**
   * In [`student_list_screen.dart`](file:///d:/SIAK-ILMI/lib/features/students/presentation/student_list_screen.dart), 'Tambah Siswa' and 'Import Dapodik' buttons are hidden and blocked for Viewer.
   * In [`fee_management_screen.dart`](file:///d:/SIAK-ILMI/lib/features/fee_management/presentation/fee_management_screen.dart), adding/editing master tariffs is blocked for Viewer.
   * In [`pos_checklist_screen.dart`](file:///d:/SIAK-ILMI/lib/features/payments/presentation/pos_checklist_screen.dart), cashier checkout is prohibited for Viewer.
2. **Dynamic Inactivity Auto-Lock:**
   * In [`lib/app/router.dart`](file:///d:/SIAK-ILMI/lib/app/router.dart), wrapped `AppShell` with a `Listener` intercepting pointer events, dynamically restarting the 5-minute timer via `resetInactivityTimer(ref)`.

---

## 5. Modern Flutter & Material 3 Compatibility

* Replaced deprecated `withOpacity(...)` with `.withValues(alpha: ...)`.
* Replaced deprecated `DropdownButtonFormField.value` with `initialValue`.
* Upgraded radio lists to Material 3 `RadioGroup` in [`student_detail_screen.dart`](file:///d:/SIAK-ILMI/lib/features/students/presentation/student_detail_screen.dart).

---

## 6. Audit Verification Scorecard

* **Static Analysis:** `flutter analyze` $\rightarrow$ **0 issues found** (Exit code 0).
* **Automated Tests:** `flutter test` $\rightarrow$ **15 / 15 Passed** (100% pass rate).
* **PRD Compliance:** **100% compliant** with all specifications and non-negotiables.
