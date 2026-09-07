import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dashboard_api.dart';
import '../repositories/trades_repository.dart';
import 'dashboard_provider.dart';
// =============================================================================
// Repository & API providers
// =============================================================================

/// Provider for TradesRepository.
final tradesRepositoryProvider = Provider<TradesRepository>((ref) {
  final dashboardApi = ref.watch(dashboardApiProvider);
  return TradesRepositoryImpl(dashboardApi);
});

// =============================================================================
// Trades state
// =============================================================================

/// Represents the trades data state.
@immutable
class TradesState {
  final TradesResponse? data;
  final bool isLoading;
  final String? error;
  final int limit;
  final String period;

  const TradesState({
    this.data,
    this.isLoading = false,
    this.error,
    this.limit = 100,
    this.period = 'all',
  });

  TradesState copyWith({
    TradesResponse? data,
    bool? isLoading,
    String? error,
    int? limit,
    String? period,
    bool clearError = false,
  }) {
    return TradesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      limit: limit ?? this.limit,
      period: period ?? this.period,
    );
  }

  factory TradesState.initial() => const TradesState();
  factory TradesState.loading() => const TradesState(isLoading: true);
}

/// Notifier for trades state management.
class TradesNotifier extends StateNotifier<TradesState> {
  final TradesRepository _repository;

  TradesNotifier(this._repository) : super(TradesState.initial());

  /// Fetches trades with the given parameters.
  Future<void> fetchTrades({
    int limit = 100,
    String period = 'all',
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      limit: limit,
      period: period,
    );
    final result = await _repository.getTrades(limit: limit, period: period);
    if (result.isSuccess) {
      state = state.copyWith(data: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  /// Refreshes trades with current parameters.
  Future<void> refresh() async {
    await fetchTrades(limit: state.limit, period: state.period);
  }

  /// Updates the period filter.
  Future<void> setPeriod(String period) async {
    state = state.copyWith(period: period);
    await fetchTrades(period: period);
  }

  /// Updates the limit.
  Future<void> setLimit(int limit) async {
    state = state.copyWith(limit: limit);
    await fetchTrades(limit: limit);
  }

  /// Clears any trades error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for trades state.
final tradesProvider =
    StateNotifierProvider<TradesNotifier, TradesState>((ref) {
  final repository = ref.watch(tradesRepositoryProvider);
  return TradesNotifier(repository);
});

/// Provider for trades list.
final tradesListProvider = Provider<List<Trade>>((ref) {
  return ref.watch(tradesProvider).data?.trades ?? [];
});

/// Provider for trades statistics.
final tradesStatsProvider = Provider<TradesResponse?>((ref) {
  return ref.watch(tradesProvider).data;
});
