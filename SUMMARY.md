# SIAK-ILMI Inspection Summary

Read-only inspection complete. No files were changed, and `flutter analyze`, `flutter test`, and a build were not run because those can write caches/artifacts. A prior debug APK exists at `build/app/outputs/flutter-apk/app-debug.apk`.

## Verified strengths

- Clean feature-first structure with 12 Drift tables, 6 DAOs, seeded schools/classes/fee categories, Auto-NIS, atomic payments, allocation validation, void reversal, bill snapshotting, receipt adapters, and WAL checkpointing.
- 15 test cases exist and the project has compiled previously.

## High-risk findings

- **Auto-lock can be bypassed:** `lib/app/router.dart:14` only swaps the base page when the session is cleared. Pushed screens/dialogs remain on top, and `Listener` only wraps `DashboardScreen` (`router.dart:17`), so pushed screens do not reset inactivity. A locked screen can remain visible.
- **RBAC is not enforced consistently:** Viewer gets "Tambah Siswa" and "Backup Data" quick actions (`dashboard_screen.dart:318`), `StudentFormScreen` has no role check and hardcodes `createdBy: 'Admin'` (`student_form_screen.dart:56`), and backup actions are available from Settings without an admin guard. This contradicts the PRD RBAC matrix.
- **Duplicate tariff data can break billing:** `TarifMaster` and `SkemaPembayaranSiswa` lack composite unique constraints (`tarif_master_table.dart`, `skema_pembayaran_siswa_table.dart`). The DAO uses `insertOnConflictUpdate` (`tarif_dao.dart:30`), which inserts duplicates because there is no conflict target; later `getSingleOrNull` calls can throw. The EC-04 test itself inserts a duplicate master tariff.
- **Backup is not production-ready:** the screen is named "Backup & Restore" but there is no restore flow; backups are plain ZIPs despite the README claiming password protection; the dead `BackupServiceImpl` still contains `TODO`/`UnimplementedError`; no OAuth setup is documented. Both adapters write to public `Download` via `parent.parent.parent.parent` paths (`drive_backup_adapter.dart:223`), which will likely fail under scoped storage. `getLocalBackupPath()` is also called unguarded in `BackupRestoreScreen.initState`.
- **Dapodik import is effectively unusable on modern Android:** it asks the user to type a path like `/sdcard/Download/dapodik.xlsx` (`student_list_screen.dart:104`) instead of using a SAF file picker, and no file-picker dependency is present.
- **PPDB discounts are not wired in:** `BillGeneratorEngine.calculateWaveDiscount` hardcodes discount amounts (`bill_generator_engine.dart:152`), violating the PRD's "no hardcoded fees" rule, and `GenerateBillScreen` always passes `nominalDiskon: 0` (`generate_bill_screen.dart:95`).
- **POS checklist has a rebuild loop:** `addPostFrameCallback` unconditionally calls `setState` on every build (`pos_checklist_screen.dart:323`), scheduling frames continuously while the unpaid tab is visible.
- **Missing required UI:** no transaction-void action, no audit-log inspection screen, no restore workflow, no fee-override approval, and no student profile edit despite the `Edit Siswa` label.

## Other issues

- Duplicate bills for the same student/period are possible; `tagihan_siswa` has no unique constraint and bill generation performs no check.
- Default PINs are known (`123456`/`654321`), with no forced change or rate limiting.
- PDF receipts depend on runtime Google Fonts; they fall back to Helvetica on failure, so styling is not deterministic offline.
- Release builds use the debug signing key (`android/app/build.gradle:32`).
- Tests do not cover Dapodik import, RBAC, duplicate constraints, real backup ZIP creation, or the route-lock behavior; EC-03 only verifies that a `BackupResult` is returned.
- README/AGENTS claims of "100% PRD compliant," password-protected backups, restore, audit inspection, and 0 analyzer issues are not supported by the code. Toolchain docs also say Flutter 3.22+, while `.dart_tool/version` is `3.47.8`.

## Recommended order

If edits are later authorized: fix RBAC/auto-lock and data constraints first, then backup/import, then the missing void/audit/edit features, then run `flutter analyze` and `flutter test`.
