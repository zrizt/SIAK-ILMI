import 'package:flutter_test/flutter_test.dart';
import 'package:siak_ilmi/core/utils/bill_semester_helper.dart';

void main() {
  group('BillSemesterHelper Tests', () {
    test('Correctly identifies Semester 1 months and academic year', () {
      final items = [
        'SPP Juli 2026',
        'SPP Agustus 2026',
        'SPP September 2026',
        'SPP Oktober 2026',
        'SPP November 2026',
        'SPP Desember 2026',
      ];

      for (final item in items) {
        expect(BillSemesterHelper.getSemester(item), 1, reason: 'Item $item should be Semester 1');
        expect(BillSemesterHelper.getAcademicYear(item), '2026/2027', reason: 'Item $item should belong to TA 2026/2027');
        expect(BillSemesterHelper.getSemesterLabel(item), 'Semester 1');
      }
    });

    test('Correctly identifies Semester 2 months and academic year', () {
      final items = [
        'SPP Januari 2027',
        'SPP Februari 2027',
        'SPP Maret 2027',
        'SPP April 2027',
        'SPP Mei 2027',
        'SPP Juni 2027',
      ];

      for (final item in items) {
        expect(BillSemesterHelper.getSemester(item), 2, reason: 'Item $item should be Semester 2');
        expect(BillSemesterHelper.getAcademicYear(item), '2026/2027', reason: 'Item $item should belong to TA 2026/2027');
        expect(BillSemesterHelper.getSemesterLabel(item), 'Semester 2');
      }
    });

    test('Handles non-monthly fees and explicit TA format', () {
      expect(BillSemesterHelper.getSemester('Infaq Gedung 2026/2027'), isNull);
      expect(BillSemesterHelper.getAcademicYear('Infaq Gedung 2026/2027'), '2026/2027');
      expect(BillSemesterHelper.getSemesterLabel('Infaq Gedung 2026/2027'), 'Lainnya');

      expect(BillSemesterHelper.getSemester('Uang Pendaftaran'), isNull);
      expect(BillSemesterHelper.getAcademicYear('Uang Pendaftaran'), isNull);
    });
  });
}
