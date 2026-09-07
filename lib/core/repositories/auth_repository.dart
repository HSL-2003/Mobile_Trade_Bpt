import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';
import '../api/api_exceptions.dart';
import '../api/user_profile.dart';
import 'result.dart';
abstract class AuthRepository {
  Future<RepositoryResult<AuthResult>> login({
    required String email,
    required String password,
  });

  Future<RepositoryResult<AuthResult>> register({
    required String email,
    required String password,
    String? displayName,
  });

  Future<RepositoryResult<void>> logout();

  Future<RepositoryResult<CurrentUser?>> getCurrentUser();

  Future<RepositoryResult<UserProfile>> getProfile();

  Future<bool> isAuthenticated();

  Future<RepositoryResult<AuthResult>> socialCallback(String supabaseToken);
}
/// Concrete implementation of [AuthRepository] using [AuthApi].
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;

  AuthRepositoryImpl(this._authApi);

  @override
  Future<RepositoryResult<AuthResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 [AuthRepo] Attempting login for: $email');
      final result = await _authApi.login(email: email, password: password);
      debugPrint('✅ [AuthRepo] Login successful for: $email');
      return RepositoryResult.success(result);
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Login failed: ${e.message}');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return RepositoryResult.failure(e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthRepo] Unexpected error during login: $e');
      debugPrint('   Stack trace: $stackTrace');
      return RepositoryResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<RepositoryResult<AuthResult>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await _authApi.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return RepositoryResult.success(result);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<RepositoryResult<void>> logout() async {
    try {
      await _authApi.logout();
      return RepositoryResult.success(null);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<RepositoryResult<CurrentUser?>> getCurrentUser() async {
    try {
      final user = await _authApi.getCurrentUser();
      return RepositoryResult.success(user);
    } on UnauthorizedException {
      return RepositoryResult.success(null);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('An unexpected error occurred');
    }
  }
  @override
  Future<RepositoryResult<UserProfile>> getProfile() async {
    try {
      debugPrint('👤 [AuthRepo] Fetching full user profile');
      final profile = await _authApi.getProfile();
      debugPrint('✅ [AuthRepo] Profile loaded: ${profile.displayName} (Balance: \$${profile.finance.balance})');
      return RepositoryResult.success(profile);
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Failed to fetch profile: ${e.message}');
      return RepositoryResult.failure(e.message);
    } catch (e, stack) {
      debugPrint('❌ [AuthRepo] Unexpected error in getProfile: $e\n$stack');
      return RepositoryResult.failure('An unexpected error occurred');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final result = await getCurrentUser();
    return result.isSuccess && result.data != null;
  }

  @override
  Future<RepositoryResult<AuthResult>> socialCallback(String supabaseToken) async {
    try {
      debugPrint('🌐 [AuthRepo] Exchanging Supabase OAuth token with backend');
      final result = await _authApi.socialCallback(supabaseToken);
      debugPrint('✅ [AuthRepo] Social callback exchange successful for user: ${result.userId}');
      return RepositoryResult.success(result);
    } on ApiException catch (e) {
      debugPrint('❌ [AuthRepo] Social callback exchange failed: ${e.message}');
      return RepositoryResult.failure(e.message);
    } catch (e) {
      debugPrint('❌ [AuthRepo] Unexpected error during social callback: $e');
      return RepositoryResult.failure(e.toString());
    }
  }
}
