// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/features/reports/data/excel_export_service.dart';
import 'package:siak_ilmi/features/reports/domain/excel_export_options.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  MockPathProviderPlatform(this.tempPath);
  final String tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;
  late ExcelExportService exportService;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('excel_export_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);

    db = AppDatabase(NativeDatabase.memory());
    final seeder = DatabaseSeeder(db);
    await seeder.seedIfEmpty();

    // Create a student in SD (sekolahId: 1, kelasId: 1)
    final siswaId1 = await db.into(db.siswa).insert(
          SiswaCompanion.insert(
            sekolahId: 1,
            nis: '261001',
            namaLengkap: 'Ahmad Santoso',
            jenisKelamin: 'L',
            kelasId: 1,
            tahunMasuk: 2026,
            status: const Value('AKTIF'),
          ),
        );

    // Create a student in SMP (sekolahId: 2, kelasId: 7)
    final siswaId2 = await db.into(db.siswa).insert(
          SiswaCompanion.insert(
            sekolahId: 2,
            nis: '262001',
            namaLengkap: 'Fatimah Az-Zahra',
            jenisKelamin: 'P',
            kelasId: 7,
            tahunMasuk: 2026,
            status: const Value('AKTIF'),
          ),
        );

    // Create bills for student 1 (SD)
    final tagihanId1 = await db.into(db.tagihanSiswa).insert(
          TagihanSiswaCompanion.insert(
            siswaId: siswaId1,
            periode: 'Juli 2026',
            isLunas: const Value(0),
          ),
        );
    final itemId1 = await db.into(db.tagihanItem).insert(
          TagihanItemCompanion.insert(
            tagihanId: tagihanId1,
            kategoriBiayaId: 1, // SPP
            namaItem: 'SPP Juli 2026',
            nominalAwal: 150000,
            nominalDiskon: const Value(0),
            nominalAkhir: 150000,
            terbayar: const Value(150000),
            isLunas: const Value(1),
          ),
        );

    // Create bills for student 2 (SMP)
    final tagihanId2 = await db.into(db.tagihanSiswa).insert(
          TagihanSiswaCompanion.insert(
            siswaId: siswaId2,
            periode: 'Juli 2026',
            isLunas: const Value(0),
          ),
        );
    await db.into(db.tagihanItem).insert(
          TagihanItemCompanion.insert(
            tagihanId: tagihanId2,
            kategoriBiayaId: 1, // SPP
            namaItem: 'SPP Juli 2026',
            nominalAwal: 200000,
            nominalDiskon: const Value(50000),
            nominalAkhir: 150000,
            terbayar: const Value(0),
            isLunas: const Value(0),
          ),
        );

    // Create payment transaction for student 1
    final txId = await db.into(db.pembayaranTransaksi).insert(
          PembayaranTransaksiCompanion.insert(
            nomorKuitansi: 'KW-20260710-0001',
            siswaId: siswaId1,
            tanggalBayar: '2026-07-10T09:30:00',
            totalBayar: 150000,
            metodeBayar: 'Tunai',
            status: const Value('VALID'),
            createdBy: 'Admin Kasir',
          ),
        );

    await db.into(db.alokasiPembayaran).insert(
          AlokasiPembayaranCompanion.insert(
            transaksiId: txId,
            tagihanItemId: itemId1,
            nominalDialokasikan: 150000,
          ),
        );

    exportService = ExcelExportService(db);
  });

  tearDown(() async {
    await db.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('ExcelExportService Tests', () {
    test('exports financial report workbook with all 3 sheets for all schools and TA',
        () async {
      const options = ExcelExportOptions(
        sekolahId: null,
        tahunAjaran: null,
        operatorName: 'Ahmad Operator',
      );

      final filePath = await exportService.exportFinancialReport(options);
      final file = File(filePath);

      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(1000));

      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      // Verify all 3 required sheets exist
      expect(excel.tables.containsKey('Ringkasan Laporan'), isTrue);
      expect(excel.tables.containsKey('Rekap Tagihan Siswa'), isTrue);
      expect(excel.tables.containsKey('Riwayat Transaksi'), isTrue);

      // Verify Sheet 1 content
      final sheet1 = excel.tables['Ringkasan Laporan']!;
      expect(sheet1.maxRows, greaterThan(10));

      // Verify Sheet 2 content
      final sheet2 = excel.tables['Rekap Tagihan Siswa']!;
      expect(sheet2.maxRows, greaterThanOrEqualTo(3)); // header + 2 items + total

      // Verify Sheet 3 content
      final sheet3 = excel.tables['Riwayat Transaksi']!;
      expect(sheet3.maxRows, greaterThanOrEqualTo(2)); // header + 1 transaction + total
    });

    test('filters report by school (SD IT only)', () async {
      const options = ExcelExportOptions(
        sekolahId: 1, // SD only
        tahunAjaran: null,
        operatorName: 'Admin',
      );

      final filePath = await exportService.exportFinancialReport(options);
      final file = File(filePath);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet2 = excel.tables['Rekap Tagihan Siswa']!;
      // Should only contain the SD student bill (1 row) + header + total
      expect(sheet2.maxRows, equals(3));
    });

    test('filters report by academic year (2026/2027)', () async {
      const options = ExcelExportOptions(
        sekolahId: null,
        tahunAjaran: '2026/2027',
        operatorName: 'Admin',
      );

      final filePath = await exportService.exportFinancialReport(options);
      final file = File(filePath);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet2 = excel.tables['Rekap Tagihan Siswa']!;
      // Both SPP Juli 2026 belong to 2026/2027
      expect(sheet2.maxRows, equals(4)); // header + 2 items + total
    });

    test('filters report by non-matching academic year returns empty items',
        () async {
      const options = ExcelExportOptions(
        sekolahId: null,
        tahunAjaran: '2028/2029', // No bills for this TA
        operatorName: 'Admin',
      );

      final filePath = await exportService.exportFinancialReport(options);
      final file = File(filePath);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet2 = excel.tables['Rekap Tagihan Siswa']!;
      // header + total row only
      expect(sheet2.maxRows, equals(2));
    });
  });
}
