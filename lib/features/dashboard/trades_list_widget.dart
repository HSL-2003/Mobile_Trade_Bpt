import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../core/api/dashboard_api.dart';

/// Bot status row: live dot, mode label, SIM/LIVE badge.
Widget buildBotStatusSection(bool isRunning, bool isSimulation) {
  final statusColor = isRunning ? AppColors.success : AppColors.textMuted;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: AppCard(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: statusColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRunning ? 'Bot Active' : 'Bot Inactive',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isSimulation ? 'Simulation Mode' : 'Live Trading',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isSimulation ? AppColors.warning : AppColors.success)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isSimulation ? 'SIM' : 'LIVE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isSimulation ? AppColors.warning : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Closed-trades list rendered as flat tiles on hairline-separated rows.
Widget buildTradesList(List<Trade> trades) {
  if (trades.isEmpty) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No trades yet',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final trade = trades[index];
        final isProfit = trade.profit >= 0;
        final color = isProfit ? AppColors.success : AppColors.error;
        final isBuy = trade.side.toUpperCase() == 'BUY';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isProfit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            trade.symbol,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBuy ? 'BUY' : 'SELL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color:
                                  isBuy ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trade.volume} lots',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : ''}\$${trade.profit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatClosedAt(trade.closedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      childCount: trades.length,
    ),
  );
}

String _formatClosedAt(String closedAt) {
  final date = DateTime.tryParse(closedAt);
  if (date == null) return '';
  return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
