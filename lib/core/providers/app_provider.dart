import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the global application state.
@immutable
class AppState {
  final bool isLoading;
  final String? errorMessage;

  const AppState({
    this.isLoading = false,
    this.errorMessage,
  });

  AppState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for global app state (loading, errors).
class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, clearError: true);
  }

  void setError(String message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const AppState();
  }
}

/// Provider for global app state.
final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});

/// Generic async state wrapper for data fetching operations.
@immutable
class AsyncState<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  const AsyncState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  AsyncState<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AsyncState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  factory AsyncState.loading() => const AsyncState(isLoading: true);
  factory AsyncState.data(T data) => AsyncState(data: data);
  factory AsyncState.error(String message) => AsyncState(error: message);
}
