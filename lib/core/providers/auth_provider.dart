import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/auth_api.dart';
import '../repositories/auth_repository.dart';
import 'api_provider.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApi(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthRepositoryImpl(authApi);
});

@immutable
class AuthState {
  final CurrentUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    CurrentUser? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(CurrentUser user) =>
      AuthState(user: user, isAuthenticated: true);
  factory AuthState.unauthenticated() => const AuthState();
  factory AuthState.error(String message) => AuthState(error: message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Listen to Supabase auth state changes for OAuth callbacks
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        final event = data.event;
        debugPrint('⚡ [Supabase Auth Event] $event');
        if (session != null &&
            (event == AuthChangeEvent.signedIn ||
             event == AuthChangeEvent.tokenRefreshed ||
             event == AuthChangeEvent.initialSession)) {
          final user = session.user;
          // Exchange Supabase token with backend session to enable full API access
          try {
            final exchangeResult = await _authRepository.socialCallback(session.accessToken);
            if (exchangeResult.data != null) {
              final authResult = exchangeResult.data!;
              state = AuthState.authenticated(
                CurrentUser(
                  userId: authResult.userId,
                  accountId: authResult.accountId,
                  roles: authResult.roles,
                  email: user.email,
                  displayName: user.userMetadata?['full_name']?.toString() ??
                      user.userMetadata?['name']?.toString() ??
                      user.email?.split('@').first,
                ),
              );
              return;
            }
          } catch (e) {
            debugPrint('⚠️ [AuthNotifier] Backend session exchange error: $e');
          }

          // Fallback to Supabase user info
          state = AuthState.authenticated(
            CurrentUser(
              userId: user.id,
              accountId: user.userMetadata?['account_id']?.toString() ?? user.id,
              roles: const ['trader'],
              email: user.email,
              displayName: user.userMetadata?['full_name']?.toString() ??
                  user.userMetadata?['name']?.toString() ??
                  user.email?.split('@').first,
            ),
          );
        } else if (event == AuthChangeEvent.signedOut) {
          state = AuthState.unauthenticated();
        }
      });

      final result = await _authRepository.getCurrentUser();
      if (result.data != null) {
        state = AuthState.authenticated(result.data!);
      } else {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          final user = session.user;
          state = AuthState.authenticated(
            CurrentUser(
              userId: user.id,
              accountId: user.userMetadata?['account_id']?.toString() ?? user.id,
              roles: const ['trader'],
              email: user.email,
              displayName: user.userMetadata?['full_name']?.toString() ??
                  user.userMetadata?['name']?.toString() ??
                  user.email?.split('@').first,
            ),
          );
        } else {
          state = AuthState.unauthenticated();
        }
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepository.login(email: email, password: password);
      if (result.data != null) {
        // Extract user from auth result
        final authResult = result.data!;
        state = AuthState.authenticated(
          CurrentUser(
            userId: authResult.userId,
            accountId: authResult.accountId,
            roles: authResult.roles,
            // email will be fetched from getCurrentUser
          ),
        );
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, 
            error: result.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (result.data != null) {
        // Extract user from auth result
        final authResult = result.data!;
        state = AuthState.authenticated(
          CurrentUser(
            userId: authResult.userId,
            accountId: authResult.accountId,
            roles: authResult.roles,
            // email will be fetched from getCurrentUser
            displayName: displayName,
          ),
        );
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, 
            error: result.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final supabase = Supabase.instance.client;
      
      // For web
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: '/',
          queryParams: {
            'access_type': 'offline',
            'prompt': 'consent',
          },
        );
      } else {
        // For mobile
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'bottrade://auth-callback',
          queryParams: {
            'access_type': 'offline',
            'prompt': 'consent',
          },
        );
      }
      
      debugPrint('🌐 [Google OAuth] Started authentication flow');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loginWithGitHub() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final supabase = Supabase.instance.client;
      
      // For web
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(
          OAuthProvider.github,
          redirectTo: '/',
        );
      } else {
        // For mobile
        await supabase.auth.signInWithOAuth(
          OAuthProvider.github,
          redirectTo: 'bottrade://auth-callback',
        );
      }
      
      debugPrint('🌐 [GitHub OAuth] Started authentication flow');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.logout();
      // Also sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
      
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<CurrentUser?>((ref) {
  return ref.watch(authProvider).user;
});