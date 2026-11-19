// ignore_for_file: avoid_print
import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
  final Sheet sheet = excel[defaultSheet];

  sheet.appendRow([
    TextCellValue('nama_lengkap'),
    TextCellValue('nisn'),
    TextCellValue('jenis_kelamin'),
    TextCellValue('tingkat'),
    TextCellValue('no_hp_wali'),
    TextCellValue('status_ppdb'),
  ]);

  final data = [
    // SD IT Baitul Akbar (Tingkat 1) — Lulus PPDB
    ['Muhammad Al-Fatih', '0151234001', 'L', 1, '08126789001', 'Lulus'],
    ['Aisyah Humaira', '0151234002', 'P', 1, '08126789002', 'Lulus'],
    ['Abdullah Rayyan', '0151234003', 'L', 1, '08126789003', 'Lulus'],
    ['Fatimah Zahra', '0151234004', 'P', 1, '08126789004', 'Lulus'],
    ['Ibrahim Malik', '0151234005', 'L', 1, '08126789005', 'Lulus'],
    ['Khadijah Azzahra', '0151234006', 'P', 1, '08126789006', 'Tidak Lulus'],
    // SMP IT Darul Ilmi (Tingkat 7)
    ['Ahmad Farhan Zaki', '0121234001', 'L', 7, '08137890001', 'Lulus'],
    ['Nabila Putri Syakir', '0121234002', 'P', 7, '08137890002', 'Lulus'],
    ['Umar Abdul Aziz', '0121234003', 'L', 7, '08137890003', 'Lulus'],
    ['Maryam Qonita', '0121234004', 'P', 7, '08137890004', 'Lulus'],
    ['Bilal Ramadhan', '0121234005', 'L', 7, '08137890005', 'Tidak Lulus'],
    ['Zaskia Adelia', '0121234006', 'P', 7, '08137890006', 'Lulus'],
  ];

  for (final row in data) {
    sheet.appendRow([
      TextCellValue(row[0].toString()),
      TextCellValue(row[1].toString()),
      TextCellValue(row[2].toString()),
      IntCellValue(row[3] as int),
      TextCellValue(row[4].toString()),
      TextCellValue(row[5].toString()),
    ]);
  }

  final bytes = excel.save();
  if (bytes != null) {
    File('docs/CONTOH_IMPORT_PPDB.xlsx').writeAsBytesSync(bytes);
    print('Excel successfully generated with package:excel!');
  }
}
