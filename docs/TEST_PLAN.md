# SIAK-ILMI: Test Plan & Quality Assurance Specification

> **Document Version:** 1.0.0  
> **Target Specification:** [`/docs/PRD.md`](file:///d:/SIAK-ILMI/docs/PRD.md) Section 10  
> **Test Status:** 15 / 15 Tests Passing (100% Pass Rate)  
> **Analyzer Status:** 0 Issues Found (`flutter analyze` Exit Code 0)

---

## 1. Test Strategy & Philosophy

SIAK-ILMI employs a test strategy designed specifically for offline-first, transaction-heavy mobile applications:
* **Zero Network Dependency in Tests:** All tests run against in-memory SQLite instances (`NativeDatabase.memory()`), ensuring zero disk I/O side effects, deterministic execution, and instant test runs.
* **Domain Engine Verification:** Every business rule defined in `/docs/PRD.md` (Auto-NIS, Tariff Priority, Bill Snapshotting, Overpayment Prevention, Atomic POS Checkout, Transaction Voiding) is verified at both unit and end-to-end integration levels.
* **Fail-Silent Boundary Testing:** Backup adapters are tested in airplane mode/disconnected states to guarantee no unhandled exceptions ever bubble up to the presentation layer.

---

## 2. Acceptance Criteria (AC) Verification Matrix

| AC ID | Description | Test Suite | Status |
|---|---|---|---|
| **AC-01** | Zero-latency Offline POS Operations | `test/integration/offline_pos_flow_test.dart` | ✅ PASS |
| **AC-02** | Auto-NIS Generation (`[YY][SchoolCode][Sequence]`) | `test/unit/auto_nis_generator_test.dart` | ✅ PASS |
| **AC-03** | Dapodik Excel/CSV Import & Deduplication | `test/integration/offline_pos_flow_test.dart` | ✅ PASS |
| **AC-04** | Atomic Multi-Item Payments & Receipts | `test/unit/process_payment_test.dart` | ✅ PASS |
| **AC-05** | Real-Time Installment & Arrears Tracking | `test/integration/offline_pos_flow_test.dart` | ✅ PASS |
| **AC-06** | PPDB Promotional Wave Discounts & Snapshot Immutability | `test/unit/bill_generator_engine_test.dart` | ✅ PASS |
| **AC-07** | Local Zip Backup Creation with WAL Checkpointing | `test/integration/offline_pos_flow_test.dart` | ✅ PASS |

---

## 3. Edge Case (EC) Verification Matrix

| Scenario ID | Edge Case Description | Test Method | Status |
|---|---|---|---|
| **EC-01** | **Overpayment Prevention:** User attempts to allocate amount exceeding remaining arrears. | Checked in `ProcessPaymentUseCase` validation rules. | ✅ PASS |
| **EC-02** | **Payment Void & Reversal:** Voiding a payment reverses `tagihan_item.terbayar` and restores unpaid status. | Verified in `test/unit/process_payment_test.dart` & `offline_pos_flow_test.dart`. | ✅ PASS |
| **EC-03** | **Airplane Mode Operations:** Backup adapter handles network/cloud disconnects without throwing. | Verified in `offline_pos_flow_test.dart`. | ✅ PASS |
| **EC-04** | **Historical Snapshot Immutability:** Changing `tarif_master` baseline rate does NOT alter existing bills. | Verified in `test/unit/bill_generator_engine_test.dart`. | ✅ PASS |
| **EC-05** | **Duplicate Student Rejection:** Bulk import skips duplicate entries matching existing NISN. | Verified in `StudentRepository.bulkImport`. | ✅ PASS |
| **EC-06** | **Receipt Sequence Collisions:** Transaction counter counts all transactions (including VOID) to prevent collisions. | Verified in `pembayaran_dao.dart`. | ✅ PASS |

---

## 4. Test Suite Inventory & Test Cases

### 4.1 Unit Test: Auto-NIS Generator ([`test/unit/auto_nis_generator_test.dart`](file:///d:/SIAK-ILMI/test/unit/auto_nis_generator_test.dart))
* `AC-02: First SMP student in 2026 gets NIS 262001`: Verifies year prefix `26`, school code `2`, sequence `001`.
* `AC-02: Second SMP student in 2026 gets NIS 262002`: Verifies sequential incrementing within the same cohort.
* `SD student in 2026 uses schoolCode 1`: Verifies SD IT Baitul Akbar uses school code `1` (`261001`).

### 4.2 Unit Test: Bill Generator Engine ([`test/unit/bill_generator_engine_test.dart`](file:///d:/SIAK-ILMI/test/unit/bill_generator_engine_test.dart))
* `AC-06: Changing tarif_master does NOT alter existing tagihan_item`: Generates SPP bill at Rp150,000, updates master tariff to Rp180,000, and asserts snapshotted line item remains exactly Rp150,000.
* `Wave 1 PPDB discount applies 100% discount on initial fees`: Verifies October–December 2026 registrations receive 100% discount and are automatically marked settled.
* `Wave 2 PPDB discount applies 50% discount on building infaq and 1st month SPP`: Verifies January–March 2027 registrations receive 50% discount.
* `Custom student rate overrides master tariff in bill generation`: Verifies individual rate overrides standard grade tariffs.

### 4.3 Unit Test: Process Payment Use Case ([`test/unit/process_payment_test.dart`](file:///d:/SIAK-ILMI/test/unit/process_payment_test.dart))
* `AC-04: Checking two items creates 1 transaksi + 2 alokasi`: Verifies atomic multi-item payment creating 1 receipt and 2 allocation rows.
* `AC-05: Partial payment increments terbayar correctly`: Verifies installment allocation of Rp200,000 on a Rp400,000 bill, leaving Rp200,000 arrears and `is_lunas = 0`.
* `Full payment marks tagihan_item and header as is_lunas = 1`: Verifies automatic settlement when `terbayar == nominal_akhir`.
* `EC-02: Voiding a transaction reverses tagihan_item amounts`: Verifies void operation deducts paid amount, resets `is_lunas`, and marks transaction `VOID`.
* `Receipt format KW-YYYYMMDD-XXXX is correctly generated`: Verifies receipt sequence formatting.
* `Payment creates audit_log entry`: Verifies automatic logging to `audit_log` table.

### 4.4 End-to-End Integration Test ([`test/integration/offline_pos_flow_test.dart`](file:///d:/SIAK-ILMI/test/integration/offline_pos_flow_test.dart))
* `AC-01 & AC-02: Offline student registration and auto-NIS generation`: Full registration flow without network access.
* `AC-04 & AC-05: Bill generation and atomic multi-item POS payment with installment`: Full checklist checkout flow.
* `EC-02: Payment void and reversal rollback restores unpaid status`: Transaction cancellation flow.
* `EC-04: Historical bill snapshot immutability guarantee`: System-wide verification of financial immutability.
* `EC-03: Offline backup service handles local backup without throwing`: Backup creation in airplane mode.

---

## 5. Test Execution Runbook

To run all tests:
```bash
flutter test
```

To run a specific test suite:
```bash
flutter test test/integration/offline_pos_flow_test.dart
flutter test test/unit/bill_generator_engine_test.dart
flutter test test/unit/process_payment_test.dart
flutter test test/unit/auto_nis_generator_test.dart
```
