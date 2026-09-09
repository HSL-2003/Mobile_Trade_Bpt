import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/api/auth_api.dart' show CurrentUser;
import '../../core/api/dashboard_api.dart';
import '../../core/api/user_profile.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/app_card.dart';
import 'active_orders_list.dart';
import 'dashboard_widgets.dart';
import 'profit_chart.dart';
import 'summary_widgets.dart';
import 'trades_list_widget.dart';
import 'widgets/ticker_marquee.dart';
/// Main dashboard screen — three tabs: overview, live orders, account.
/// Protected route. Polls fresh state every 2 seconds while visible.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _pollingTimer;
  int _currentTab = 0;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).fetchAll();
      ref.read(profileProvider.notifier).fetchProfile();
    });
    // Polling dashboard with concurrency guard to avoid flooding backend connections
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!mounted || _isPolling) return;
      _isPolling = true;
      try {
        await ref.read(dashboardProvider.notifier).fetchAll();
      } catch (_) {
      } finally {
        _isPolling = false;
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait<void>([
      ref.read(dashboardProvider.notifier).refresh(),
      ref.read(profileProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final currentUser = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider);

    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final userDisplayName = profile?.displayName ??
        currentUser?.displayName ??
        (profile?.email != null ? profile!.email!.split('@').first : 'Trader');
    final activeBalance = profile?.finance.balance ??
        dashboardState.botState?.accountInfo.balance ??
        10000.0;

    const tabTitles = ['Tổng Quan', 'Lệnh Đang Vào', 'Tài Khoản'];
    final tabSubtitles = [
      '$userDisplayName • ${currencyFmt.format(activeBalance)}',
      'Trạng thái bot thời gian thực',
      'Hồ sơ & cài đặt hệ thống',
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: buildDashboardAppBar(
                  tabTitles[_currentTab],
                  tabSubtitles[_currentTab],
                  _handleLogout,
                ),
              ),
              if (_currentTab == 0) ..._buildOverviewTab(dashboardState, profile),
              if (_currentTab == 1) ..._buildOrdersTab(dashboardState),
              if (_currentTab == 2) ..._buildAccountTab(profile, currentUser),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // ── Tab: Overview ────────────────────────────────────────────────────────
  List<Widget> _buildOverviewTab(
    DashboardState dashboardState,
    UserProfile? profile,
  ) {
    final summary = dashboardState.data?.summary ??
        const DashboardSummary(
          totalProfit: 0.0,
          totalTrades: 0,
          winningTrades: 0,
          losingTrades: 0,
          winRate: 0.0,
        );

    return [
      SliverToBoxAdapter(
        child: _buildBalanceHeroCard(
          profile,
          dashboardState.botState?.accountInfo,
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: TickerMarquee(),
        ),
      ),
      SliverToBoxAdapter(child: buildSummarySection(summary)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: ProfitChart(data: dashboardState.data?.points ?? const []),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: buildBotStatusSection(
            dashboardState.botState?.isRunning ?? false,
            dashboardState.botState?.simulationMode ?? true,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ActiveOrdersList(
            positions: dashboardState.botState?.positions ?? const [],
            onRefresh: _handleRefresh,
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'Recent Trades',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
      buildTradesList(dashboardState.data?.trades ?? const []),
    ];
  }

  Widget _buildBalanceHeroCard(
    UserProfile? profile,
    AccountInfo? accountInfo,
  ) {
    final currencyFmt = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final balance = profile?.finance.balance ?? accountInfo?.balance ?? 10000.0;
    final equity = profile?.finance.equity ?? accountInfo?.equity ?? balance;
    final freeMargin =
        profile?.finance.freeMargin ?? accountInfo?.freeMargin ?? equity;
    final profit = profile?.finance.floatingProfit ?? accountInfo?.profit ?? 0.0;
    final profitColor = profit >= 0 ? AppColors.success : AppColors.error;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D121D),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0x1AFFFFFF), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(-8, -8),
            ),
            const BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2563EB).withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              profile?.displayName != null
                                  ? 'ACCOUNT • ${profile!.displayName.toUpperCase()}'
                                  : 'NET ASSET VALUE',
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x1F22C55E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0x3322C55E),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                profile?.brokerInfo.broker ?? 'Simulation Mode',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFmt.format(balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.2,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 0.8,
                      color: const Color(0x1AFFFFFF),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _balanceMiniStat(
                            'Vốn Ròng (Equity)',
                            currencyFmt.format(equity),
                            AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          width: 0.8,
                          height: 28,
                          color: const Color(0x1AFFFFFF),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: _balanceMiniStat(
                              'Khả Dụng (Free)',
                              currencyFmt.format(freeMargin),
                              AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          width: 0.8,
                          height: 28,
                          color: const Color(0x1AFFFFFF),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: _balanceMiniStat(
                              'Lãi/Lỗ Tạm',
                              profit > 0 ? '+${currencyFmt.format(profit)}' : currencyFmt.format(profit),
                              profitColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
            fontFeatures: AppTheme.tabularNumbers,
          ),
        ),
      ],
    );
  }

  // ── Tab: Live orders ─────────────────────────────────────────────────────
  List<Widget> _buildOrdersTab(DashboardState dashboardState) {
    final botState = dashboardState.botState;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: buildBotStatusSection(
            botState?.isRunning ?? false,
            botState?.simulationMode ?? true,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ActiveOrdersList(
          positions: botState?.positions ?? const [],
          onRefresh: _handleRefresh,
        ),
      ),
    ];
  }

  // ── Tab: Account ─────────────────────────────────────────────────────────
  List<Widget> _buildAccountTab(
    UserProfile? profile,
    CurrentUser? currentUser,
  ) {
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final displayName = profile?.displayName ??
        currentUser?.displayName ??
        (profile?.email != null ? profile!.email!.split('@').first : 'Trader');
    final email =
        profile?.email ?? currentUser?.email ?? 'Chưa cập nhật email';
    final accountId =
        profile?.accountId ?? currentUser?.accountId ?? 'demo-account';
    final balance = profile?.finance.balance ?? 10000.0;
    final equity = profile?.finance.equity ?? balance;
    final freeMargin = profile?.finance.freeMargin ?? equity;
    final margin = profile?.finance.margin ?? 0.0;
    final profit = profile?.finance.floatingProfit ?? 0.0;
    final profitColor = profit >= 0 ? AppColors.success : AppColors.error;
        final initialLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profile Header Card
              AppCard(
                borderRadius: AppRadius.xl,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accent,
                            AppColors.accent.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (profile?.roles.contains('admin') ?? false)
                                      ? 'ADMIN'
                                      : 'TRADER',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mã TK: $accountId',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Financial Balance & Equity Card
              AppCard(
                borderRadius: AppRadius.xl,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'TỔNG QUAN TÀI CHÍNH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _settingRow('Số dư tài khoản (Balance)',
                        currencyFmt.format(balance)),
                    const SizedBox(height: 12),
                    _settingRow(
                        'Vốn ròng (Equity)', currencyFmt.format(equity)),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Lợi nhuận tạm (Floating PnL)',
                      profit > 0 ? '+${currencyFmt.format(profit)}' : currencyFmt.format(profit),
                      valueColor: profitColor,
                    ),
                    const SizedBox(height: 12),
                    _settingRow('Ký quỹ khả dụng (Free Margin)',
                        currencyFmt.format(freeMargin)),
                    const SizedBox(height: 12),
                    _settingRow(
                        'Ký quỹ đã dùng (Margin)', currencyFmt.format(margin)),
                    const SizedBox(height: 12),
                    _settingRow('Đơn vị tiền tệ',
                        profile?.preferredCurrency ?? 'USD'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Broker & System Status Card
              AppCard(
                borderRadius: AppRadius.xl,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.dns_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'KẾT NỐI SÀN & TRẠNG THÁI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _settingRow('Máy chủ sàn (Broker)',
                        profile?.brokerInfo.broker ?? 'Simulation Mode'),
                    const SizedBox(height: 12),
                    _settingRow('Số tài khoản MT5',
                        profile?.brokerInfo.accountNumber ?? accountId),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Trạng thái tài khoản',
                      (profile?.status ?? 'active').toUpperCase(),
                      valueColor: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Khoá tài khoản',
                      (profile?.brokerInfo.lockState ?? 'unlocked')
                          .toUpperCase(),
                      valueColor: (profile?.brokerInfo.lockState ?? 'unlocked') ==
                              'unlocked'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Độ trễ kết nối (Latency)',
                      '24 ms • Tốt',
                      valueColor: AppColors.success,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Trading Rules
              AppCard(
                borderRadius: AppRadius.xl,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'QUY TẮC GIAO DỊCH PONYTAIL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _settingRow(
                        'Tỷ lệ Risk : Reward', '1 : 3 (SL 500 / TP 1500)'),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Trailing Stop',
                      '500 pts (Step 500, Offset 1000)',
                      valueColor: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Breakeven Trigger',
                      '500 pts (Buffer 0)',
                      valueColor: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Vùng kích hoạt Confluence',
                      '300 points (\$3.0 Gold)',
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Ngưỡng lọc RSI',
                      'BUY < 42 / SELL > 58',
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Dung sai Spread tối đa',
                      '100 points',
                    ),
                    const SizedBox(height: 12),
                    _settingRow(
                      'Tốc độ WebSocket UI',
                      '50ms (20 FPS)',
                      valueColor: AppColors.accent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AnimatedButton(
                text: 'Đăng Xuất',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                onPressed: _handleLogout,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _settingRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingNavbar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xCC0E131F),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0x24FFFFFF),
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _buildNavItem(0, Icons.dashboard_rounded, 'Tổng Quan')),
                  Expanded(child: _buildNavItem(1, Icons.candlestick_chart_rounded, 'Lệnh Đang Vào')),
                  Expanded(child: _buildNavItem(2, Icons.person_rounded, 'Tài Khoản')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 10 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x1F38BDF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0x3338BDF8), width: 0.8)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }
}
