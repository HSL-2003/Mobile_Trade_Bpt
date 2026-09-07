import 'api_client.dart';
import 'api_exceptions.dart';
import 'user_profile.dart';
/// Result of a successful authentication operation.
class AuthResult {
  /// Bearer token returned by the server.
  final String accessToken;

  /// Token type (always "bearer" from FastAPI).
  final String tokenType;

  /// When the session expires.
  final DateTime expiresAt;

  /// Supabase user ID.
  final String userId;

  /// Account ID the user belongs to.
  final String accountId;

  /// Roles assigned to the user (e.g. ["trader"], ["admin"]).
  final List<String> roles;

  const AuthResult({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
    required this.userId,
    required this.accountId,
    required this.roles,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'bearer',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['trader'],
    );
  }
}

/// Lightweight view of the currently authenticated user.
class CurrentUser {
  final String userId;
  final String accountId;
  final List<String> roles;
  final String? email;
  final String? displayName;

  const CurrentUser({
    required this.userId,
    required this.accountId,
    required this.roles,
    this.email,
    this.displayName,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      userId: json['user_id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['trader'],
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
    );
  }

  bool get isAdmin => roles.contains('admin');
}

/// API client for authentication endpoints defined in `app.py`.
///
/// Endpoints:
///  - `POST /api/auth/register`
///  - `POST /api/auth/login`
///  - `POST /api/auth/logout`
///  - `GET  /api/auth/me`
class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  /// Creates a new user account and returns a session.
  ///
  /// Throws:
  ///  - [ValidationException] if the server rejects the payload (422).
  ///  - [ApiException] if the email is already taken or the server errors.
  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        if (displayName != null) 'display_name': displayName,
      },
    );
    final authResult = AuthResult.fromJson(response.data!);
    _client.setAuthToken(authResult.accessToken);
    return authResult;
  }

  /// Authenticates an existing user and returns a session.
  ///
  /// Throws:
  ///  - [UnauthorizedException] if credentials are invalid (401).
  ///  - [ValidationException] if the payload is malformed (422).
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final authResult = AuthResult.fromJson(response.data!);
    _client.setAuthToken(authResult.accessToken);
    return authResult;
  }
  /// Exchanges a Supabase OAuth token for a FastAPI application session.
  ///
  /// Endpoint: `POST /api/auth/social/callback`
  Future<AuthResult> socialCallback(String supabaseToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/social/callback',
      data: {'token': supabaseToken},
    );
    final authResult = AuthResult.fromJson(response.data!);
    _client.setAuthToken(authResult.accessToken);
    return authResult;
  }

  /// Revokes the current session on the server.
  ///
  /// Returns normally on success (HTTP 204). The caller is responsible for
  /// clearing any local session state (e.g. Supabase signOut).
  ///
  /// Throws [UnauthorizedException] if the token is already invalid.
  Future<void> logout() async {
    _client.setAuthToken(null);
    await _client.post<void>('/api/auth/logout');
  }

  /// Returns the currently authenticated user's profile.
  Future<CurrentUser> getCurrentUser() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/auth/me',
    );
    return CurrentUser.fromJson(response.data!);
  }

  /// Fetches the user's full profile including financial balance and broker info.
  Future<UserProfile> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/profile',
    );
    return UserProfile.fromJson(response.data!);
  }
}
