import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/utils/bill_semester_helper.dart';
import '../domain/excel_export_options.dart';

/// Riverpod provider for [ExcelExportService].
final excelExportServiceProvider = Provider<ExcelExportService>((ref) {
  return ExcelExportService(ref.watch(appDatabaseProvider));
});

/// High-performance export engine that compiles school financial and student billing
/// data into a formatted, human-readable multi-sheet Microsoft Excel (.xlsx) workbook.
class ExcelExportService {
  const ExcelExportService(this._db);

  final AppDatabase _db;

  /// Generates the Excel financial report workbook and returns the file path.
  Future<String> exportFinancialReport(ExcelExportOptions options) async {
    // ── 1. Fetch metadata & lookup maps ─────────────────────────────────────
    final sekolahList = await _db.select(_db.sekolah).get();
    final sekolahMap = {for (final s in sekolahList) s.id: s};

    final kelasList = await _db.select(_db.kelas).get();
    final kelasMap = {for (final k in kelasList) k.id: k};

    final kategoriList = await _db.select(_db.kategoriBiaya).get();
    final kategoriMap = {for (final kat in kategoriList) kat.id: kat};

    // ── 2. Fetch students ───────────────────────────────────────────────────
    final siswaQuery = _db.select(_db.siswa);
    if (options.sekolahId != null) {
      siswaQuery.where((s) => s.sekolahId.equals(options.sekolahId!));
    }
    final students = await siswaQuery.get();
    final studentMap = {for (final s in students) s.id: s};
    final studentIds = studentMap.keys.toSet();

    // ── 3. Fetch bills & bill items ─────────────────────────────────────────
    final allBills = await _db.select(_db.tagihanSiswa).get();
    final relevantBills =
        allBills.where((b) => studentIds.contains(b.siswaId)).toList();
    final billMap = {for (final b in relevantBills) b.id: b};
    final relevantBillIds = billMap.keys.toSet();

    final allItems = await _db.select(_db.tagihanItem).get();
    final matchedItems = <TagihanItemData>[];

    for (final item in allItems) {
      if (!relevantBillIds.contains(item.tagihanId)) continue;
      final bill = billMap[item.tagihanId]!;

      // Determine academic year for the bill item
      final itemTa = BillSemesterHelper.getAcademicYear(item.namaItem) ??
          BillSemesterHelper.getAcademicYear(bill.periode);

      if (options.tahunAjaran != null && options.tahunAjaran!.isNotEmpty) {
        if (itemTa != options.tahunAjaran) {
          continue;
        }
      }
      matchedItems.add(item);
    }

    // ── 4. Fetch payment transactions ───────────────────────────────────────
    final allTransactions = await _db.select(_db.pembayaranTransaksi).get();
    final matchedTransactions = <PembayaranTransaksiData>[];
    for (final tx in allTransactions) {
      if (!studentIds.contains(tx.siswaId)) continue;
      if (options.tahunAjaran != null && options.tahunAjaran!.isNotEmpty) {
        final txYear = tx.tanggalBayar.length >= 4
            ? int.tryParse(tx.tanggalBayar.substring(0, 4))
            : null;
        final optStartYear = options.tahunAjaran!.length >= 4
            ? int.tryParse(options.tahunAjaran!.substring(0, 4))
            : null;
        if (txYear != null && optStartYear != null) {
          if (txYear < optStartYear || txYear > optStartYear + 1) {
            continue;
          }
        }
      }
      matchedTransactions.add(tx);
    }

    // Fetch allocations for descriptions
    final allAllocations = await _db.select(_db.alokasiPembayaran).get();
    final allocMap = <int, List<AlokasiPembayaranData>>{};
    for (final a in allAllocations) {
      allocMap.putIfAbsent(a.transaksiId, () => []).add(a);
    }
    final allItemMap = {for (final it in allItems) it.id: it};

    // ── 5. Create Excel Workbook ────────────────────────────────────────────
    final excel = Excel.createExcel();

    // Setup Sheet 1: Ringkasan Eksekutif
    const sheet1Name = 'Ringkasan Laporan';
    final sheet1 = excel[sheet1Name];
    excel.setDefaultSheet(sheet1Name);
    excel.delete('Sheet1');

    _buildExecutiveSummarySheet(
      sheet: sheet1,
      options: options,
      students: students,
      items: matchedItems,
      transactions: matchedTransactions,
      kategoriMap: kategoriMap,
      sekolahMap: sekolahMap,
      billMap: billMap,
      studentMap: studentMap,
    );

    // Setup Sheet 2: Rekap Tagihan Siswa
    const sheet2Name = 'Rekap Tagihan Siswa';
    final sheet2 = excel[sheet2Name];
    _buildStudentBillsSheet(
      sheet: sheet2,
      options: options,
      items: matchedItems,
      billMap: billMap,
      studentMap: studentMap,
      kelasMap: kelasMap,
      sekolahMap: sekolahMap,
      kategoriMap: kategoriMap,
    );

    // Setup Sheet 3: Riwayat Pembayaran
    const sheet3Name = 'Riwayat Transaksi';
    final sheet3 = excel[sheet3Name];
    _buildTransactionsSheet(
      sheet: sheet3,
      options: options,
      transactions: matchedTransactions,
      studentMap: studentMap,
      kelasMap: kelasMap,
      sekolahMap: sekolahMap,
      allocMap: allocMap,
      itemMap: allItemMap,
    );

    // ── 6. Save to local storage file ───────────────────────────────────────
    final bytes = excel.save();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Gagal memproses encoding file Excel.');
    }

