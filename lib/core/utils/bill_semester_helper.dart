/// Helper utility to parse semester and academic year information from
/// Indonesian school fee item names (e.g. 'SPP Juli 2026', 'SPP Januari 2027').
class BillSemesterHelper {
  const BillSemesterHelper._();

  static const List<String> monthsSem1 = [
    'juli',
    'agustus',
    'september',
    'oktober',
    'november',
    'desember',
  ];

  static const List<String> monthsSem2 = [
    'januari',
    'februari',
    'maret',
    'april',
    'mei',
    'juni',
  ];

  /// Returns 1 for Semester 1 (Ganjil: Juli-Desember),
  /// 2 for Semester 2 (Genap: Januari-Juni), or null if non-monthly fee.
  static int? getSemester(String text) {
    final lower = text.toLowerCase();
    for (final m in monthsSem1) {
      if (lower.contains(m)) return 1;
    }
    for (final m in monthsSem2) {
      if (lower.contains(m)) return 2;
    }
    if (lower.contains('semester 1') ||
        lower.contains('sem 1') ||
        lower.contains('ganjil')) {
      return 1;
    }
    if (lower.contains('semester 2') ||
        lower.contains('sem 2') ||
        lower.contains('genap')) {
      return 2;
    }
    return null;
  }

  /// Extracts the Academic Year string (e.g. '2026/2027') from a bill text.
  ///
  /// Examples:
  /// - 'SPP Juli 2026' -> '2026/2027' (Semester 1 in July 2026 belongs to TA 2026/2027)
  /// - 'SPP Januari 2027' -> '2026/2027' (Semester 2 in Jan 2027 belongs to TA 2026/2027)
  /// - 'Infaq TA 2026/2027' -> '2026/2027'
  static String? getAcademicYear(String text) {
    // Check if TA is already in YYYY/YYYY format
    final explicitTaMatch = RegExp(r'(\d{4}/\d{4})').firstMatch(text);
    if (explicitTaMatch != null) {
      return explicitTaMatch.group(1);
    }

    // Check 4-digit year
    final yearMatch = RegExp(r'(\d{4})').firstMatch(text);
    if (yearMatch == null) return null;
    final year = int.tryParse(yearMatch.group(1)!);
    if (year == null) return null;

    final sem = getSemester(text);
    if (sem == 1) {
      return '$year/${year + 1}';
    } else if (sem == 2) {
      return '${year - 1}/$year';
    }
    return '$year';
  }

  /// Returns human readable label for item's semester.
  static String getSemesterLabel(String text) {
    final sem = getSemester(text);
    if (sem == 1) return 'Semester 1';
    if (sem == 2) return 'Semester 2';
    return 'Lainnya';
  }
}
