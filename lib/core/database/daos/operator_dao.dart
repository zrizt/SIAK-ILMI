import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/operator_account_table.dart';

part 'operator_dao.g.dart';

@DriftAccessor(tables: [OperatorAccount])
class OperatorDao extends DatabaseAccessor<AppDatabase>
    with _$OperatorDaoMixin {
  OperatorDao(super.db);

  /// Inserts a new operator and returns the generated id.
  Future<int> insertOperator(OperatorAccountCompanion entry) =>
      into(operatorAccount).insert(entry);

  /// Returns all operators ordered by full name.
  Future<List<OperatorData>> getAllOperators() =>
      (select(operatorAccount)
            ..orderBy([(o) => OrderingTerm.asc(o.fullName)]))
          .get();

  /// Returns active operators only.
  Future<List<OperatorData>> getActiveOperators() =>
      (select(operatorAccount)..where((o) => o.isActive.equals(1))).get();

  /// Finds an operator by username (for login).
  Future<OperatorData?> getByUsername(String username) =>
      (select(operatorAccount)
            ..where((o) => o.username.equals(username)))
          .getSingleOrNull();

  /// Finds an operator by id.
  Future<OperatorData?> getById(int id) =>
      (select(operatorAccount)..where((o) => o.id.equals(id)))
          .getSingleOrNull();

  /// Partial update of an operator row.
  Future<bool> updateOperator(int id, OperatorAccountCompanion entry) async {
    final count = await (update(operatorAccount)
          ..where((o) => o.id.equals(id)))
        .write(entry);
    return count > 0;
  }

  /// Toggles the active/inactive state of an operator.
  Future<void> setActive(int id, {required bool active}) async {
    await (update(operatorAccount)..where((o) => o.id.equals(id))).write(
      OperatorAccountCompanion(
        isActive: Value(active ? 1 : 0),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  /// Watches the full operator list reactively.
  Stream<List<OperatorData>> watchAll() =>
      (select(operatorAccount)
            ..orderBy([(o) => OrderingTerm.asc(o.fullName)]))
          .watch();

  /// Returns the total count of operators.
  Future<int> count() async {
    final countExpr = operatorAccount.id.count();
    final q = selectOnly(operatorAccount)..addColumns([countExpr]);
    final row = await q.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
