import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/audit_dao.dart';

final auditLoggerProvider = Provider<AuditLoggerService>(
  (ref) => AuditLoggerService(
    ref.watch(appDatabaseProvider),
  ),
);

/// Constants for action_type values in the audit_log table.
class AuditAction {
  AuditAction._();

  static const insertPayment = 'INSERT_PAYMENT';
  static const voidTransaction = 'VOID_TRANSACTION';
  static const insertSiswa = 'INSERT_SISWA';
  static const updateSiswa = 'UPDATE_SISWA';
  static const updateSiswaStatus = 'UPDATE_SISWA_STATUS';
  static const insertTagihan = 'INSERT_TAGIHAN';
  static const upsertCustomRate = 'UPSERT_CUSTOM_RATE';
  static const deleteCustomRate = 'DELETE_CUSTOM_RATE';
  static const insertTarifMaster = 'INSERT_TARIF_MASTER';
  static const updateTarifMaster = 'UPDATE_TARIF_MASTER';
  static const databaseBackup = 'DATABASE_BACKUP';
  static const databaseRestore = 'DATABASE_RESTORE';
  static const pinChange = 'PIN_CHANGE';
}

/// Centralized service for writing to the local audit_log table.
/// All write operations in the app MUST call this service.
class AuditLoggerService {
  AuditLoggerService(this._db);

  final AppDatabase _db;
  late final AuditDao _dao = AuditDao(_db);

  Future<void> log({
    required String userRole,
    required String actionType,
    required String entityAffected,
    int? entityId,
    String? details,
  }) =>
      _dao.log(
        userRole: userRole,
        actionType: actionType,
        entityAffected: entityAffected,
        entityId: entityId,
        timestampIso: DateTime.now().toIso8601String(),
        details: details,
      );
}