    final outputDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    final scopeCode = options.sekolahId == 1
        ? 'SD'
        : options.sekolahId == 2
            ? 'SMP'
            : 'SEMUA';
    final taCode = options.tahunAjaran != null
        ? 'TA_${options.tahunAjaran!.replaceAll('/', '-')}'
        : 'SEMUA_TA';

    final fileName = 'Laporan_Keuangan_SIAK_${scopeCode}_${taCode}_$dateStr.xlsx';
    final filePath = p.join(outputDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }

  // ── Helper: Format timestamp ──────────────────────────────────────────────
  static String _formatTimestamp(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} ${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  // ── Sheet 1: Ringkasan Eksekutif ──────────────────────────────────────────
  void _buildExecutiveSummarySheet({
    required Sheet sheet,
    required ExcelExportOptions options,
    required List<SiswaData> students,
    required List<TagihanItemData> items,
    required List<PembayaranTransaksiData> transactions,
    required Map<int, KategoriBiayaData> kategoriMap,
    required Map<int, SekolahData> sekolahMap,
    required Map<int, TagihanSiswaData> billMap,
    required Map<int, SiswaData> studentMap,
  }) {
    // Styles
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final subTitleStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#2E7D32'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final metaStyle = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final sectionHeaderStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
    );
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final regularCenter = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final regularLeft = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    final regularRight = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    final totalRowStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    final totalRowCenter = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Title rows
    _setCell(sheet, 0, 0, 'SISTEM INFORMASI ADMINISTRASI DAN KEUANGAN (SIAK-ILMI)', titleStyle);
    _setCell(sheet, 0, 1, 'LAPORAN REKAPITULASI KEUANGAN & PEMBAYARAN SISWA', subTitleStyle);
    _setCell(
      sheet,
      0,
      2,
      'Cakupan: ${options.sekolahLabel}  |  ${options.tahunAjaranLabel}',
      metaStyle,
    );
    _setCell(
      sheet,
      0,
      3,
      'Tanggal Cetak: ${_formatTimestamp(DateTime.now())}  |  Operator: ${options.operatorName ?? 'Administrator'}',
      metaStyle,
    );

    // Compute metrics
    int totalKotor = 0;
    int totalDiskon = 0;
    int totalBersih = 0;
    int totalTerbayar = 0;
    for (final item in items) {
      totalKotor += item.nominalAwal;
      totalDiskon += item.nominalDiskon;
      totalBersih += item.nominalAkhir;
      totalTerbayar += item.terbayar;
    }
    final totalSisa = totalBersih - totalTerbayar;
    final pctBayar =
        totalBersih > 0 ? (totalTerbayar / totalBersih * 100).toStringAsFixed(1) : '0.0';

    int validTxTotal = 0;
    for (final tx in transactions) {
      if (tx.status == 'VALID') {
        validTxTotal += tx.totalBayar;
      }
    }

    // Section 1: Ringkasan Utama
    int r = 5;
    _setCell(sheet, 0, r++, '1. RINGKASAN INDIKATOR UTAMA', sectionHeaderStyle);

    final summaryHeaders = ['Indikator Keuangan', 'Nominal / Nilai', 'Keterangan'];
    for (int i = 0; i < summaryHeaders.length; i++) {
      _setCell(sheet, i, r, summaryHeaders[i], headerStyle);
    }
    r++;

    final kpis = [
      ['Jumlah Siswa Terdaftar', '${students.length} Siswa', 'Total siswa sesuai cakupan filter'],
      ['Total Tagihan Kotor (Sebelum Diskon)', CurrencyFormatter.format(totalKotor), 'Akumulasi tarif dasar sebelum potongan'],
      ['Total Potongan / Beasiswa', CurrencyFormatter.format(totalDiskon), 'Potongan gelombang PPDB & skema khusus'],
      ['Total Tagihan Bersih (Kewajiban)', CurrencyFormatter.format(totalBersih), 'Total kewajiban biaya yang wajib dilunasi'],
      ['Total Pembayaran Diterima (Alokasi)', CurrencyFormatter.format(totalTerbayar), 'Akumulasi dana pembayaran yang sudah dialokasikan'],
      ['Total Pemasukan Kasir (Kuitansi Valid)', CurrencyFormatter.format(validTxTotal), 'Total penerimaan dari transaksi kasir VALID'],
      ['Total Sisa Piutang / Tunggakan', CurrencyFormatter.format(totalSisa), 'Piutang tagihan siswa yang belum lunas'],
      ['Persentase Pelunasan Tagihan', '$pctBayar%', 'Rasio perbandingan terbayar terhadap tagihan bersih'],
    ];

    for (final row in kpis) {
      _setCell(sheet, 0, r, row[0], regularLeft);
      _setCell(sheet, 1, r, row[1], regularRight);
      _setCell(sheet, 2, r, row[2], regularLeft);
      r++;
    }

    // Section 2: Rincian per Kategori Biaya
    r += 2;
    _setCell(sheet, 0, r++, '2. RINCIAN PER KATEGORI BIAYA', sectionHeaderStyle);

    final catHeaders = ['No', 'Kategori Biaya', 'Tagihan Kotor', 'Diskon', 'Tagihan Bersih', 'Terbayar', 'Sisa Tunggakan', '% Lunas'];
    for (int i = 0; i < catHeaders.length; i++) {
      _setCell(sheet, i, r, catHeaders[i], headerStyle);
    }
    r++;

    int catIdx = 1;
    for (final kat in kategoriMap.values) {
      final catItems = items.where((it) => it.kategoriBiayaId == kat.id).toList();
      if (catItems.isEmpty) continue;

      int kAwal = 0;
      int kDiskon = 0;
      int kBersih = 0;
      int kBayar = 0;
      for (final it in catItems) {
        kAwal += it.nominalAwal;
        kDiskon += it.nominalDiskon;
        kBersih += it.nominalAkhir;
        kBayar += it.terbayar;
      }
      final kSisa = kBersih - kBayar;
      final kPct = kBersih > 0 ? (kBayar / kBersih * 100).toStringAsFixed(1) : '0.0';

      _setCell(sheet, 0, r, '$catIdx', regularCenter);
      _setCell(sheet, 1, r, kat.namaBiaya, regularLeft);
      _setCell(sheet, 2, r, CurrencyFormatter.format(kAwal), regularRight);
      _setCell(sheet, 3, r, CurrencyFormatter.format(kDiskon), regularRight);
      _setCell(sheet, 4, r, CurrencyFormatter.format(kBersih), regularRight);
      _setCell(sheet, 5, r, CurrencyFormatter.format(kBayar), regularRight);
      _setCell(sheet, 6, r, CurrencyFormatter.format(kSisa), regularRight);
      _setCell(sheet, 7, r, '$kPct%', regularCenter);
      r++;
      catIdx++;
    }

    // Total row for categories
    _setCell(sheet, 0, r, '', totalRowCenter);
    _setCell(sheet, 1, r, 'TOTAL KATEGORI BIAYA', totalRowStyle);
    _setCell(sheet, 2, r, CurrencyFormatter.format(totalKotor), totalRowStyle);
    _setCell(sheet, 3, r, CurrencyFormatter.format(totalDiskon), totalRowStyle);
    _setCell(sheet, 4, r, CurrencyFormatter.format(totalBersih), totalRowStyle);
    _setCell(sheet, 5, r, CurrencyFormatter.format(totalTerbayar), totalRowStyle);
    _setCell(sheet, 6, r, CurrencyFormatter.format(totalSisa), totalRowStyle);
    _setCell(sheet, 7, r, '$pctBayar%', totalRowCenter);
    r++;

    // Section 3: Rincian per Lembaga / Sekolah
    r += 2;
    _setCell(sheet, 0, r++, '3. RINCIAN PER LEMBAGA / SEKOLAH', sectionHeaderStyle);

    final schHeaders = ['No', 'Nama Lembaga', 'Jumlah Siswa', 'Tagihan Bersih', 'Terbayar', 'Sisa Tunggakan', '% Lunas'];
    for (int i = 0; i < schHeaders.length; i++) {
      _setCell(sheet, i, r, schHeaders[i], headerStyle);
    }
    r++;

    int schIdx = 1;
    for (final sch in sekolahMap.values) {
      if (options.sekolahId != null && options.sekolahId != sch.id) continue;

      final schStudents = students.where((s) => s.sekolahId == sch.id).toList();

      int scBersih = 0;
      int scBayar = 0;
      for (final it in items) {
        final b = billMap[it.tagihanId];
        if (b != null) {
          final st = studentMap[b.siswaId];
          if (st != null && st.sekolahId == sch.id) {
            scBersih += it.nominalAkhir;
            scBayar += it.terbayar;
          }
        }
      }
      final scSisa = scBersih - scBayar;
      final scPct = scBersih > 0 ? (scBayar / scBersih * 100).toStringAsFixed(1) : '0.0';

      _setCell(sheet, 0, r, '$schIdx', regularCenter);
      _setCell(sheet, 1, r, sch.namaSekolah, regularLeft);
      _setCell(sheet, 2, r, '${schStudents.length} Siswa', regularCenter);
      _setCell(sheet, 3, r, CurrencyFormatter.format(scBersih), regularRight);
      _setCell(sheet, 4, r, CurrencyFormatter.format(scBayar), regularRight);
      _setCell(sheet, 5, r, CurrencyFormatter.format(scSisa), regularRight);
      _setCell(sheet, 6, r, '$scPct%', regularCenter);
      r++;
      schIdx++;
    }

    // Set column widths for Sheet 1
    sheet.setColumnWidth(0, 36.0);
    sheet.setColumnWidth(1, 26.0);
    sheet.setColumnWidth(2, 45.0);
    sheet.setColumnWidth(3, 18.0);
    sheet.setColumnWidth(4, 20.0);
    sheet.setColumnWidth(5, 20.0);
    sheet.setColumnWidth(6, 20.0);
    sheet.setColumnWidth(7, 14.0);
  }

