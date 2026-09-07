import 'api_client.dart';

// =============================================================================
// Data models
// =============================================================================

/// High-level trading performance summary returned by the dashboard endpoint.
class DashboardSummary {
  final double totalProfit;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;

  const DashboardSummary({
    required this.totalProfit,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final total = (json['total_trades'] as num?)?.toInt() ?? 0;
    final wins = (json['winning_trades'] as num?)?.toInt() ?? 0;
    final losses = (json['losing_trades'] as num?)?.toInt() ?? 0;
    final double calculatedWinRate;
    if (total > 0) {
      calculatedWinRate = ((wins / total) * 100.0).clamp(0.0, 100.0);
    } else {
      final raw = (json['win_rate'] as num?)?.toDouble() ?? 0.0;
      calculatedWinRate = (raw > 1.0 ? raw : raw * 100.0).clamp(0.0, 100.0);
    }

    return DashboardSummary(
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      totalTrades: total,
      winningTrades: wins,
      losingTrades: losses,
      winRate: calculatedWinRate,
    );
  }
}

/// A single point on the cumulative-profit chart.
class ProfitPoint {
  /// Date label (YYYY-MM-DD).
  final String date;

  /// Profit of the trade that closed on this date.
  final double profit;

  /// Running total profit up to and including this date.
  final double cumulativeProfit;

  /// Number of trades represented by this point (always 1 from the API).
  final int trades;

  const ProfitPoint({
    required this.date,
    required this.profit,
    required this.cumulativeProfit,
    required this.trades,
  });

  factory ProfitPoint.fromJson(Map<String, dynamic> json) {
    return ProfitPoint(
      date: (json['date'] as String?) ?? '',
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      cumulativeProfit: (json['cumulative_profit'] as num?)?.toDouble() ?? 0.0,
      trades: (json['trades'] as num?)?.toInt() ?? 1,
    );
  }
}

/// A closed trade record.
class Trade {
  final int ticket;
  final String symbol;
  final String side; // "BUY" or "SELL"
  final double volume;
  final double openPrice;
  final double closePrice;
  final double profit;
  final String status;
  final String closedAt;

  const Trade({
    required this.ticket,
    required this.symbol,
    required this.side,
    required this.volume,
    required this.openPrice,
    required this.closePrice,
    required this.profit,
    required this.status,
    required this.closedAt,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      ticket: (json['ticket'] as num?)?.toInt() ??
          (json['broker_ticket'] as num?)?.toInt() ??
          0,
      symbol: (json['symbol'] as String?) ?? '',
      side: (json['side'] as String?) ?? (json['type'] as String?) ?? 'BUY',
      volume: (json['volume'] as num?)?.toDouble() ??
          (json['quantity'] as num?)?.toDouble() ??
          0.0,
      openPrice: (json['open_price'] as num?)?.toDouble() ??
          (json['entry_price'] as num?)?.toDouble() ??
          0.0,
      closePrice: (json['close_price'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] as String?) ?? 'closed',
      closedAt: (json['closed_at'] as String?) ??
          (json['close_time'] as String?) ??
          '',
    );
  }
}

/// Complete dashboard payload returned by `GET /api/dashboard/data`.
class DashboardData {
  final DashboardSummary summary;
  final List<ProfitPoint> points;
  final List<Trade> trades;

  const DashboardData({
    required this.summary,
    required this.points,
    required this.trades,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: DashboardSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      points: ((json['points'] as List<dynamic>?)
              ?.map((e) => ProfitPoint.fromJson(e as Map<String, dynamic>))
              .toList()) ??
          const [],
      trades: ((json['trades'] as List<dynamic>?)
              ?.map((e) => Trade.fromJson(e as Map<String, dynamic>))
              .toList()) ??
          const [],
    );
  }
}

/// An open position held on the broker account.
class Position {
  final int ticket;
  final String symbol;
  final String type; // "BUY" or "SELL"
  final double volume;
  final double openPrice;
  final double currentPrice;
  final double sl;
  final double tp;
  final double profit;
  final int magic;
  final String openTime;

