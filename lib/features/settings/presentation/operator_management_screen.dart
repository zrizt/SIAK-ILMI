import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/security/operator_service.dart';
import 'pin_auth_screen.dart';

/// Screen for managing SQLite-backed operator accounts.
/// Allows administrators to view, add, and activate/deactivate operators.
class OperatorManagementScreen extends ConsumerWidget {
  const OperatorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final role = ref.watch(authRoleProvider);
    final isAdmin = role == PinRole.admin;
    final operatorService = ref.watch(operatorServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Operator'),
      ),
      body: StreamBuilder<List<OperatorData>>(
        stream: operatorService.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: TextStyle(color: cs.error),
              ),
            );
          }

          final operators = snapshot.data ?? [];

          if (operators.isEmpty) {
            return const Center(
              child: Text('Belum ada akun operator yang terdaftar.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: operators.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final op = operators[index];
              final isActive = op.isActive == 1;

              return Card(
                elevation: 0,
                color: isActive
                    ? cs.surfaceContainerLow
                    : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isActive ? cs.outlineVariant : cs.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? cs.primaryContainer : cs.surfaceContainerHighest,
                    child: Icon(
                      Icons.person,
                      color: isActive ? cs.onPrimaryContainer : cs.outline,
                    ),
                  ),
                  title: Text(
                    op.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    '@${op.username}${op.nip != null && op.nip!.isNotEmpty ? ' • NIP: ${op.nip}' : ''} • Dibuat: ${op.createdAt.split("T").first}',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                  ),
                  trailing: isAdmin
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (val) async {
                            if (val == 'toggle') {
                              await operatorService.setActive(op.id, active: !isActive);
                            } else if (val == 'password') {
                              _showChangePasswordDialog(context, ref, op);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.block : Icons.check_circle_outline,
                                    size: 18,
                                    color: isActive ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'password',
                              child: Row(
                                children: [
                                  Icon(Icons.password, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ganti Password'),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Chip(
                          label: Text(
                            isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddOperatorDialog(context, ref),
              icon: const Icon(Icons.person_add),
              label: const Text('Operator Baru'),
            )
          : null,
    );
  }

  void _showAddOperatorDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final nipCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMsg;
    bool isSaving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dCtx, setDState) {
          return AlertDialog(
            title: const Text('Tambah Operator Baru'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Petugas *',
                      hintText: 'e.g. Ahmad Fauzi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nipCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NIP (Opsional)',
                      hintText: 'e.g. 198507122010011002',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username Login *',
                      hintText: 'e.g. fauzi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMsg!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        final nip = nipCtrl.text.trim();
                        final username = userCtrl.text.trim();
                        final password = passCtrl.text;
                        final confirm = confirmCtrl.text;

                        if (name.isEmpty || username.isEmpty || password.isEmpty) {
                          setDState(() => errorMsg = 'Nama, username, dan password wajib diisi');
                          return;
                        }

                        if (password.length < 6) {
                          setDState(() => errorMsg = 'Password minimal 6 karakter');
                          return;
                        }

                        if (password != confirm) {
                          setDState(() => errorMsg = 'Konfirmasi password tidak cocok');
                          return;
                        }

                        setDState(() {
                          isSaving = true;
                          errorMsg = null;
                        });

                        try {
                          await ref.read(operatorServiceProvider).createOperator(
                                fullName: name,
                                username: username,
                                password: password,
                                nip: nip.isNotEmpty ? nip : null,
                              );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Operator @$username berhasil dibuat'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setDState(() {
                            isSaving = false;
                            errorMsg = 'Gagal membuat operator (username mungkin sudah ada)';
                          });
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
    OperatorData op,
  ) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMsg;
    bool isSaving = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dCtx, setDState) {
          return AlertDialog(
            title: Text('Ganti Password @${op.username}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Saat Ini',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMsg!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final currentPass = oldPassCtrl.text;
                        final newPass = newPassCtrl.text;
                        final confirm = confirmCtrl.text;

                        if (currentPass.isEmpty || newPass.isEmpty) {
                          setDState(() => errorMsg = 'Semua field wajib diisi');
                          return;
                        }

                        if (newPass.length < 6) {
                          setDState(() => errorMsg = 'Password baru minimal 6 karakter');
                          return;
                        }

                        if (newPass != confirm) {
                          setDState(() => errorMsg = 'Konfirmasi password baru tidak cocok');
                          return;
                        }

                        setDState(() {
                          isSaving = true;
                          errorMsg = null;
                        });

                        final success = await ref.read(operatorServiceProvider).changePassword(
                              operatorId: op.id,
                              currentPassword: currentPass,
                              newPassword: newPass,
                            );

                        if (ctx.mounted) {
                          if (success) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password operator berhasil diubah'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setDState(() {
                              isSaving = false;
                              errorMsg = 'Password saat ini salah';
                            });
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ubah Password'),
              ),
            ],
          );
        },
      ),
    );
  }
}
