import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _compactFormat = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Formats an integer amount to Indonesian Rupiah string.
  /// e.g. 150000 → 'Rp 150.000'
  static String format(int amount) => _idrFormat.format(amount);

  /// Compact format for dashboard cards.
  /// e.g. 1500000 → 'Rp 1,5 jt'
  static String compact(int amount) => _compactFormat.format(amount);

  /// Parses a formatted currency string back to integer.
  /// Returns 0 on parse failure.
  static int parse(String formatted) {
    try {
      return _idrFormat.parse(formatted.replaceAll('.', '')).toInt();
    } catch (_) {
      return 0;
    }
  }
}
