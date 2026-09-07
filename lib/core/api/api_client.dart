import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient;
import 'api_exceptions.dart';
/// Central Dio HTTP client configured for the FastAPI backend.
///
/// Features:
///  - Base URL points to the FastAPI [app.py] server.
///  - Attaches the Supabase session access-token via an interceptor
///    so every authenticated request carries `Authorization: Bearer <token>`.
///  - Translates [DioException] into domain-specific [ApiException] subtypes.
///  - Built-in retry with exponential backoff for transient failures.
class ApiClient {
  final Dio _dio;
  final SupabaseClient _supabase;
  String? _authToken;

  String? get authToken => _authToken;
  void setAuthToken(String? token) {
    _authToken = token;
  }
  /// Base URL for the FastAPI backend (auto-routes to 10.0.2.2 on Android emulator).
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }
  /// Maximum number of retry attempts for transient errors.
  static const int maxRetries = 3;

  /// Initial backoff duration (doubles each retry).
  static const Duration initialBackoff = Duration(milliseconds: 500);

  ApiClient({
    String? baseUrl,
    SupabaseClient? supabase,
    Dio? dio,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ??
                  (const String.fromEnvironment('API_BASE_URL').isNotEmpty
                      ? const String.fromEnvironment('API_BASE_URL')
                      : defaultBaseUrl),
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
              contentType: Headers.jsonContentType,
            )) {
    _setupInterceptors();
  }

  /// The underlying [Dio] instance (useful for testing / custom requests).
  Dio get dio => _dio;

  // ---------------------------------------------------------------------------
  // Interceptor setup
  // ---------------------------------------------------------------------------

  void _setupInterceptors() {
    _dio.interceptors.clear();

    // -- Auth interceptor: attach session token ------------------------------
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final session = _supabase.auth.currentSession;
        final token = _authToken ?? (session != null && session.accessToken.isNotEmpty ? session.accessToken : null);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('🌐 [ApiClient] ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('📥 [ApiClient] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (DioException error, handler) {
        debugPrint('❌ [ApiClient] Error ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}: ${error.message}');
        if (error.response?.data != null) {
          debugPrint('   Response body: ${error.response?.data}');
        }
        handler.reject(error.copyWith(error: _translateDioError(error)));
      },
    ));
  }

  // ---------------------------------------------------------------------------
  // Public HTTP helpers with retry
  // ---------------------------------------------------------------------------

  /// Performs a GET request with automatic retry on transient failures.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _retry(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  /// Performs a POST request with automatic retry on transient failures.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _retry(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  // ---------------------------------------------------------------------------
  // Retry logic
  // ---------------------------------------------------------------------------

  /// Executes [request] up to [maxRetries] times with exponential backoff.
  /// Only retries on network errors or 5xx server errors.
  Future<Response<T>> _retry<T>(Future<Response<T>> Function() request) async {
    int attempt = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        attempt++;
        final isRetryable = _isRetryable(e);
        if (!isRetryable || attempt >= maxRetries) {
          throw _translateDioError(e);
        }
        final delay = initialBackoff * (1 << (attempt - 1)); // 500ms, 1s, 2s
        await Future<void>.delayed(delay);
      }
    }
  }

  /// Returns `true` when the error is transient and safe to retry.
  bool _isRetryable(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // DioException -> ApiException translation
  // ---------------------------------------------------------------------------

  /// Converts a [DioException] into a domain-specific [ApiException].
  ApiException _translateDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;

    // Try to extract a human-readable message from the response body.
    String message = error.message ?? 'Unknown error';
    if (body is Map<String, dynamic>) {
      message = body['detail'] as String? ??
          body['message'] as String? ??
          message;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Request timed out — $message');

      case DioExceptionType.connectionError:
        return NetworkException(message: message);

      case DioExceptionType.badResponse:
        return _mapStatusCode(statusCode, message, body);

      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled');

      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }

  /// Maps an HTTP status code to the appropriate [ApiException] subtype.
  ApiException _mapStatusCode(
    int? statusCode,
    String message,
    dynamic body,
  ) {
    switch (statusCode) {
      case 401:
      case 403:
        return UnauthorizedException(message: message);

      case 422:
        final details = _parseValidationDetails(body);
        return ValidationException(message: message, details: details);

      case 429:
        int? retryAfter;
        if (body is Map<String, dynamic>) {
          final raw = body['retry_after'];
          if (raw is int) retryAfter = raw;
        }
        return RateLimitException(message: message, retryAfter: retryAfter);

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message: message, statusCode: statusCode);

      default:
        return ApiException(message, statusCode: statusCode);
    }
  }

  /// Extracts per-field validation errors from a 422 response body.
  Map<String, List<String>> _parseValidationDetails(dynamic body) {
    final result = <String, List<String>>{};
    if (body is! Map<String, dynamic>) return result;

    final detail = body['detail'];
    if (detail is List) {
      // FastAPI default format: [{loc: ["body","field"], msg: "...", ...}]
      for (final item in detail) {
        if (item is Map<String, dynamic>) {
          final loc = item['loc'] as List<dynamic>?;
          final msg = item['msg'] as String? ?? 'Invalid value';
          if (loc != null && loc.isNotEmpty) {
            final field = loc.last.toString();
            result.putIfAbsent(field, () => []).add(msg);
          }
        }
      }
    }
    return result;
  }
}
