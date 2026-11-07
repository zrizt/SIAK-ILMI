import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/operator_dao.dart';

/// Provider for the currently authenticated operator.
/// null means no operator is logged in (falls back to PIN role name).
final activeOperatorProvider = StateProvider<OperatorData?>((ref) => null);

/// Provider for [OperatorService].
final operatorServiceProvider = Provider<OperatorService>((ref) {
  return OperatorService(OperatorDao(ref.watch(appDatabaseProvider)));
});

/// Local operator account management and authentication.
///
/// Uses per-operator random salts + SHA-256 — same pattern as PinService
/// but stored in SQLite (not SharedPreferences) so records survive app reinstalls
/// and are included in DB backups.
class OperatorService {
  const OperatorService(this._dao);

  final OperatorDao _dao;

  // ── Password utilities ───────────────────────────────────────────────────

  /// Generates a 24-character base64url random salt.
  static String generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(18, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hashes [password] with [salt] using SHA-256.
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  // ── Authentication ───────────────────────────────────────────────────────

  /// Authenticates an operator by username + password.
  /// Returns the [OperatorData] on success, or null on failure.
  Future<OperatorData?> login(String username, String password) async {
    final op = await _dao.getByUsername(username.trim());
    if (op == null || op.isActive == 0) return null;
    final hash = hashPassword(password, op.passwordSalt);
    return hash == op.passwordHash ? op : null;
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  /// Creates a new operator account. Returns the new operator's id.
  Future<int> createOperator({
    required String fullName,
    required String username,
    required String password,
    String? nip,
  }) async {
    final salt = generateSalt();
    final hash = hashPassword(password, salt);
    final now = DateTime.now().toIso8601String();
    final cleanNip = nip?.trim();
    return _dao.insertOperator(
      OperatorAccountCompanion.insert(
        fullName: fullName,
        nip: Value(cleanNip != null && cleanNip.isNotEmpty ? cleanNip : null),
        username: username.trim().toLowerCase(),
        passwordHash: hash,
        passwordSalt: salt,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Changes the password for a given operator id.
  /// Requires the operator's current password for verification.
  Future<bool> changePassword({
    required int operatorId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final op = await _dao.getById(operatorId);
    if (op == null) return false;
    final currentHash = hashPassword(currentPassword, op.passwordSalt);
    if (currentHash != op.passwordHash) return false;
    final salt = generateSalt();
    final newHash = hashPassword(newPassword, salt);
    await _dao.updateOperator(
      operatorId,
      OperatorAccountCompanion(
        passwordHash: Value(newHash),
        passwordSalt: Value(salt),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    return true;
  }

  Future<List<OperatorData>> getAllOperators() => _dao.getAllOperators();

  Future<void> setActive(int id, {required bool active}) =>
      _dao.setActive(id, active: active);

  Stream<List<OperatorData>> watchAll() => _dao.watchAll();

  Future<int> count() => _dao.count();
}
