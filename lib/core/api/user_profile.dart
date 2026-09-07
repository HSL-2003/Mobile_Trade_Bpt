import 'package:flutter/foundation.dart';

/// Financial summary and real-time balance for the user's trading account.
@immutable
class UserFinance {
  final double balance;
  final double equity;
  final double floatingProfit;
  final double margin;
  final double freeMargin;
  final String currency;
  final double dailyDrawdownPercent;

  const UserFinance({
    required this.balance,
    required this.equity,
    required this.floatingProfit,
    required this.margin,
    required this.freeMargin,
    required this.currency,
    required this.dailyDrawdownPercent,
  });

  factory UserFinance.fromJson(Map<String, dynamic> json) {
    return UserFinance(
      balance: (json['balance'] as num?)?.toDouble() ?? 10000.0,
      equity: (json['equity'] as num?)?.toDouble() ?? 10000.0,
      floatingProfit: (json['floating_profit'] as num?)?.toDouble() ?? 0.0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
      freeMargin: (json['free_margin'] as num?)?.toDouble() ?? 10000.0,
      currency: (json['currency'] as String?) ?? 'USD',
      dailyDrawdownPercent:
          (json['daily_drawdown_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const empty = UserFinance(
    balance: 10000.0,
    equity: 10000.0,
    floatingProfit: 0.0,
    margin: 0.0,
    freeMargin: 10000.0,
    currency: 'USD',
    dailyDrawdownPercent: 0.0,
  );
}

/// Broker & technical connection details.
@immutable
class BrokerInfo {
  final String broker;
  final String accountNumber;
  final String lockState;
  final bool isRunning;
  final bool simulationMode;

  const BrokerInfo({
    required this.broker,
    required this.accountNumber,
    required this.lockState,
    required this.isRunning,
    required this.simulationMode,
  });

  factory BrokerInfo.fromJson(Map<String, dynamic> json) {
    return BrokerInfo(
      broker: (json['broker'] as String?) ?? 'MetaQuotes-Demo',
      accountNumber: (json['account_number'] as String?) ?? 'N/A',
      lockState: (json['lock_state'] as String?) ?? 'unlocked',
      isRunning: (json['is_running'] as bool?) ?? false,
      simulationMode: (json['simulation_mode'] as bool?) ?? true,
    );
  }

  static const empty = BrokerInfo(
    broker: 'Simulation Mode',
    accountNumber: 'N/A',
    lockState: 'unlocked',
    isRunning: false,
    simulationMode: true,
  );
}

/// Comprehensive user profile returned by `GET /api/profile`.
@immutable
class UserProfile {
  final String userId;
  final String accountId;
  final String? email;
  final String displayName;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String preferredCurrency;
  final String status;
  final List<String> roles;
  final UserFinance finance;
  final BrokerInfo brokerInfo;

  const UserProfile({
    required this.userId,
    required this.accountId,
    this.email,
    required this.displayName,
    this.fullName,
    this.avatarUrl,
    this.phone,
    required this.preferredCurrency,
    required this.status,
    required this.roles,
    required this.finance,
    required this.brokerInfo,
  });

  bool get isAdmin => roles.contains('admin');

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['user_id'] as String?) ?? '',
      accountId: (json['account_id'] as String?) ?? '',
      email: json['email'] as String?,
      displayName: (json['display_name'] as String?) ??
          (json['email'] != null
              ? (json['email'] as String).split('@').first
              : 'Trader'),
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      preferredCurrency: (json['preferred_currency'] as String?) ?? 'USD',
      status: (json['status'] as String?) ?? 'active',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['trader'],
      finance: json['finance'] != null && json['finance'] is Map<String, dynamic>
          ? UserFinance.fromJson(json['finance'] as Map<String, dynamic>)
          : UserFinance.empty,
      brokerInfo: json['broker_info'] != null &&
              json['broker_info'] is Map<String, dynamic>
          ? BrokerInfo.fromJson(json['broker_info'] as Map<String, dynamic>)
          : BrokerInfo.empty,
    );
  }
}
