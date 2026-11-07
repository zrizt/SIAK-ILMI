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
  ]);

  final data = [
    // Siswa Baru SD IT Baitul Akbar (Tingkat 1)
    ['Muhammad Al-Fatih', '0151234001', 'L', 1, '08126789001'],
    ['Aisyah Humaira', '0151234002', 'P', 1, '08126789002'],
    ['Abdullah Rayyan', '0151234003', 'L', 1, '08126789003'],
    ['Fatimah Zahra', '0151234004', 'P', 1, '08126789004'],
    ['Ibrahim Malik', '0151234005', 'L', 1, '08126789005'],
    ['Khadijah Azzahra', '0151234006', 'P', 1, '08126789006'],
    // Siswa Baru SMP IT Darul Ilmi (Tingkat 7)
    ['Ahmad Farhan Zaki', '0121234001', 'L', 7, '08137890001'],
    ['Nabila Putri Syakir', '0121234002', 'P', 7, '08137890002'],
    ['Umar Abdul Aziz', '0121234003', 'L', 7, '08137890003'],
    ['Maryam Qonita', '0121234004', 'P', 7, '08137890004'],
    ['Bilal Ramadhan', '0121234005', 'L', 7, '08137890005'],
    ['Zaskia Adelia', '0121234006', 'P', 7, '08137890006'],
  ];

  for (final row in data) {
    sheet.appendRow([
      TextCellValue(row[0].toString()),
      TextCellValue(row[1].toString()),
      TextCellValue(row[2].toString()),
      IntCellValue(row[3] as int),
      TextCellValue(row[4].toString()),
    ]);
  }

  final bytes = excel.save();
  if (bytes != null) {
    File('docs/CONTOH_IMPORT_PPDB.xlsx').writeAsBytesSync(bytes);
    print('Excel successfully generated with package:excel!');
  }
}
