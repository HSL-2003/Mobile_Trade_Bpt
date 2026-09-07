import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../core/api/dashboard_api.dart';

/// Summary section: hero profit metric + 2×2 performance grid.
Widget buildSummarySection(DashboardSummary summary) {
  final profitColor =
      summary.totalProfit >= 0 ? AppColors.success : AppColors.error;
  final double winRatePercent = summary.totalTrades > 0
      ? ((summary.winningTrades / summary.totalTrades) * 100.0).clamp(0.0, 100.0)
      : (summary.winRate > 1.0 ? summary.winRate : summary.winRate * 100.0)
          .clamp(0.0, 100.0);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL PROFIT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${summary.totalProfit.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: profitColor,
                  letterSpacing: -0.5,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'All time across ${summary.totalTrades} trades',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildStatCard(
                'Win Rate',
                '${winRatePercent.toStringAsFixed(1)}%',
                Icons.trending_up_rounded,
                winRatePercent >= 50.0 ? AppColors.success : AppColors.error,
                progress: winRatePercent / 100.0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildStatCard(
                'Total Trades',
                '${summary.totalTrades}',
                Icons.swap_horiz_rounded,
                AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildStatCard(
                'Winning Trades',
                '${summary.winningTrades}',
                Icons.check_circle_outline_rounded,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildStatCard(
                'Losing Trades',
                '${summary.losingTrades}',
                Icons.cancel_outlined,
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// A single stat card: tinted icon chip, tabular value, muted label, optional progress.
Widget buildStatCard(
  String label,
  String value,
  IconData icon,
  Color color, {
  double? progress,
}) {
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (progress != null)
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFeatures: AppTheme.tabularNumbers,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: AppTheme.tabularNumbers,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    ),
  );
}
