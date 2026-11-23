/// Options for generating financial and billing Excel reports.
class ExcelExportOptions {
  const ExcelExportOptions({
    this.sekolahId,
    this.tahunAjaran,
    this.operatorName,
  });

  /// null = Semua Sekolah (SD & SMP), 1 = SD IT Baitul Akbar, 2 = SMP IT Darul Ilmi
  final int? sekolahId;

  /// null = Semua Tahun Ajaran, or specific academic year e.g. "2026/2027"
  final String? tahunAjaran;

  /// Name of cashier / operator generating the report
  final String? operatorName;

  String get sekolahLabel {
    if (sekolahId == 1) return 'SD IT Baitul Akbar Parabek';
    if (sekolahId == 2) return 'SMP IT Darul Ilmi';
    return 'Semua Sekolah (SD & SMP)';
  }

  String get tahunAjaranLabel {
    if (tahunAjaran != null && tahunAjaran!.isNotEmpty) {
      return 'Tahun Ajaran $tahunAjaran';
    }
    return 'Semua Tahun Ajaran';
  }
}
