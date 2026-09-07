import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dashboard_api.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/result.dart';
import 'api_provider.dart';
// =============================================================================
// Repository & API providers
// =============================================================================

/// Provider for DashboardApi instance.
final dashboardApiProvider = Provider<DashboardApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardApi(apiClient);
});

/// Provider for DashboardRepository.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dashboardApi = ref.watch(dashboardApiProvider);
  return DashboardRepositoryImpl(dashboardApi);
});

// =============================================================================
// Dashboard state
// =============================================================================

/// Represents the dashboard data state.
@immutable
class DashboardState {
  final DashboardData? data;
  final BotState? botState;
  final bool isLoading;
  final String? error;
  final int selectedDays;

  const DashboardState({
    this.data,
    this.botState,
    this.isLoading = false,
    this.error,
    this.selectedDays = 30,
  });

  DashboardState copyWith({
    DashboardData? data,
    BotState? botState,
    bool? isLoading,
    String? error,
    int? selectedDays,
    bool clearError = false,
  }) {
    return DashboardState(
      data: data ?? this.data,
      botState: botState ?? this.botState,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  factory DashboardState.initial() => const DashboardState();
  factory DashboardState.loading() => const DashboardState(isLoading: true);
}

/// Notifier for dashboard state management.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState.initial());

  /// Fetches dashboard data for the given time period.
  Future<void> fetchDashboardData({int days = 30}) async {
    state = state.copyWith(isLoading: true, clearError: true, selectedDays: days);
    final result = await _repository.getDashboardData(days: days);
    if (result.isSuccess) {
      state = state.copyWith(data: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  /// Fetches the current bot state (positions, account info).
  Future<void> fetchBotState() async {
    final result = await _repository.getBotState();
    if (result.isSuccess) {
      state = state.copyWith(botState: result.data);
    }
  }

  /// Fetches both dashboard data and bot state.
  Future<void> fetchAll({int days = 30}) async {
    state = state.copyWith(isLoading: true, clearError: true, selectedDays: days);

    final results = await Future.wait([
      _repository.getDashboardData(days: days),
      _repository.getBotState(),
    ]);

    final dashboardResult = results[0] as RepositoryResult<DashboardData>;
    final botStateResult = results[1] as RepositoryResult<BotState>;

    if (dashboardResult.isSuccess) {
      state = state.copyWith(
        data: dashboardResult.data,
        botState: botStateResult.isSuccess ? botStateResult.data : null,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, error: dashboardResult.error);
    }
  }

  /// Refreshes dashboard data.
  Future<void> refresh() async {
    await fetchAll(days: state.selectedDays);
  }

  /// Updates the selected time period.
  void setSelectedDays(int days) {
    state = state.copyWith(selectedDays: days);
  }

  /// Clears any dashboard error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for dashboard state.
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});

/// Provider for dashboard summary data.
final dashboardSummaryProvider = Provider<DashboardSummary?>((ref) {
  return ref.watch(dashboardProvider).data?.summary;
});

/// Provider for profit chart data.
final profitChartProvider = Provider<List<ProfitPoint>>((ref) {
  return ref.watch(dashboardProvider).data?.points ?? [];
});

/// Provider for recent trades from dashboard.
final recentTradesProvider = Provider<List<Trade>>((ref) {
  return ref.watch(dashboardProvider).data?.trades ?? [];
});

/// Provider for bot positions.
final positionsProvider = Provider<List<Position>>((ref) {
  return ref.watch(dashboardProvider).botState?.positions ?? [];
});

/// Provider for account info.
final accountInfoProvider = Provider<AccountInfo?>((ref) {
  return ref.watch(dashboardProvider).botState?.accountInfo;
});

/// Provider for bot running status.
final botStatusProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).botState?.isRunning ?? false;
});
