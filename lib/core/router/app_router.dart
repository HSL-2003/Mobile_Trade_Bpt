import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';

/// Notifier that triggers GoRouter refresh when auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isLoading != next.isLoading) {
        notifyListeners();
      }
    });
  }
}

/// Provider for GoRouter instance with auth guard.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Subscribes the router to auth-state changes.
  _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.isAuthenticated;
      final uri = state.uri;
      final isAuthRoute = uri.path == '/login' || uri.path == '/register' || uri.path == '/splash';
      final isCallback = uri.path == '/' || uri.path == '/auth-callback';

      if (isCallback) {
        return isAuth ? '/dashboard' : '/login';
      }

      if (isAuth && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },

    routes: [
      // Root redirect
      GoRoute(
        path: '/',
        redirect: (context, state) =>
            ref.read(authProvider).isAuthenticated ? '/dashboard' : '/login',
      ),

      // Supabase OAuth callback route
      GoRoute(
        path: '/auth-callback',
        redirect: (context, state) =>
            ref.read(authProvider).isAuthenticated ? '/dashboard' : '/login',
      ),
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Dashboard (protected route)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],

    // Error page for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 56,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Extension for convenient navigation.
extension GoRouterExtension on BuildContext {
  void goToSplash() => go('/splash');
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToDashboard() => go('/dashboard');
  void pushToRegister() => push('/register');
}
