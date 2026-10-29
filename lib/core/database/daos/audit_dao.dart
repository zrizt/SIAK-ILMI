import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/audit_log_table.dart';

part 'audit_dao.g.dart';

@DriftAccessor(tables: [AuditLog])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  /// Inserts an audit log entry.
  Future<int> log({
    required String userRole,
    required String actionType,
    required String entityAffected,
    int? entityId,
    required String timestampIso,
    String? details,
  }) =>
      into(auditLog).insert(
        AuditLogCompanion.insert(
          userRole: userRole,
          actionType: actionType,
          entityAffected: entityAffected,
          entityId: Value(entityId),
          timestampIso: timestampIso,
          details: Value(details),
        ),
      );

  /// Fetches recent audit log entries (latest 100).
  Future<List<AuditLogData>> getRecentLogs({int limit = 100}) =>
      (select(auditLog)
            ..orderBy([(a) => OrderingTerm.desc(a.id)])
            ..limit(limit))
          .get();

  /// Watches the audit log stream for a specific entity.
  Stream<List<AuditLogData>> watchLogsByEntity(
          String entityAffected, int entityId) =>
      (select(auditLog)
            ..where(
              (a) =>
                  a.entityAffected.equals(entityAffected) &
                  a.entityId.equals(entityId),
            )
            ..orderBy([(a) => OrderingTerm.desc(a.id)]))
          .watch();
}
