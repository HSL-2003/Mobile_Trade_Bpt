import '../api/dashboard_api.dart';
import '../api/api_exceptions.dart';
import 'result.dart';

/// Abstract contract for dashboard data operations.
abstract class DashboardRepository {
  Future<RepositoryResult<DashboardData>> getDashboardData({int days = 30});
  Future<RepositoryResult<BotState>> getBotState();
  Future<RepositoryResult<List<Position>>> getPositions();
}

/// Concrete implementation of [DashboardRepository] using [DashboardApi].
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApi _dashboardApi;

  DashboardRepositoryImpl(this._dashboardApi);

  @override
  Future<RepositoryResult<DashboardData>> getDashboardData({int days = 30}) async {
    try {
      final data = await _dashboardApi.getDashboardData(days: days);
      return RepositoryResult.success(data);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('Failed to load dashboard data');
    }
  }

  @override
  Future<RepositoryResult<BotState>> getBotState() async {
    try {
      final state = await _dashboardApi.getBotState();
      return RepositoryResult.success(state);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('Failed to load bot state');
    }
  }

  @override
  Future<RepositoryResult<List<Position>>> getPositions() async {
    try {
      final positions = await _dashboardApi.getPositions();
      return RepositoryResult.success(positions);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('Failed to load positions');
    }
  }
}
