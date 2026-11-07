import 'package:drift/drift.dart';

/// Operator account table for local operator identity management.
/// Separate from PIN auth — operators are linked to transactions by name.
@DataClassName('OperatorData')
class OperatorAccount extends Table {
  @override
  String get tableName => 'operator_account';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()(); // e.g. 'Budi Santoso'
  TextColumn get nip => text().nullable()(); // optional NIP (e.g. 198501012010011001)
  TextColumn get username => text().unique()(); // login username
  TextColumn get passwordHash => text()(); // SHA-256(salt:password)
  TextColumn get passwordSalt => text()(); // per-operator random salt
  IntColumn get isActive =>
      integer().withDefault(const Constant(1))(); // 1=active, 0=inactive
  TextColumn get createdAt => text()(); // ISO8601
  TextColumn get updatedAt => text()(); // ISO8601
}
