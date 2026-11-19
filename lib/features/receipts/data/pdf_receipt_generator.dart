import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/terbilang.dart';
import '../domain/receipt_model.dart';

final pdfReceiptGeneratorProvider =
    Provider<PdfReceiptGenerator>((ref) => const PdfReceiptGenerator());

/// Generates a formal Indonesian school payment receipt (Kwitansi) in A5 format.
class PdfReceiptGenerator {
  const PdfReceiptGenerator();

  static final _idrFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
  static final _dateOnlyFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  /// Builds and saves the PDF receipt to the temporary directory.
  /// Returns the [File] ready for sharing via WhatsApp or printing.
  Future<File> generate(ReceiptModel receipt) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final fontItalic = await PdfGoogleFonts.notoSansItalic();

    // Load logo with priority: logo_yayasan.png -> logo.png -> fallback
    pw.MemoryImage? logoImage;
    for (final path in [
      'assets/images/logo_yayasan.png',
      'assets/images/logo.png',
    ]) {
      try {
        final byteData = await rootBundle.load(path);
        logoImage = pw.MemoryImage(byteData.buffer.asUint8List());
        break;
      } catch (_) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            logoImage = pw.MemoryImage(file.readAsBytesSync());
            break;
          }
        } catch (_) {}
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold, italic: fontItalic),
        build: (pw.Context context) {
          final terbilangText = Terbilang.convert(receipt.totalBayar);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── 1. Official School Letterhead (Kop Surat) ──
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // School / Yayasan Logo
                  if (logoImage != null)
                    pw.Container(
                      width: 68,
                      height: 68,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    )
                  else
                    pw.Container(
                      width: 44,
                      height: 44,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.green800, width: 1.5),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'ILMI',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                            color: PdfColors.green900,
                          ),
                        ),
                      ),
                    ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'YAYASAN BAITUL AKBAR PARABEK',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: PdfColors.grey800,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          receipt.namaSekolah.toUpperCase(),
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                            color: PdfColors.green900,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Jalan Jombang Astek, No.86, Kel. Lengkong Gudang Timur, '
                          'Kec. Serpong, Kota Tangerang Selatan, 15318',
                          style: const pw.TextStyle(
                            fontSize: 6.5,
                            color: PdfColors.grey700,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Telp: 021-5387768. • Email: yysn.baitulakbarparabek@gmail.com',
                          style: const pw.TextStyle(
                            fontSize: 6,
                            color: PdfColors.grey600,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              // Indonesian Double-line rule below Kop Surat
              pw.Divider(thickness: 1.5, color: PdfColors.black),
              pw.SizedBox(height: 1),
              pw.Divider(thickness: 0.5, color: PdfColors.black),
              pw.SizedBox(height: 6),

              // ── 2. Receipt Title & Number ──
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'KUITANSI PEMBAYARAN',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 11,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Nomor: ${receipt.nomorKuitansi}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 8.5,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // ── 3. Student & Transaction Details ──
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  children: [
                    _pdfRow(fontBold, font, 'Telah terima dari', receipt.namaLengkap),
                    _pdfRow(fontBold, font, 'Nomor Induk (NIS)', receipt.nis),
                    _pdfRow(fontBold, font, 'Tingkat / Kelas', receipt.kelas),
                    _pdfRow(fontBold, font, 'Waktu Transaksi', _dateFormat.format(receipt.tanggalBayar)),
                    _pdfRow(fontBold, font, 'Metode Bayar', receipt.metodeBayar),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // ── 4. Itemized Payment Breakdown ──
              pw.Text(
                'Rincian Alokasi Pembayaran:',
                style: pw.TextStyle(font: fontBold, fontSize: 8.5),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(5),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableCell('Uraian Pembayaran', fontBold, isHeader: true),
                      _tableCell('Jumlah Dibayar', fontBold, isHeader: true, alignRight: true),
                      _tableCell('Status Sisa', fontBold, isHeader: true, alignRight: true),
                    ],
                  ),
                  ...receipt.items.map(
                    (item) => pw.TableRow(
                      children: [
                        _tableCell(item.namaItem, font),
                        _tableCell(_idrFormat.format(item.nominalDibayar), font, alignRight: true),
                        _tableCell(
                          item.sisaTagihan > 0
                              ? _idrFormat.format(item.sisaTagihan)
                              : 'LUNAS',
                          fontBold,
                          alignRight: true,
                          isLunas: item.sisaTagihan == 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              // ── 5. Total and Terbilang (Words) ──
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL DITERIMA:',
                          style: pw.TextStyle(font: fontBold, fontSize: 9.5),
                        ),
                        pw.Text(
                          _idrFormat.format(receipt.totalBayar),
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 11,
                            color: PdfColors.green900,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terbilang: ',
                          style: pw.TextStyle(font: fontItalic, fontSize: 8, color: PdfColors.grey800),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '# $terbilangText #',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 8,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // ── 6. Signature Area ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Tangerang Selatan, ${_dateOnlyFormat.format(receipt.tanggalBayar)}',
                        style: pw.TextStyle(font: font, fontSize: 8),
                      ),
                      pw.Text(
                        'Petugas Keuangan / Kasir,',
                        style: pw.TextStyle(font: font, fontSize: 8),
                      ),
                      pw.SizedBox(height: 34),
                      pw.Text(
                        receipt.createdBy,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 8.5,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                      pw.Text(
                        receipt.operatorNip != null && receipt.operatorNip!.isNotEmpty
                            ? 'NIP: ${receipt.operatorNip}'
                            : 'Petugas Keuangan SIAK',
                        style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // ── 7. Formal Footer ──
              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Dicetak oleh Operator: ${receipt.createdBy} • SIAK-ILMI Mobile POS',
                    style: pw.TextStyle(font: font, fontSize: 6.5, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Kuitansi sah tanda bukti pembayaran resmi',
                    style: pw.TextStyle(font: fontItalic, fontSize: 6.5, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save to temp directory
    final dir = await getTemporaryDirectory();
    final fileName = 'KUITANSI_${receipt.nomorKuitansi.replaceAll("-", "_")}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _pdfRow(
    pw.Font bold,
    pw.Font regular,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey800),
            ),
          ),
          pw.Text(': ', style: pw.TextStyle(font: regular, fontSize: 8)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 8)),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    bool alignRight = false,
    bool isLunas = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.5,
          color: isLunas ? PdfColors.green800 : PdfColors.black,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
