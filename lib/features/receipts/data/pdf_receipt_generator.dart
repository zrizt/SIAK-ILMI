import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/receipt_model.dart';

final pdfReceiptGeneratorProvider =
    Provider<PdfReceiptGenerator>((ref) => const PdfReceiptGenerator());

/// Generates a WhatsApp-shareable A5 PDF receipt.
class PdfReceiptGenerator {
  const PdfReceiptGenerator();

  static final _idrFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

  /// Builds and saves the PDF to app's temp directory.
  /// Returns the [File] path for sharing.
  Future<File> generate(ReceiptModel receipt) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      receipt.namaSekolah,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 13,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'KUITANSI PEMBAYARAN',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),

              // Receipt metadata
              _pdfRow(fontBold, font, 'No. Kuitansi', receipt.nomorKuitansi),
              _pdfRow(fontBold, font, 'Tanggal',
                  _dateFormat.format(receipt.tanggalBayar)),
              _pdfRow(fontBold, font, 'Nama Siswa', receipt.namaLengkap),
              _pdfRow(fontBold, font, 'NIS', receipt.nis),
              _pdfRow(fontBold, font, 'Kelas', receipt.kelas),
              _pdfRow(fontBold, font, 'Metode Bayar', receipt.metodeBayar),
              pw.SizedBox(height: 12),

              // Line items table
              pw.Text(
                'Rincian Pembayaran:',
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(3),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableCell('Keterangan', fontBold, isHeader: true),
                      _tableCell('Dibayar', fontBold, isHeader: true),
                      _tableCell('Sisa', fontBold, isHeader: true),
                    ],
                  ),
                  // Item rows
                  ...receipt.items.map(
                    (item) => pw.TableRow(
                      children: [
                        _tableCell(item.namaItem, font),
                        _tableCell(
                            _idrFormat.format(item.nominalDibayar), font),
                        _tableCell(
                            item.sisaTagihan > 0
                                ? _idrFormat.format(item.sisaTagihan)
                                : 'LUNAS',
                            font,
                            isLunas: item.sisaTagihan == 0),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration:
                    const pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL PEMBAYARAN',
                      style:
                          pw.TextStyle(font: fontBold, fontSize: 11),
                    ),
                    pw.Text(
                      _idrFormat.format(receipt.totalBayar),
                      style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 11,
                          color: PdfColors.green800),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Petugas,',
                        style: pw.TextStyle(font: font, fontSize: 9),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        '( ${receipt.createdBy} )',
                        style: pw.TextStyle(font: font, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),
              // Footer
              pw.Center(
                child: pw.Text(
                  'Dicetak oleh SIAK-ILMI \u2022 Dokumen ini sah tanpa tanda tangan basah',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 7,
                      color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center,
                ),
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
      pw.Font bold, pw.Font regular, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(label,
                style: pw.TextStyle(font: regular, fontSize: 9,
                    color: PdfColors.grey700)),
          ),
          pw.Text(': ',
              style: pw.TextStyle(font: regular, fontSize: 9)),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(font: bold, fontSize: 9)),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    bool isLunas = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          color: isLunas ? PdfColors.green700 : PdfColors.black,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
