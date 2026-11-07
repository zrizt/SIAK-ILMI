import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/core/utils/terbilang.dart';

void main() {
  group('Terbilang Unit Tests', () {
    test('Zero returns Nol Rupiah', () {
      expect(Terbilang.convert(0), 'Nol Rupiah');
    });

    test('Single digits and teens', () {
      expect(Terbilang.convert(1), 'Satu Rupiah');
      expect(Terbilang.convert(10), 'Sepuluh Rupiah');
      expect(Terbilang.convert(11), 'Sebelas Rupiah');
      expect(Terbilang.convert(15), 'Lima Belas Rupiah');
      expect(Terbilang.convert(19), 'Sembilan Belas Rupiah');
    });

    test('Tens and hundreds', () {
      expect(Terbilang.convert(20), 'Dua Puluh Rupiah');
      expect(Terbilang.convert(25), 'Dua Puluh Lima Rupiah');
      expect(Terbilang.convert(100), 'Seratus Rupiah');
      expect(Terbilang.convert(105), 'Seratus Lima Rupiah');
      expect(Terbilang.convert(250), 'Dua Ratus Lima Puluh Rupiah');
    });

    test('Thousands and school fee figures', () {
      expect(Terbilang.convert(1000), 'Seribu Rupiah');
      expect(Terbilang.convert(150000), 'Seratus Lima Puluh Ribu Rupiah');
      expect(Terbilang.convert(400000), 'Empat Ratus Ribu Rupiah');
      expect(Terbilang.convert(750000), 'Tujuh Ratus Lima Puluh Ribu Rupiah');
    });

    test('Millions and Billions', () {
      expect(Terbilang.convert(1000000), 'Satu Juta Rupiah');
      expect(Terbilang.convert(1500000), 'Satu Juta Lima Ratus Ribu Rupiah');
      expect(
        Terbilang.convert(2575000),
        'Dua Juta Lima Ratus Tujuh Puluh Lima Ribu Rupiah',
      );
      expect(Terbilang.convert(1000000000), 'Satu Miliar Rupiah');
    });

    test('Negative numbers prepend Minus', () {
      expect(Terbilang.convert(-50000), 'Minus Lima Puluh Ribu Rupiah');
    });
  });
}