  // ── Sheet 2: Rekap Tagihan Siswa ──────────────────────────────────────────
  void _buildStudentBillsSheet({
    required Sheet sheet,
    required ExcelExportOptions options,
    required List<TagihanItemData> items,
    required Map<int, TagihanSiswaData> billMap,
    required Map<int, SiswaData> studentMap,
    required Map<int, KelasData> kelasMap,
    required Map<int, SekolahData> sekolahMap,
    required Map<int, KategoriBiayaData> kategoriMap,
  }) {
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final regularCenter = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final regularLeft = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    final regularRight = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    final lunasStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final sebagianStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#E65100'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final belumBayarStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#B71C1C'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final totalRowStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    final totalRowCenter = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Headers
    final headers = [
      'No',
      'NIS',
      'NISN',
      'Nama Siswa',
      'Sekolah',
      'Kelas',
      'Tahun Ajaran',
      'Periode Tagihan',
      'Kategori Biaya',
      'Nama Item Tagihan',
      'Tagihan Kotor',
      'Diskon',
      'Tagihan Bersih',
      'Terbayar',
      'Sisa Tunggakan',
      'Status Pelunasan',
    ];

    for (int i = 0; i < headers.length; i++) {
      _setCell(sheet, i, 0, headers[i], headerStyle);
    }

    int sumKotor = 0;
    int sumDiskon = 0;
    int sumBersih = 0;
    int sumTerbayar = 0;
    int sumSisa = 0;

    int r = 1;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final bill = billMap[item.tagihanId];
      if (bill == null) continue;
      final student = studentMap[bill.siswaId];
      if (student == null) continue;

      final sekolah = sekolahMap[student.sekolahId]?.namaSekolah ?? '-';
      final kelas = kelasMap[student.kelasId]?.namaKelas ?? '-';
      final kategori = kategoriMap[item.kategoriBiayaId]?.namaBiaya ?? '-';
      final ta = BillSemesterHelper.getAcademicYear(item.namaItem) ??
          BillSemesterHelper.getAcademicYear(bill.periode) ??
          '-';

      final sisa = item.nominalAkhir - item.terbayar;
      final statusLabel = item.isLunas == 1
          ? 'LUNAS'
          : item.terbayar > 0
              ? 'SEBAGIAN'
              : 'BELUM BAYAR';
      final statusStyle = item.isLunas == 1
          ? lunasStyle
          : item.terbayar > 0
              ? sebagianStyle
              : belumBayarStyle;

      sumKotor += item.nominalAwal;
      sumDiskon += item.nominalDiskon;
      sumBersih += item.nominalAkhir;
      sumTerbayar += item.terbayar;
      sumSisa += sisa;

      _setCell(sheet, 0, r, '$r', regularCenter);
      _setCell(sheet, 1, r, student.nis, regularCenter);
      _setCell(sheet, 2, r, student.nisn ?? '-', regularCenter);
      _setCell(sheet, 3, r, student.namaLengkap, regularLeft);
      _setCell(sheet, 4, r, sekolah, regularLeft);
      _setCell(sheet, 5, r, kelas, regularCenter);
      _setCell(sheet, 6, r, ta, regularCenter);
      _setCell(sheet, 7, r, bill.periode, regularCenter);
      _setCell(sheet, 8, r, kategori, regularLeft);
      _setCell(sheet, 9, r, item.namaItem, regularLeft);
      _setCell(sheet, 10, r, CurrencyFormatter.format(item.nominalAwal), regularRight);
      _setCell(sheet, 11, r, CurrencyFormatter.format(item.nominalDiskon), regularRight);
      _setCell(sheet, 12, r, CurrencyFormatter.format(item.nominalAkhir), regularRight);
      _setCell(sheet, 13, r, CurrencyFormatter.format(item.terbayar), regularRight);
      _setCell(sheet, 14, r, CurrencyFormatter.format(sisa), regularRight);
      _setCell(sheet, 15, r, statusLabel, statusStyle);
      r++;
    }

