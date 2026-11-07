import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/pin_service.dart';
export '../../../core/security/pin_service.dart';

/// Provider holding the currently authenticated role (null = unauthenticated)
final authRoleProvider = StateProvider<PinRole?>((ref) => null);

/// Inactivity timer for auto-lock (5 minutes per PRD Section 4.2)
final inactivityTimerProvider = StateProvider<Timer?>((ref) => null);

/// Resets the 5-minute auto-lock inactivity timer.
void resetInactivityTimer(WidgetRef ref) {
  if (ref.read(authRoleProvider) == null) return;
  ref.read(inactivityTimerProvider.notifier).state?.cancel();
  ref.read(inactivityTimerProvider.notifier).state = Timer(
    const Duration(minutes: 5),
    () {
      ref.read(authRoleProvider.notifier).state = null;
    },
  );
}

class PinAuthScreen extends ConsumerStatefulWidget {
  const PinAuthScreen({super.key});

  @override
  ConsumerState<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends ConsumerState<PinAuthScreen> {
  final List<String> _pin = [];
  bool _isError = false;
  bool _isLoading = false;
  static const _pinLength = 6;

  void _addDigit(String digit) {
    if (_pin.length >= _pinLength || _isLoading) return;
    setState(() {
      _pin.add(digit);
      _isError = false;
    });
    if (_pin.length == _pinLength) _verifyPin();
  }

  void _removeDigit() {
    if (_pin.isEmpty) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    final pin = _pin.join();
    final role = await PinService.verifyPin(pin);
    if (!mounted) return;

    if (role != null) {
      ref.read(authRoleProvider.notifier).state = role;
      resetInactivityTimer(ref);
    } else {
      setState(() {
        _pin.clear();
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Replaceable Logo PNG (assets/images/logo.png)
                  Image.asset(
                    'assets/images/logo.png',
                    height: 72,
                    width: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SIAK-ILMI',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Darul Ilmi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    'Masukkan PIN 6 Digit',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // PIN dots
                  _PinDots(
                    filled: _pin.length,
                    total: _pinLength,
                    isError: _isError,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: _isError ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'PIN salah. Coba lagi.',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Number pad
                  _NumPad(
                    onDigit: _addDigit,
                    onDelete: _removeDigit,
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.filled,
    required this.total,
    required this.isError,
    required this.isLoading,
  });
  final int filled;
  final int total;
  final bool isError;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const CircularProgressIndicator();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isError
                ? Theme.of(context).colorScheme.error
                : isFilled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
          ),
        );
      }),
    );
  }
}

class _NumPad extends StatelessWidget {
  const _NumPad({
    required this.onDigit,
    required this.onDelete,
    required this.enabled,
  });
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', '<',
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: buttons.map((b) {
        if (b.isEmpty) return const SizedBox();
        if (b == '<') {
          return TextButton(
            onPressed: enabled ? onDelete : null,
            child: const Icon(Icons.backspace_outlined, size: 22),
          );
        }
        return OutlinedButton(
          onPressed: enabled ? () => onDigit(b) : null,
          child: Text(
            b,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }
}
