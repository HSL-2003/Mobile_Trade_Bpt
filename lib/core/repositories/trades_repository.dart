import '../api/dashboard_api.dart';
import '../api/api_exceptions.dart';
import 'result.dart';

/// Abstract contract for trades data operations.
abstract class TradesRepository {
  Future<RepositoryResult<TradesResponse>> getTrades({
    int limit = 100,
    String period = 'all',
  });
}

/// Concrete implementation of [TradesRepository] using [DashboardApi].
class TradesRepositoryImpl implements TradesRepository {
  final DashboardApi _dashboardApi;

  TradesRepositoryImpl(this._dashboardApi);

  @override
  Future<RepositoryResult<TradesResponse>> getTrades({
    int limit = 100,
    String period = 'all',
  }) async {
    try {
      final response = await _dashboardApi.getTrades(limit: limit, period: period);
      return RepositoryResult.success(response);
    } on ApiException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure('Failed to load trades');
    }
  }
}
