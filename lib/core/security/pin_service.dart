import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PIN role identifiers matching PRD Section 4.2.
enum PinRole {
  admin('Admin', 'pin_hash_admin'),
  viewer('Kepala Sekolah', 'pin_hash_viewer');

  const PinRole(this.displayName, this.prefKey);

  final String displayName;
  final String prefKey;
}

/// Manages local 6-digit PIN authentication.
/// Stores SHA-256 hash of PIN + salt — never the raw PIN.
class PinService {
  static const _saltKey = 'pin_salt';
  static const _defaultAdminPin = '123456';
  static const _defaultViewerPin = '654321';

  /// Generates a SHA-256 hash of [pin] combined with [salt].
  static String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  /// Initializes default PINs if not yet set.
  static Future<void> initializeDefaultPins() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(PinRole.admin.prefKey) == null) {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_saltKey, salt);
      await prefs.setString(
        PinRole.admin.prefKey,
        _hash(_defaultAdminPin, salt),
      );
      await prefs.setString(
        PinRole.viewer.prefKey,
        _hash(_defaultViewerPin, salt),
      );
    }
  }

  /// Verifies a PIN input against the stored hash for the given [role].
  /// Returns the matched [PinRole] or null if invalid.
  static Future<PinRole?> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_saltKey) ?? '';
    final inputHash = _hash(pin, salt);

    for (final role in PinRole.values) {
      final storedHash = prefs.getString(role.prefKey);
      if (storedHash != null && storedHash == inputHash) {
        return role;
      }
    }
    return null;
  }

  /// Updates the PIN for a given [role]. Requires the current Admin PIN to authorize.
  static Future<bool> changePin({
    required String currentAdminPin,
    required PinRole targetRole,
    required String newPin,
  }) async {
    final verified = await verifyPin(currentAdminPin);
    if (verified != PinRole.admin) return false;

    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_saltKey) ?? '';
    await prefs.setString(targetRole.prefKey, _hash(newPin, salt));
    return true;
  }

  /// Sets the PIN for a given [role] directly.
  static Future<bool> setPin(PinRole role, String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_saltKey) ?? '';
    return prefs.setString(role.prefKey, _hash(newPin, salt));
  }
}
