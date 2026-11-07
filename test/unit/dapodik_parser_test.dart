import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/features/students/data/dapodik_parser.dart';

void main() {
  group('DapodikParser Tests with Example Files', () {
    const parser = DapodikParser();

    test('Parses docs/CONTOH_IMPORT_PPDB.xlsx correctly', () async {
      final file = File('docs/CONTOH_IMPORT_PPDB.xlsx');
      expect(file.existsSync(), isTrue);

      final result = await parser.parseFile(file, 2026);

      // Verify no syntax/format errors
      expect(result.errorRows, isEmpty);
      expect(result.rows.length, 12);

      // Check first student: SD IT Baitul Akbar (Tingkat 1)
      final first = result.rows.first;
      expect(first.namaLengkap, 'Muhammad Al-Fatih');
      expect(first.jenisKelamin, 'L');
      expect(first.sekolahId, 1); // SD
      expect(first.kelasId, 1);
      expect(first.nisn, '0151234001');
      expect(first.kontakWali, '08126789001');
      expect(first.tahunMasuk, 2026);

      // Check seventh student: SMP IT Darul Ilmi (Tingkat 7)
      final smp = result.rows[6];
      expect(smp.namaLengkap, 'Ahmad Farhan Zaki');
      expect(smp.jenisKelamin, 'L');
      expect(smp.sekolahId, 2); // SMP
      expect(smp.kelasId, 7);
      expect(smp.nisn, '0121234001');
      expect(smp.kontakWali, '08137890001');
    });

    test('Parses docs/CONTOH_IMPORT_PPDB.csv correctly', () async {
      final file = File('docs/CONTOH_IMPORT_PPDB.csv');
      expect(file.existsSync(), isTrue);

      final result = await parser.parseFile(file, 2026);

      expect(result.errorRows, isEmpty);
      expect(result.rows.length, 12);
      expect(result.rows.where((s) => s.sekolahId == 1).length, 6);
      expect(result.rows.where((s) => s.sekolahId == 2).length, 6);
    });
  });
}
