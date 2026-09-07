import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/user_profile.dart';
import '../repositories/auth_repository.dart';
import 'auth_provider.dart';

/// StateNotifier that manages user profile state.
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final AuthRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  /// Fetches fresh user profile including real-time balance.
  Future<void> fetchProfile() async {
    final result = await _repository.getProfile();
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      state = AsyncValue.data(result.data!);
    } else {
      state = AsyncValue.error(
        result.error ?? 'Failed to load profile',
        StackTrace.current,
      );
    }
  }

  /// Silently refresh profile data without setting state to loading.
  Future<void> refresh() async {
    final result = await _repository.getProfile();
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      state = AsyncValue.data(result.data!);
    }
  }
}

/// Provider for the full UserProfile state.
final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ProfileNotifier(repository);
});

/// Convenience provider for the currently loaded UserProfile object (or null).
final userProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(profileProvider).valueOrNull;
});

/// Convenience provider for real-time account balance.
final userBalanceProvider = Provider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.finance.balance ?? 10000.0;
});

/// Convenience provider for real-time account equity.
final userEquityProvider = Provider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.finance.equity ?? 10000.0;
});
