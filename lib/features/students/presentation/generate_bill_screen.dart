import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/tarif_dao.dart';
import '../../../core/database/tables/kategori_biaya_table.dart'; // ignore: unused_import
import '../../../core/formatters/currency_formatter.dart'; // ignore: unused_import
import '../../fee_management/domain/bill_generator_engine.dart';
import '../../settings/presentation/pin_auth_screen.dart'; // ignore: unused_import

/// Screen allowing admin to generate a new fee bill for a student.
class GenerateBillScreen extends ConsumerStatefulWidget {
  const GenerateBillScreen({
    super.key,
    required this.siswaId,
    required this.tingkat,
  });

  final int siswaId;
  final int tingkat;

  @override
  ConsumerState<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends ConsumerState<GenerateBillScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final List<int> _selectedKategoriIds = [];
  bool _isLoading = false;

  late final TextEditingController _yearController;

  static const List<String> _indonesianMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: _selectedYear.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateBill(List<KategoriBiayaData> categories) async {
    if (_selectedKategoriIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu kategori biaya untuk ditagihkan'),
        ),
      );
      return;
    }

    final yearParsed = int.tryParse(_yearController.text.trim());
    if (yearParsed == null || yearParsed < 2000 || yearParsed > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan tahun yang valid (2000-2100)'),
        ),
      );
      return;
    }

    _selectedYear = yearParsed;
    final monthName = _indonesianMonths[_selectedMonth - 1];
    final periode = '$monthName $_selectedYear';

    setState(() => _isLoading = true);

    try {
      final categoryMap = {for (final k in categories) k.id: k.namaBiaya};

      final billItems = _selectedKategoriIds.map((kategoriId) {
        final namaBiaya = categoryMap[kategoriId] ?? 'Tagihan';
        return BillLineItemParam(
          kategoriBiayaId: kategoriId,
          namaItem: '$namaBiaya $monthName $_selectedYear',
          nominalDiskon: 0,
        );
      }).toList();

      await ref.read(billGeneratorEngineProvider).generateBill(
            siswaId: widget.siswaId,
            tingkat: widget.tingkat,
            periode: periode,
            items: billItems,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tagihan periode $periode berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat tagihan: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(appDatabaseProvider);
    final tarifDao = TarifDao(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tagihan Baru'),
      ),
      body: FutureBuilder<List<KategoriBiayaData>>(
        future: tarifDao.getAllKategori(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat kategori biaya: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Siswa',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tingkat: ${widget.tingkat}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Period Section
              Text(
                'Periode Tagihan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Dropdown
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Bulan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: List.generate(12, (index) {
                        final monthNum = index + 1;
                        return DropdownMenuItem<int>(
                          value: monthNum,
                          child: Text(_indonesianMonths[index]),
                        );
                      }),
                      onChanged: _isLoading
                          ? null
                          : (val) {
                              if (val != null) {
                                setState(() => _selectedMonth = val);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Year Field
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Tahun',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fee Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Kategori Biaya',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              if (_selectedKategoriIds.length ==
                                  categories.length) {
                                _selectedKategoriIds.clear();
                              } else {
                                _selectedKategoriIds
                                  ..clear()
                                  ..addAll(
                                    categories.map(
                                      (c) => c.id,
                                    ),
                                  );
                              }
                            });
                          },
                    child: Text(
                      _selectedKategoriIds.length == categories.length
                          ? 'Batal Pilih Semua'
                          : 'Pilih Semua',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (categories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada kategori biaya yang terdaftar.'),
                  ),
                )
              else
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final isSelected =
                          _selectedKategoriIds.contains(item.id);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(item.namaBiaya),
                        subtitle: Text(
                          'Tipe: ${item.tipe}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        onChanged: _isLoading
                            ? null
                            : (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedKategoriIds.add(item.id);
                                  } else {
                                    _selectedKategoriIds.remove(item.id);
                                  }
                                });
                              },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _handleGenerateBill(categories),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(
                  _isLoading ? 'Memproses Tagihan...' : 'Buat Tagihan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
