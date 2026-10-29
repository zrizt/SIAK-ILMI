import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/features/students/domain/auto_nis_generator_use_case.dart';
import 'package:siak_ilmi/core/database/daos/siswa_dao.dart';

/// Creates an in-memory [AppDatabase] for testing (no file I/O).
AppDatabase buildTestDatabase() =>
    AppDatabase(NativeDatabase.memory());

void main() {
  group('AutoNisGeneratorUseCase', () {
    late AppDatabase db;
    late DatabaseSeeder seeder;
    late AutoNisGeneratorUseCase useCase;

    setUp(() async {
      db = buildTestDatabase();
      seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();
      useCase = AutoNisGeneratorUseCase(SiswaDao(db));
    });

    tearDown(() => db.close());

    test('AC-02: First SMP student in 2026 gets NIS 262001', () async {
      final nis = await useCase.generate(
        sekolahId: 2, // SMP IT Darul Ilmi
        kodeSekolah: 2,
        tahunMasuk: 2026,
      );
      expect(nis, '262001');
    });

    test('AC-02: Second SMP student in 2026 gets NIS 262002', () async {
      // Insert first student
      final siswaDao = SiswaDao(db);
      // First call
      final nis1 = await useCase.generate(
        sekolahId: 2,
        kodeSekolah: 2,
        tahunMasuk: 2026,
      );
      expect(nis1, '262001');

      // Insert a stub so count increments
      await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 2,
          nis: nis1,
          namaLengkap: 'Siswa Test 1',
          jenisKelamin: 'L',
          kelasId: 7, // Grade 7
          tahunMasuk: 2026,
        ),
      );

      // Second call
      final nis2 = await useCase.generate(
        sekolahId: 2,
        kodeSekolah: 2,
        tahunMasuk: 2026,
      );
      expect(nis2, '262002');
    });

    test('SD student in 2026 uses schoolCode 1', () async {
      final nis = await useCase.generate(
        sekolahId: 1, // SD IT Baitul Akbar
        kodeSekolah: 1,
        tahunMasuk: 2026,
      );
      expect(nis, '261001');
    });
  });
}
