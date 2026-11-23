// dart run build_runner build --delete-conflicting-outputs
// to regenerate app_database.g.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/audit_dao.dart';
import 'daos/operator_dao.dart';
import 'daos/pembayaran_dao.dart';
import 'daos/sekolah_dao.dart';
import 'daos/siswa_dao.dart';
import 'daos/tagihan_dao.dart';
import 'daos/tarif_dao.dart';
import 'tables/alokasi_pembayaran_table.dart';
import 'tables/audit_log_table.dart';
import 'tables/kategori_biaya_table.dart';
import 'tables/kelas_table.dart';
import 'tables/operator_account_table.dart';
import 'tables/pembayaran_transaksi_table.dart';
import 'tables/sekolah_table.dart';
import 'tables/siswa_table.dart';
import 'tables/skema_pembayaran_siswa_table.dart';
import 'tables/tagihan_item_table.dart';
import 'tables/tagihan_siswa_table.dart';
import 'tables/tahun_ajaran_table.dart';
import 'tables/tarif_master_table.dart';

part 'app_database.g.dart';

/// Manages the active [AppDatabase] instance and hot-reload lifecycle.
class DatabaseNotifier extends StateNotifier<AppDatabase> {
  DatabaseNotifier(
    super.initialDb, {
    AppDatabase Function()? dbFactory,
  }) : _dbFactory = dbFactory ?? (() => AppDatabase());

  final AppDatabase Function() _dbFactory;

  /// Closes the current database connection and opens a fresh one.
  /// All dependent providers watching [appDatabaseProvider] will automatically update.
  Future<void> reloadDatabase() async {
    try {
      await state.close();
    } catch (_) {}
    state = _dbFactory();
  }
}

/// Provider managing the mutable state of the active [AppDatabase].
final databaseNotifierProvider =
    StateNotifierProvider<DatabaseNotifier, AppDatabase>((ref) {
  return DatabaseNotifier(AppDatabase());
});

/// Global Riverpod provider for the [AppDatabase].
/// Reads from [databaseNotifierProvider] so that when [DatabaseNotifier.reloadDatabase]
/// is invoked, all dependent DAOs, services, and UI streams reactively reload.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(databaseNotifierProvider);
});

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
    OperatorAccount, // added in schema v2
  ],
  daos: [
    SiswaDao,
    TagihanDao,
    PembayaranDao,
    TarifDao,
    AuditDao,
    SekolahDao,
    OperatorDao, // added in schema v2
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Create performance indexes.
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
        onUpgrade: (Migrator m, int from, int to) async {
          // v1 → v2: Add operator_account table
          if (from < 2) {
            await m.createTable(operatorAccount);
          }
          // v2 → v3: Add nip column to operator_account table
          if (from < 3) {
            await m.addColumn(operatorAccount, operatorAccount.nip);
          }
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
