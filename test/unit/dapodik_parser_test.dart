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

      // Verify no syntax/format errors, 10 accepted rows, 2 skipped (Tidak Lulus)
      expect(result.errorRows, isEmpty);
      expect(result.rows.length, 10);
      expect(result.skippedTidakLulusCount, 2);

      // Check first student: SD IT Baitul Akbar (Tingkat 1)
      final first = result.rows.first;
      expect(first.namaLengkap, 'Muhammad Al-Fatih');
      expect(first.jenisKelamin, 'L');
      expect(first.sekolahId, 1); // SD
      expect(first.kelasId, 1);
      expect(first.nisn, '0151234001');
      expect(first.kontakWali, '08126789001');
      expect(first.tahunMasuk, 2026);

      // Check first SMP student (index 5 because 1 SD student was skipped as 'Tidak Lulus')
      final smp = result.rows[5];
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
    test('Filters rows based on status_ppdb admission status in CSV', () async {
      final tempDir = Directory.systemTemp.createTempSync('ppdb_test_');
      final tempFile = File('${tempDir.path}/test_status.csv');
      tempFile.writeAsStringSync(
        'nama_lengkap,nisn,jenis_kelamin,tingkat,no_hp_wali,status_ppdb\r\n'
        'Siswa Diterima,0159999001,L,1,08120000001,Lulus\r\n'
        'Siswa Ditolak,0159999002,P,1,08120000002,Tidak Lulus\r\n'
        'Siswa Gagal,0159999003,L,1,08120000003,GAGAL\r\n'
        'Siswa Masuk,0159999004,P,1,08120000004,LULUS\r\n'
        'Siswa Rejected,0159999005,L,7,08120000005,DITOLAK\r\n',
      );

      final result = await parser.parseFile(tempFile, 2026);

      expect(result.errorRows, isEmpty);
      expect(result.rows.length, 2);
      expect(result.skippedTidakLulusCount, 3);
      expect(result.rows[0].namaLengkap, 'Siswa Diterima');
      expect(result.rows[1].namaLengkap, 'Siswa Masuk');

      tempDir.deleteSync(recursive: true);
    });
  });
}
