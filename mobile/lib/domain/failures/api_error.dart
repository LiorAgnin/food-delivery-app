/// Closed set from `docs/CONTRACT.md`, plus the client-only codes the
/// wire never sends: [network], [timeout], [malformed], [unknown].
enum ApiErrorCode {
  validationFailed,
  unauthorized,
  notFound,
  invalidTransition,
  concurrentUpdate,
  idempotencyConflict,
  restaurantClosed,
  itemUnavailable,
  itemNotInRestaurant,
  belowMinimum,
  otpInvalid,
  otpExpired,
  otpTooManyAttempts,
  internal,
  network,
  timeout,
  malformed,
  unknown,
}

/// Maps a contract `error.code`. Anything outside the closed set is
/// [ApiErrorCode.unknown] so a new server code cannot crash the client.
ApiErrorCode apiErrorCodeFromWire(String code) {
  return switch (code) {
    'VALIDATION_FAILED' => ApiErrorCode.validationFailed,
    'UNAUTHORIZED' => ApiErrorCode.unauthorized,
    'NOT_FOUND' => ApiErrorCode.notFound,
    'INVALID_TRANSITION' => ApiErrorCode.invalidTransition,
    'CONCURRENT_UPDATE' => ApiErrorCode.concurrentUpdate,
    'IDEMPOTENCY_CONFLICT' => ApiErrorCode.idempotencyConflict,
    'RESTAURANT_CLOSED' => ApiErrorCode.restaurantClosed,
    'ITEM_UNAVAILABLE' => ApiErrorCode.itemUnavailable,
    'ITEM_NOT_IN_RESTAURANT' => ApiErrorCode.itemNotInRestaurant,
    'BELOW_MINIMUM' => ApiErrorCode.belowMinimum,
    'OTP_INVALID' => ApiErrorCode.otpInvalid,
    'OTP_EXPIRED' => ApiErrorCode.otpExpired,
    'OTP_TOO_MANY_ATTEMPTS' => ApiErrorCode.otpTooManyAttempts,
    'INTERNAL' => ApiErrorCode.internal,
    _ => ApiErrorCode.unknown,
  };
}

final class ApiError implements Exception {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  final ApiErrorCode code;
  final String message;
  final Object? details;
  final int? statusCode;

  @override
  String toString() => 'ApiError(${code.name}, $message)';
}
