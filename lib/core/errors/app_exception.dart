/// Base exception class for SIAK-ILMI domain errors.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when an input or business validation fails.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Thrown when NIS generation fails (e.g., sequence > 999).
final class NisGenerationException extends AppException {
  const NisGenerationException(super.message);
}

/// Thrown when a payment amount exceeds the remaining arrears.
final class OverpaymentException extends AppException {
  const OverpaymentException(super.message);
}

/// Thrown when a record is not found.
final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Wraps backup-related failures (fail-silent; should not reach core UI).
final class BackupException extends AppException {
  const BackupException(super.message);
}

/// Thrown for RBAC violations (Viewer trying to exec Admin-only ops).
final class AuthorizationException extends AppException {
  const AuthorizationException(super.message);
}
