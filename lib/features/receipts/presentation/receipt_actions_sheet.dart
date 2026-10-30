import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../data/pdf_receipt_generator.dart';
import '../data/thermal_printer_adapter.dart';
import '../domain/receipt_model.dart';

/// Bottom sheet with actions: print thermal, export PDF, share via WhatsApp.
class ReceiptActionsSheet extends ConsumerStatefulWidget {
  const ReceiptActionsSheet({super.key, required this.receipt});
  final ReceiptModel receipt;

  @override
  ConsumerState<ReceiptActionsSheet> createState() =>
      _ReceiptActionsSheetState();
}

class _ReceiptActionsSheetState extends ConsumerState<ReceiptActionsSheet> {
  bool _isPrinting = false;
  bool _isGeneratingPdf = false;

  Future<void> _printThermal() async {
    setState(() => _isPrinting = true);
    try {
      final adapter = ref.read(thermalPrinterAdapterProvider);
      final connected = await adapter.isConnected;
      if (!connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Printer Bluetooth tidak terhubung. Sambungkan printer terlebih dahulu.'),
            ),
          );
        }
        return;
      }
      final success = await adapter.printReceipt(widget.receipt);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Kuitansi berhasil dicetak'
                : 'Gagal mencetak. Periksa koneksi printer.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _generateAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final generator = ref.read(pdfReceiptGeneratorProvider);
      final file = await generator.generate(widget.receipt);
      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Kuitansi ${widget.receipt.nomorKuitansi}',
          text:
              'Kuitansi pembayaran untuk ${widget.receipt.namaLengkap} (NIS: ${widget.receipt.nis})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _previewPdf() async {
    final generator = ref.read(pdfReceiptGeneratorProvider);
    final file = await generator.generate(widget.receipt);
    if (mounted) {
      await Printing.layoutPdf(
        onLayout: (_) async => file.readAsBytes(),
        name: 'Kuitansi_${widget.receipt.nomorKuitansi}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: _isPrinting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print),
            title: const Text('Cetak Thermal (Bluetooth)'),
            subtitle: const Text('Printer ESC/POS 58mm'),
            onTap: _isPrinting ? null : _printThermal,
          ),
          ListTile(
            leading: _isGeneratingPdf
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            title: const Text('Bagikan PDF (WhatsApp)'),
            subtitle: const Text('Export & share PDF kuitansi'),
            onTap: _isGeneratingPdf ? null : _generateAndSharePdf,
          ),
          ListTile(
            leading: const Icon(Icons.preview),
            title: const Text('Preview PDF'),
            onTap: _previewPdf,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Tutup'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
