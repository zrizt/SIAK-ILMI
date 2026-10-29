// dart run build_runner build --delete-conflicting-outputs
// to regenerate app_database.g.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/audit_dao.dart';
import 'daos/pembayaran_dao.dart';
import 'daos/siswa_dao.dart';
import 'daos/tagihan_dao.dart';
import 'daos/tarif_dao.dart';
import 'tables/alokasi_pembayaran_table.dart';
import 'tables/audit_log_table.dart';
import 'tables/kategori_biaya_table.dart';
import 'tables/kelas_table.dart';
import 'tables/pembayaran_transaksi_table.dart';
import 'tables/sekolah_table.dart';
import 'tables/siswa_table.dart';
import 'tables/skema_pembayaran_siswa_table.dart';
import 'tables/tagihan_item_table.dart';
import 'tables/tagihan_siswa_table.dart';
import 'tables/tahun_ajaran_table.dart';
import 'tables/tarif_master_table.dart';

part 'app_database.g.dart';

/// Global Riverpod provider for the [AppDatabase].
/// Overridden at startup in [bootstrap()] with the real instance.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('AppDatabase provider not initialized'),
);

@DriftDatabase(
  tables: [
    Sekolah,
    TahunAjaran,
    Kelas,
    KategoriBiaya,
    Siswa,
    TarifMaster,
    SkemaPembayaranSiswa,
    TagihanSiswa,
    TagihanItem,
    PembayaranTransaksi,
    AlokasiPembayaran,
    AuditLog,
  ],
  daos: [
    SiswaDao,
    TagihanDao,
    PembayaranDao,
    TarifDao,
    AuditDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Create performance indexes as raw SQL since Drift doesn't
          // support index declarations natively in the table class.
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_siswa_sekolah ON siswa(sekolah_id);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_siswa_kelas ON siswa(kelas_id);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tagihan_item_tagihan ON tagihan_item(tagihan_id);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_alokasi_transaksi ON alokasi_pembayaran(transaksi_id);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_pembayaran_siswa ON pembayaran_transaksi(siswa_id);',
          );
        },
        beforeOpen: (details) async {
          // CRITICAL: Enable foreign key constraints on every connection.
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
        },
      );
}

/// Opens a connection to the local SQLite file in the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'siak_ilmi.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