    // Summary Total row
    _setCell(sheet, 0, r, '', totalRowCenter);
    _setCell(sheet, 1, r, '', totalRowCenter);
    _setCell(sheet, 2, r, '', totalRowCenter);
    _setCell(sheet, 3, r, '', totalRowCenter);
    _setCell(sheet, 4, r, '', totalRowCenter);
    _setCell(sheet, 5, r, '', totalRowCenter);
    _setCell(sheet, 6, r, '', totalRowCenter);
    _setCell(sheet, 7, r, '', totalRowCenter);
    _setCell(sheet, 8, r, '', totalRowCenter);
    _setCell(sheet, 9, r, 'TOTAL REKAPITULASI', totalRowStyle);
    _setCell(sheet, 10, r, CurrencyFormatter.format(sumKotor), totalRowStyle);
    _setCell(sheet, 11, r, CurrencyFormatter.format(sumDiskon), totalRowStyle);
    _setCell(sheet, 12, r, CurrencyFormatter.format(sumBersih), totalRowStyle);
    _setCell(sheet, 13, r, CurrencyFormatter.format(sumTerbayar), totalRowStyle);
    _setCell(sheet, 14, r, CurrencyFormatter.format(sumSisa), totalRowStyle);
    _setCell(sheet, 15, r, '', totalRowCenter);

