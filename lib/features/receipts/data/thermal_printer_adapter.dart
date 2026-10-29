import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../domain/receipt_model.dart';

final thermalPrinterAdapterProvider =
    Provider<ThermalPrinterAdapter>((ref) => ThermalPrinterAdapter());

/// State of the Bluetooth thermal printer connection.
enum PrinterState { disconnected, connecting, connected, printing, error }

/// Adapter for Bluetooth ESC/POS thermal receipt printing.
/// Wraps [BlueThermalPrinter] and [esc_pos_utils_plus] generators.
class ThermalPrinterAdapter {
  final _printer = BlueThermalPrinter.instance;

  /// Lists available Bluetooth devices.
  Future<List<BluetoothDevice>> listDevices() async {
    try {
      return await _printer.getBondedDevices();
    } catch (_) {
      return [];
    }
  }

  /// Connects to a Bluetooth printer device.
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _printer.connect(device);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Disconnects from the current printer.
  Future<void> disconnect() async {
    try {
      await _printer.disconnect();
    } catch (_) {}
  }

  /// Checks if currently connected to a printer.
  Future<bool> get isConnected async {
    try {
      return await _printer.isConnected ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Prints a [ReceiptModel] using ESC/POS commands.
  /// Returns true on success, false on any error.
  Future<bool> printReceipt(ReceiptModel receipt) async {
    try {
      final connected = await isConnected;
      if (!connected) return false;

      // Build ESC/POS byte commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = [];

      // ── Header ──────────────────────────────────────────
      bytes += generator.text(
        receipt.namaSekolah,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      );
      bytes += generator.text(
        'KUITANSI PEMBAYARAN',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      // ── Metadata ─────────────────────────────────────────
      bytes += generator.row([
        PosColumn(text: 'No. Kuitansi', width: 6),
        PosColumn(
            text: ': ${receipt.nomorKuitansi}',
            width: 6,
            styles: const PosStyles(bold: true)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Tanggal', width: 6),
        PosColumn(
            text:
                ': ${DateFormatter.toDisplay(receipt.tanggalBayar)}',
            width: 6),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Nama Siswa', width: 6),
        PosColumn(
            text: ': ${receipt.namaLengkap}',
            width: 6,
            styles: const PosStyles(bold: true)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'NIS', width: 6),
        PosColumn(text: ': ${receipt.nis}', width: 6),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Kelas', width: 6),
        PosColumn(text: ': ${receipt.kelas}', width: 6),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Metode', width: 6),
        PosColumn(text: ': ${receipt.metodeBayar}', width: 6),
      ]);
      bytes += generator.hr();

      // ── Line Items ────────────────────────────────────────
      bytes += generator.text(
        'RINCIAN PEMBAYARAN',
        styles: const PosStyles(
            bold: true, align: PosAlign.center),
      );
      for (final item in receipt.items) {
        bytes += generator.text(
          item.namaItem,
          styles: const PosStyles(bold: true),
        );
        bytes += generator.row([
          PosColumn(
              text:
                  '  Dibayar: ${CurrencyFormatter.format(item.nominalDibayar)}',
              width: 8),
          PosColumn(
              text: item.sisaTagihan > 0
                  ? 'Sisa: ${CurrencyFormatter.format(item.sisaTagihan)}'
                  : 'LUNAS',
              width: 4,
              styles: PosStyles(
                  bold: item.sisaTagihan == 0,
                  align: PosAlign.right)),
        ]);
      }
      bytes += generator.hr();

      // ── Total ─────────────────────────────────────────────
      bytes += generator.row([
        PosColumn(
            text: 'TOTAL BAYAR',
            width: 6,
            styles: const PosStyles(bold: true)),
        PosColumn(
            text: CurrencyFormatter.format(receipt.totalBayar),
            width: 6,
            styles: const PosStyles(
                bold: true, align: PosAlign.right)),
      ]);
      bytes += generator.hr();

      // ── Footer ────────────────────────────────────────────
      bytes += generator.text(
        'Petugas: ${receipt.createdBy}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Dokumen sah \u2014 SIAK-ILMI',
        styles: const PosStyles(
            align: PosAlign.center, italic: true),
      );
      bytes += generator.feed(3);
      bytes += generator.cut();

      // Send to printer
      await _printer.writeBytes(Uint8List.fromList(bytes));
      return true;
    } catch (_) {
      return false;
    }
  }
}
