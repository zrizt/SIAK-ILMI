import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'student_repository.dart';

final dapodikParserProvider = Provider<DapodikParser>(
  (ref) => const DapodikParser(),
);

/// Parse result containing imported rows and skipped duplicates.
class ParseResult {
  const ParseResult({
    required this.rows,
    required this.duplicateNisns,
    required this.errorRows,
  });
  final List<DapodikImportRow> rows;
  final List<String> duplicateNisns;
  final List<String> errorRows;
}

/// Parses Dapodik export files (.xlsx or .csv) into [DapodikImportRow] lists.
///
/// Required columns (case-insensitive):
///   - nama / nama_lengkap
///   - nisn (optional)
///   - jenis_kelamin / gender  (L/P or Laki/Perempuan)
///   - tingkat / kelas / grade  (1-9)
///   - no_hp_wali / kontak_wali / phone (optional)
///
/// School is resolved from [tingkat]: 1-6 = SD (sekolahId=1), 7-9 = SMP (sekolahId=2)
class DapodikParser {
  const DapodikParser();

  Future<ParseResult> parseFile(File file, int tahunMasuk) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext == 'csv') return _parseCsv(file, tahunMasuk);
    if (ext == 'xlsx' || ext == 'xls') return _parseExcel(file, tahunMasuk);
    throw UnsupportedError('File format not supported: $ext');
  }

  Future<ParseResult> _parseExcel(File file, int tahunMasuk) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first;
    final rows = sheet.rows;
    if (rows.isEmpty) return _emptyResult();

    final headers = rows.first
        .map((c) => c?.value.toString().toLowerCase().trim() ?? '')
        .toList();

    return _processRows(
      rows.skip(1).map((r) => r.map((c) => c?.value.toString() ?? '').toList()).toList(),
      headers,
      tahunMasuk,
    );
  }

  Future<ParseResult> _parseCsv(File file, int tahunMasuk) async {
    final content = await file.readAsString();
    final csvRows = const CsvToListConverter().convert(content);
    if (csvRows.isEmpty) return _emptyResult();

    final headers = csvRows.first
        .map((c) => c.toString().toLowerCase().trim())
        .toList();

    return _processRows(
      csvRows.skip(1).map((r) => r.map((c) => c.toString()).toList()).toList(),
      headers,
      tahunMasuk,
    );
  }

  ParseResult _processRows(
    List<List<String>> dataRows,
    List<String> headers,
    int tahunMasuk,
  ) {
    final namaIdx = _findCol(headers, ['nama', 'nama_lengkap', 'name']);
    final nisnIdx = _findCol(headers, ['nisn']);
    final genderIdx = _findCol(headers, ['jenis_kelamin', 'gender', 'kelamin']);
    final tingkatIdx = _findCol(headers, ['tingkat', 'kelas', 'grade', 'level']);
    final kontakIdx =
        _findCol(headers, ['no_hp_wali', 'kontak_wali', 'phone', 'hp']);

    final result = <DapodikImportRow>[];
    final errors = <String>[];

    for (final row in dataRows) {
      String get(int? idx) =>
          (idx != null && idx < row.length) ? row[idx].trim() : '';

      final nama = get(namaIdx);
      if (nama.isEmpty) {
        errors.add('Empty name in row: $row');
        continue;
      }

      final tingkatStr = get(tingkatIdx);
      final tingkat = int.tryParse(tingkatStr);
      if (tingkat == null || tingkat < 1 || tingkat > 9) {
        errors.add('Invalid tingkat "$tingkatStr" for student $nama');
        continue;
      }

      final genderRaw = get(genderIdx).toUpperCase();
      final gender = _parseGender(genderRaw);

      // Resolve school from tingkat
      final isSD = tingkat <= 6;
      final sekolahId = isSD ? 1 : 2;
      final kodeSekolah = isSD ? 1 : 2;

      // kelasId = seeded as sekolahId-tingkat mapping
      // Seeder creates kelas IDs: SD grade 1 = id 1 ... SD grade 6 = id 6
      //                           SMP grade 7 = id 7 ... SMP grade 9 = id 9
      final kelasId = tingkat;

      result.add(DapodikImportRow(
        namaLengkap: nama,
        jenisKelamin: gender,
        kelasId: kelasId,
        sekolahId: sekolahId,
        kodeSekolah: kodeSekolah,
        tahunMasuk: tahunMasuk,
        nisn: nisnIdx != null ? get(nisnIdx).nullIfEmpty() : null,
        kontakWali: kontakIdx != null ? get(kontakIdx).nullIfEmpty() : null,
      ));
    }

    return ParseResult(rows: result, duplicateNisns: [], errorRows: errors);
  }

  int? _findCol(List<String> headers, List<String> candidates) {
    for (final c in candidates) {
      final idx = headers.indexOf(c);
      if (idx != -1) return idx;
    }
    return null;
  }

  String _parseGender(String raw) {
    if (raw == 'L' || raw.startsWith('LAKI')) return 'L';
    if (raw == 'P' || raw.startsWith('PERE')) return 'P';
    return 'L'; // Default
  }

  ParseResult _emptyResult() =>
      const ParseResult(rows: [], duplicateNisns: [], errorRows: []);
}

extension _StringExt on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}
