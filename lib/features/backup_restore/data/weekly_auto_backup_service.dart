// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/supabase_config.dart';
import 'backup_service.dart';

/// Provider for [WeeklyAutoBackupService].
final weeklyAutoBackupServiceProvider = Provider<WeeklyAutoBackupService>(
  (ref) => WeeklyAutoBackupService(
    backupService: ref.watch(backupServiceProvider),
  ),
);

/// Handles silent background cloud backups to Supabase Storage.
///
/// Rules:
/// - Runs automatically in the background only when the device is online.
/// - Minimum interval between automatic backups is 5 days ([minInterval]).
/// - Strictly capped at **1 automatic online backup per ISO week**.
/// - Completely fail-silent: never throws or interrupts the user.
class WeeklyAutoBackupService {
  WeeklyAutoBackupService({
    required BackupService backupService,
    Future<bool> Function()? checkOnline,
    DateTime Function()? nowProvider,
    Future<SharedPreferences> Function()? prefsProvider,
  })  : _backupService = backupService,
        _checkOnline = checkOnline ?? _defaultCheckOnline,
        _nowProvider = nowProvider ?? (() => DateTime.now().toUtc()),
        _prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  static const String prefsKeyLastAutoBackup = 'siak_weekly_auto_backup_utc';
  static const Duration minInterval = Duration(days: 5);

  final BackupService _backupService;
  final Future<bool> Function() _checkOnline;
  final DateTime Function() _nowProvider;
  final Future<SharedPreferences> Function() _prefsProvider;

  bool _isRunning = false;

  /// Returns true if an automatic online backup is due at [nowUtc]
  /// given [lastBackupUtc].
  bool isBackupDue(DateTime? lastBackupUtc, DateTime nowUtc) {
    if (lastBackupUtc == null) return true;

    final elapsed = nowUtc.difference(lastBackupUtc);
    if (elapsed < minInterval) return false;

    // Enforce at most 1 automatic online backup per ISO calendar week.
    if (isoWeekKey(lastBackupUtc) == isoWeekKey(nowUtc)) {
      return false;
    }

    return true;
  }

  /// Checks schedule and online status, then performs a silent background
  /// backup to Supabase if due.
  ///
  /// Returns `true` if a new cloud backup was uploaded, `false` otherwise.
  /// Never throws.
  Future<bool> runIfDue() async {
    if (_isRunning) return false;
    _isRunning = true;

    try {
      final service = _backupService;
      if (service is SupabaseBackupService && !service.isConfigured) {
        return false;
      }

      final prefs = await _prefsProvider();
      final lastRaw = prefs.getString(prefsKeyLastAutoBackup);
      final lastBackupUtc =
          lastRaw != null ? DateTime.tryParse(lastRaw)?.toUtc() : null;
      final nowUtc = _nowProvider().toUtc();

      if (!isBackupDue(lastBackupUtc, nowUtc)) {
        return false;
      }

      final online = await _checkOnline();
      if (!online) {
        return false;
      }

      final result = await service.performBackup();
      if (result.cloudUploaded) {
        await prefs.setString(
          prefsKeyLastAutoBackup,
          nowUtc.toIso8601String(),
        );
        return true;
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      _isRunning = false;
    }
  }

  /// Computes ISO-8601 week identifier (e.g. `2026-W48`) in UTC.
  static String isoWeekKey(DateTime dateUtc) {
    final d = DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);
    final thursday = d.add(Duration(days: 4 - d.weekday));
    final isoYear = thursday.year;
    final jan1 = DateTime.utc(isoYear, 1, 1);
    final dayOfYear = thursday.difference(jan1).inDays;
    final isoWeek = (dayOfYear ~/ 7) + 1;
    return '$isoYear-W${isoWeek.toString().padLeft(2, '0')}';
  }

  static Future<bool> _defaultCheckOnline() async {
    try {
      final host = Uri.tryParse(supabaseUrl)?.host;
      if (host == null || host.isEmpty) return false;
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
