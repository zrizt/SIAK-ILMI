/// Form validation utilities used across SIAK-ILMI input forms.
class InputValidators {
  InputValidators._();

  /// Validates that [value] is not null or empty.
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validates that [value] is a valid 6-digit numeric PIN.
  static String? pin(String? value) {
    if (value == null || value.trim().isEmpty) return 'PIN wajib diisi';
    if (value.length != 6) return 'PIN harus tepat 6 digit';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) return 'PIN hanya boleh angka';
    return null;
  }

  /// Validates a positive integer currency amount.
  static String? positiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nominal wajib diisi';
    final amount = int.tryParse(value.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) return 'Nominal harus lebih dari 0';
    return null;
  }

  /// Validates a valid year (2020-2035).
  static String? academicYear(String? value) {
    final y = int.tryParse(value ?? '');
    if (y == null || y < 2020 || y > 2035) {
      return 'Tahun tidak valid (2020-2035)';
    }
    return null;
  }

  /// Validates a phone number (optional field).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (value.length < 9 || value.length > 15) {
      return 'Nomor HP tidak valid';
    }
    return null;
  }

  /// Validates NISN: exactly 10 digits.
  static String? nisn(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'NISN harus 10 digit angka';
    }
    return null;
  }
}
