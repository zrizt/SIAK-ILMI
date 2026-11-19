import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/core/database/app_database.dart';
import 'package:siak_ilmi/core/database/daos/siswa_dao.dart';
import 'package:siak_ilmi/core/database/database_seeder.dart';
import 'package:siak_ilmi/core/services/audit_logger_service.dart';
import 'package:siak_ilmi/features/students/domain/promote_students_use_case.dart';

AppDatabase buildTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
  group('PromoteStudentsUseCase Tests', () {
    late AppDatabase db;
    late DatabaseSeeder seeder;
    late SiswaDao siswaDao;
    late AuditLoggerService auditLogger;
    late PromoteStudentsUseCase promoteUseCase;

    setUp(() async {
      db = buildTestDatabase();
      seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();

      siswaDao = SiswaDao(db);
      auditLogger = AuditLoggerService(db);
      promoteUseCase = PromoteStudentsUseCase(
        db: db,
        siswaDao: siswaDao,
        auditLogger: auditLogger,
      );
    });

    tearDown(() => db.close());

    test('getPromotionCandidates maps SD 1-5 and SMP 7-8 to next grade, 6 and 9 to graduate', () async {
      // Classes seeded:
      // SD (sekolahId 1): id 1=Kelas 1, id 2=Kelas 2, ... id 6=Kelas 6
      // SMP (sekolahId 2): id 7=Kelas 7, id 8=Kelas 8, id 9=Kelas 9

      // Insert students in different grades
      final idSd1 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261001',
          namaLengkap: 'Budi SD1',
          jenisKelamin: 'L',
          kelasId: 1, // Tingkat 1
          tahunMasuk: 2026,
        ),
      );

      final idSd6 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261002',
          namaLengkap: 'Siti SD6',
          jenisKelamin: 'P',
          kelasId: 6, // Tingkat 6
          tahunMasuk: 2021,
        ),
      );

      final idSmp8 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 2,
          nis: '262001',
          namaLengkap: 'Fajar SMP8',
          jenisKelamin: 'L',
          kelasId: 8, // Tingkat 8
          tahunMasuk: 2025,
        ),
      );

      final idSmp9 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 2,
          nis: '262002',
          namaLengkap: 'Alya SMP9',
          jenisKelamin: 'P',
          kelasId: 9, // Tingkat 9
          tahunMasuk: 2024,
        ),
      );

      final candidates = await promoteUseCase.getPromotionCandidates();
      expect(candidates.length, 4);

      final candSd1 = candidates.firstWhere((c) => c.student.id == idSd1);
      expect(candSd1.willGraduate, false);
      expect(candSd1.targetTingkat, 2);
      expect(candSd1.targetKelas?.tingkat, 2);

      final candSd6 = candidates.firstWhere((c) => c.student.id == idSd6);
      expect(candSd6.willGraduate, true);
      expect(candSd6.targetTingkat, isNull);

      final candSmp8 = candidates.firstWhere((c) => c.student.id == idSmp8);
      expect(candSmp8.willGraduate, false);
      expect(candSmp8.targetTingkat, 9);
      expect(candSmp8.targetKelas?.tingkat, 9);

      final candSmp9 = candidates.firstWhere((c) => c.student.id == idSmp9);
      expect(candSmp9.willGraduate, true);
      expect(candSmp9.targetTingkat, isNull);
    });

    test('executePromotion executes atomic promotion, graduation, retains, and transitions academic year', () async {
      final idSd1 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261001',
          namaLengkap: 'Budi SD1',
          jenisKelamin: 'L',
          kelasId: 1, // Tingkat 1
          tahunMasuk: 2026,
        ),
      );

      final idSd2 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261002',
          namaLengkap: 'Doni SD2 Tinggal',
          jenisKelamin: 'L',
          kelasId: 2, // Tingkat 2
          tahunMasuk: 2025,
        ),
      );

      final idSd6 = await siswaDao.insertSiswa(
        SiswaCompanion.insert(
          sekolahId: 1,
          nis: '261003',
          namaLengkap: 'Siti SD6',
          jenisKelamin: 'P',
          kelasId: 6, // Tingkat 6
          tahunMasuk: 2021,
        ),
      );

      final candidates = await promoteUseCase.getPromotionCandidates();

      // Mark Doni SD2 as retained (tinggal kelas)
      for (final c in candidates) {
        if (c.student.id == idSd2) {
          c.isRetained = true;
        }
      }

      final result = await promoteUseCase.executePromotion(
        candidates: candidates,
        newAcademicYear: '2027/2028',
        operatorName: 'Admin',
      );

      expect(result.totalProcessed, 3);
      expect(result.promotedCount, 1); // Budi SD1 -> SD2
      expect(result.retainedCount, 1); // Doni SD2 remains SD2
      expect(result.graduatedCount, 1); // Siti SD6 -> LULUS
      expect(result.newAcademicYear, '2027/2028');

      // Verify Budi promoted
      final updatedBudi = await siswaDao.getById(idSd1);
      expect(updatedBudi!.kelasId, 2);
      expect(updatedBudi.status, 'AKTIF');

      // Verify Doni retained
      final updatedDoni = await siswaDao.getById(idSd2);
      expect(updatedDoni!.kelasId, 2);
      expect(updatedDoni.status, 'AKTIF');

      // Verify Siti graduated
      final updatedSiti = await siswaDao.getById(idSd6);
      expect(updatedSiti!.status, 'LULUS');

      // Verify Academic Year transition
      final activeTa = await (db.select(db.tahunAjaran)..where((t) => t.isAktif.equals(1))).getSingle();
      expect(activeTa.namaTa, '2027/2028');

      final oldTa = await (db.select(db.tahunAjaran)..where((t) => t.namaTa.equals('2026/2027'))).getSingle();
      expect(oldTa.isAktif, 0);
    });
  });
}
