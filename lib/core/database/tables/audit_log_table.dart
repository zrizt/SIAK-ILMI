import 'package:drift/drift.dart';

@DataClassName('AuditLogData')
class AuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userRole => text()(); // 'Admin' or 'Kepala Sekolah'
  TextColumn get actionType => text()(); // 'INSERT_PAYMENT', 'VOID_TRANSACTION', etc.
  TextColumn get entityAffected => text()();
  IntColumn get entityId => integer().nullable()();
  TextColumn get timestampIso => text()();
  TextColumn get details => text().nullable()();
}
