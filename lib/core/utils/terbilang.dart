/// Converts an integer IDR amount to Indonesian words (terbilang).
///
/// Examples:
///   Terbilang.convert(150000) → 'Seratus Lima Puluh Ribu Rupiah'
///   Terbilang.convert(1500000) → 'Satu Juta Lima Ratus Ribu Rupiah'
class Terbilang {
  Terbilang._();

  static const List<String> _ones = [
    '',
    'Satu',
    'Dua',
    'Tiga',
    'Empat',
    'Lima',
    'Enam',
    'Tujuh',
    'Delapan',
    'Sembilan',
    'Sepuluh',
    'Sebelas',
    'Dua Belas',
    'Tiga Belas',
    'Empat Belas',
    'Lima Belas',
    'Enam Belas',
    'Tujuh Belas',
    'Delapan Belas',
    'Sembilan Belas',
  ];

  /// Converts [amount] to Indonesian words ending with "Rupiah".
  static String convert(int amount) {
    if (amount == 0) return 'Nol Rupiah';
    if (amount < 0) return 'Minus ${convert(-amount)}';
    return '${_toWords(amount)} Rupiah';
  }

  static String _toWords(int n) {
    if (n == 0) return '';
    if (n < 20) return _ones[n];
    if (n < 100) {
      final tens = n ~/ 10;
      final rem = n % 10;
      final tensStr = tens == 1 ? 'Sepuluh' : '${_ones[tens]} Puluh';
      return rem == 0 ? tensStr : '$tensStr ${_ones[rem]}';
    }
    if (n < 1000) {
      final h = n ~/ 100;
      final rem = n % 100;
      final hundredStr = h == 1 ? 'Seratus' : '${_ones[h]} Ratus';
      return rem == 0 ? hundredStr : '$hundredStr ${_toWords(rem)}';
    }
    if (n < 1000000) {
      final thousands = n ~/ 1000;
      final rem = n % 1000;
      final thousandStr =
          thousands == 1 ? 'Seribu' : '${_toWords(thousands)} Ribu';
      return rem == 0 ? thousandStr : '$thousandStr ${_toWords(rem)}';
    }
    if (n < 1000000000) {
      final millions = n ~/ 1000000;
      final rem = n % 1000000;
      final millionStr = '${_toWords(millions)} Juta';
      return rem == 0 ? millionStr : '$millionStr ${_toWords(rem)}';
    }
    final billions = n ~/ 1000000000;
    final rem = n % 1000000000;
    final billionStr = '${_toWords(billions)} Miliar';
    return rem == 0 ? billionStr : '$billionStr ${_toWords(rem)}';
  }
}