  const Position({
    required this.ticket,
    required this.symbol,
    required this.type,
    required this.volume,
    required this.openPrice,
    required this.currentPrice,
    required this.sl,
    required this.tp,
    required this.profit,
    required this.magic,
    required this.openTime,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      ticket: (json['ticket'] as num?)?.toInt() ?? 0,
      symbol: (json['symbol'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'BUY',
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      openPrice: (json['open_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      sl: (json['sl'] as num?)?.toDouble() ?? 0.0,
      tp: (json['tp'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      magic: (json['magic'] as num?)?.toInt() ?? 0,
      openTime: (json['open_time'] as String?) ?? '',
    );
  }
}

/// Account balance / equity snapshot.
class AccountInfo {
  final double balance;
  final double equity;
  final double margin;
  final double freeMargin;
  final double profit;
  final double dailyStartEquity;
  final double dailyDrawdownPercent;

  const AccountInfo({
    required this.balance,
    required this.equity,
    required this.margin,
    required this.freeMargin,
    required this.profit,
    required this.dailyStartEquity,
    required this.dailyDrawdownPercent,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      equity: (json['equity'] as num?)?.toDouble() ?? 0.0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
      freeMargin: (json['free_margin'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      dailyStartEquity: (json['daily_start_equity'] as num?)?.toDouble() ?? 0.0,
      dailyDrawdownPercent:
          (json['daily_drawdown_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Full bot state returned by `GET /api/state`.
class BotState {
  final bool isRunning;
  final bool simulationMode;
  final AccountInfo accountInfo;
  final List<Position> positions;

  const BotState({
    required this.isRunning,
    required this.simulationMode,
    required this.accountInfo,
    required this.positions,
  });

  factory BotState.fromJson(Map<String, dynamic> json) {
    return BotState(
      isRunning: (json['is_running'] as bool?) ?? false,
      simulationMode: (json['simulation_mode'] as bool?) ?? true,
      accountInfo: AccountInfo.fromJson(
        (json['account_info'] as Map<String, dynamic>?) ?? const {},
      ),
      positions: ((json['positions'] as List<dynamic>?)
              ?.map((e) => Position.fromJson(e as Map<String, dynamic>))
              .toList()) ??
          const [],
    );
  }
}

/// Paginated trade-history response from `GET /api/user/trades`.
class TradesResponse {
  final List<Trade> trades;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalProfit;

  const TradesResponse({
    required this.trades,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalProfit,
  });

  factory TradesResponse.fromJson(Map<String, dynamic> json) {
    final total = (json['total_trades'] as num?)?.toInt() ?? 0;
    final wins = (json['winning_trades'] as num?)?.toInt() ?? 0;
    final losses = (json['losing_trades'] as num?)?.toInt() ?? 0;
    final double calculatedWinRate;
    if (total > 0) {
      calculatedWinRate = ((wins / total) * 100.0).clamp(0.0, 100.0);
    } else {
      final raw = (json['win_rate'] as num?)?.toDouble() ?? 0.0;
      calculatedWinRate = (raw > 1.0 ? raw : raw * 100.0).clamp(0.0, 100.0);
    }

    return TradesResponse(
      trades: ((json['trades'] as List<dynamic>?)
              ?.map((e) => Trade.fromJson(e as Map<String, dynamic>))
              .toList()) ??
          const [],
      totalTrades: total,
      winningTrades: wins,
      losingTrades: losses,
      winRate: calculatedWinRate,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// =============================================================================
// API client
// =============================================================================

/// API client for dashboard, positions, and trades endpoints in `app.py`.
///
/// Endpoints:
///  - `GET /api/dashboard/data`
///  - `GET /api/state`
///  - `GET /api/user/trades`
class DashboardApi {
  final ApiClient _client;

  DashboardApi(this._client);

  /// Fetches the full dashboard payload (summary, profit chart, recent trades).
  ///
  /// [days] defaults to 30 and is clamped server-side to 1–365.
  Future<DashboardData> getDashboardData({int days = 30}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/dashboard/data',
      queryParameters: {'days': days},
    );
    return DashboardData.fromJson(response.data!);
  }

  /// Fetches the current bot state including open positions and account info.
  Future<BotState> getBotState() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/state',
    );
    return BotState.fromJson(response.data!);
  }

  /// Fetches the user's open positions (convenience wrapper over [getBotState]).
  Future<List<Position>> getPositions() async {
    final state = await getBotState();
    return state.positions;
  }

  /// Fetches the user's trade history.
  ///
  /// [limit]  – maximum number of trades to return (default 100).
  /// [period] – one of `"day"`, `"week"`, `"month"`, `"all"` (default `"all"`).
  Future<TradesResponse> getTrades({
    int limit = 100,
    String period = 'all',
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/user/trades',
      queryParameters: {
        'limit': limit,
        'period': period,
      },
    );
    return TradesResponse.fromJson(response.data!);
  }
}
