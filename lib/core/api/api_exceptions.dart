/// Custom exception classes for API error handling.
///
/// These exceptions wrap [DioException] into domain-specific types
/// so that UI layers can react appropriately (show login screen,
/// display retry dialog, etc.).
library;

/// Base class for all API-related exceptions.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Thrown when the server returns a 401 (unauthenticated) or 403 (forbidden).
/// Typically signals that the session token is invalid or expired.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({String message = 'Authentication required'})
      : super(message, statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Thrown when the server returns a 422 (validation error).
/// The [details] map contains field-level error messages.
class ValidationException extends ApiException {
  /// Keyed by field name, value is a list of error messages for that field.
  final Map<String, List<String>> details;

  const ValidationException({
    String message = 'Validation failed',
    this.details = const {},
  }) : super(message, statusCode: 422);

  @override
  String toString() => 'ValidationException: $message — $details';
}

/// Thrown when the server returns a 429 (rate-limit exceeded).
/// The [retryAfter] hint (in seconds) comes from the server when available.
class RateLimitException extends ApiException {
  /// Seconds to wait before retrying, if provided by the server.
  final int? retryAfter;

  const RateLimitException({String message = 'Too many requests', this.retryAfter})
      : super(message, statusCode: 429);

  @override
  String toString() => 'RateLimitException: $message (retryAfter: $retryAfter)';
}

/// Thrown when the server returns a 5xx response or when the client
/// cannot reach the server at all (network error, timeout, etc.).
class ServerException extends ApiException {
  const ServerException({String message = 'Server error', int? statusCode})
      : super(message, statusCode: statusCode);

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Thrown when the client cannot connect to the server
/// (DNS failure, no internet, connection refused, timeout).
class NetworkException extends ApiException {
  const NetworkException({String message = 'Network connection failed'})
      : super(message, statusCode: null);

  @override
  String toString() => 'NetworkException: $message';
}
