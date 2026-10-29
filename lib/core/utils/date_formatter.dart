import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final _displayFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _dateOnlyFormat = DateFormat('yyyyMMdd');

  /// Formats a DateTime as the period string used in tagihan_siswa.
  /// e.g. 'Juli 2026'
  static String toPeriodString(DateTime date) =>
      _monthYearFormat.format(date);

  /// Formats a DateTime to ISO 8601 string for database storage.
  static String toIso(DateTime date) => _isoFormat.format(date);

  /// Formats a DateTime for display in receipts and UI.
  static String toDisplay(DateTime date) => _displayFormat.format(date);

  /// Formats a DateTime as YYYYMMDD for nomor_kuitansi generation.
  static String toDateCode(DateTime date) => _dateOnlyFormat.format(date);

  /// Returns today's ISO8601 date prefix (YYYY-MM-DD) for DB queries.
  static String todayPrefix() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