    // Set column widths
    sheet.setColumnWidth(0, 8.0);
    sheet.setColumnWidth(1, 14.0);
    sheet.setColumnWidth(2, 16.0);
    sheet.setColumnWidth(3, 28.0);
    sheet.setColumnWidth(4, 24.0);
    sheet.setColumnWidth(5, 12.0);
    sheet.setColumnWidth(6, 14.0);
    sheet.setColumnWidth(7, 18.0);
    sheet.setColumnWidth(8, 16.0);
    sheet.setColumnWidth(9, 24.0);
    sheet.setColumnWidth(10, 18.0);
    sheet.setColumnWidth(11, 16.0);
    sheet.setColumnWidth(12, 18.0);
    sheet.setColumnWidth(13, 18.0);
    sheet.setColumnWidth(14, 18.0);
    sheet.setColumnWidth(15, 16.0);
  }

  // ── Sheet 3: Riwayat Transaksi ────────────────────────────────────────────
  void _buildTransactionsSheet({
    required Sheet sheet,
    required ExcelExportOptions options,
    required List<PembayaranTransaksiData> transactions,
    required Map<int, SiswaData> studentMap,
    required Map<int, KelasData> kelasMap,
    required Map<int, SekolahData> sekolahMap,
    required Map<int, List<AlokasiPembayaranData>> allocMap,
    required Map<int, TagihanItemData> itemMap,
  }) {
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final regularCenter = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final regularLeft = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    final regularRight = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    final validStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final voidStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#B71C1C'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final totalRowStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    final totalRowCenter = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headers = [
      'No',
      'Nomor Kuitansi',
      'Tanggal & Waktu Bayar',
      'NIS',
      'Nama Siswa',
      'Sekolah',
      'Kelas',
      'Metode Bayar',
      'Total Bayar',
      'Kasir / Operator',
      'Status Transaksi',
      'Alokasi Tagihan yang Dibayar',
    ];

    for (int i = 0; i < headers.length; i++) {
      _setCell(sheet, i, 0, headers[i], headerStyle);
    }

    int sumValidTotal = 0;
    int r = 1;
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final student = studentMap[tx.siswaId];
      final sekolah = student != null ? (sekolahMap[student.sekolahId]?.namaSekolah ?? '-') : '-';
      final kelas = student != null ? (kelasMap[student.kelasId]?.namaKelas ?? '-') : '-';

      // Format payment date
      String formattedDate = tx.tanggalBayar;
      try {
        final dt = DateTime.parse(tx.tanggalBayar);
        formattedDate = _formatTimestamp(dt);
      } catch (_) {}

      // Build allocated item summary
      final allocs = allocMap[tx.id] ?? [];
      final allocDescriptions = <String>[];
      for (final a in allocs) {
        final item = itemMap[a.tagihanItemId];
        final itemName = item?.namaItem ?? 'Item #${a.tagihanItemId}';
        allocDescriptions.add('$itemName (${CurrencyFormatter.format(a.nominalDialokasikan)})');
      }
      final rincian = allocDescriptions.isNotEmpty ? allocDescriptions.join(', ') : '-';

      if (tx.status == 'VALID') {
        sumValidTotal += tx.totalBayar;
      }

      _setCell(sheet, 0, r, '$r', regularCenter);
      _setCell(sheet, 1, r, tx.nomorKuitansi, regularCenter);
      _setCell(sheet, 2, r, formattedDate, regularCenter);
      _setCell(sheet, 3, r, student?.nis ?? '-', regularCenter);
      _setCell(sheet, 4, r, student?.namaLengkap ?? '-', regularLeft);
      _setCell(sheet, 5, r, sekolah, regularLeft);
      _setCell(sheet, 6, r, kelas, regularCenter);
      _setCell(sheet, 7, r, tx.metodeBayar, regularCenter);
      _setCell(sheet, 8, r, CurrencyFormatter.format(tx.totalBayar), regularRight);
      _setCell(sheet, 9, r, tx.createdBy, regularCenter);
      _setCell(sheet, 10, r, tx.status, tx.status == 'VALID' ? validStyle : voidStyle);
      _setCell(sheet, 11, r, rincian, regularLeft);
      r++;
    }

    // Total row
    _setCell(sheet, 0, r, '', totalRowCenter);
    _setCell(sheet, 1, r, '', totalRowCenter);
    _setCell(sheet, 2, r, '', totalRowCenter);
    _setCell(sheet, 3, r, '', totalRowCenter);
    _setCell(sheet, 4, r, '', totalRowCenter);
    _setCell(sheet, 5, r, '', totalRowCenter);
    _setCell(sheet, 6, r, '', totalRowCenter);
    _setCell(sheet, 7, r, 'TOTAL PEMBAYARAN VALID', totalRowStyle);
    _setCell(sheet, 8, r, CurrencyFormatter.format(sumValidTotal), totalRowStyle);
    _setCell(sheet, 9, r, '', totalRowCenter);
    _setCell(sheet, 10, r, '', totalRowCenter);
    _setCell(sheet, 11, r, '', totalRowCenter);

    // Set column widths
    sheet.setColumnWidth(0, 8.0);
    sheet.setColumnWidth(1, 22.0);
    sheet.setColumnWidth(2, 20.0);
    sheet.setColumnWidth(3, 14.0);
    sheet.setColumnWidth(4, 28.0);
    sheet.setColumnWidth(5, 24.0);
    sheet.setColumnWidth(6, 12.0);
    sheet.setColumnWidth(7, 14.0);
    sheet.setColumnWidth(8, 20.0);
    sheet.setColumnWidth(9, 18.0);
    sheet.setColumnWidth(10, 16.0);
    sheet.setColumnWidth(11, 45.0);
  }

  // ── Cell setter helper ────────────────────────────────────────────────────
  void _setCell(Sheet sheet, int col, int row, String value, CellStyle style) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }
}
