/// Data model for a payment receipt.
/// Populated from a completed [PembayaranTransaksiData] + its allocations.
class ReceiptModel {
  const ReceiptModel({
    required this.nomorKuitansi,
    required this.tanggalBayar,
    required this.namaLengkap,
    required this.nis,
    required this.namaSekolah,
    required this.kelas,
    required this.metodeBayar,
    required this.items,
    required this.totalBayar,
    required this.createdBy,
    this.operatorNip,
  });

  final String nomorKuitansi;
  final DateTime tanggalBayar;
  final String namaLengkap;
  final String nis;
  final String namaSekolah;
  final String kelas;
  final String metodeBayar;
  final List<ReceiptLineItem> items;
  final int totalBayar;
  final String createdBy;
  final String? operatorNip;
}

class ReceiptLineItem {
  const ReceiptLineItem({
    required this.namaItem,
    required this.nominalDibayar,
    required this.sisaTagihan,
  });
  final String namaItem;
  final int nominalDibayar;
  final int sisaTagihan; // 0 if fully paid
}
