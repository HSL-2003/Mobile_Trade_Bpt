import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/api/dashboard_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

/// Gapless Bento Grid Architecture for Dashboard Performance Metrics.
/// Engineered with 0% dead space and interlocking asymmetric metric density.
Widget buildSummarySection(DashboardSummary summary) {
  final isProfitable = summary.totalProfit >= 0;
  final profitColor = isProfitable ? AppColors.success : AppColors.error;
  final double winRatePercent = summary.totalTrades > 0
      ? ((summary.winningTrades / summary.totalTrades) * 100.0).clamp(0.0, 100.0)
      : (summary.winRate > 1.0 ? summary.winRate : summary.winRate * 100.0).clamp(0.0, 100.0);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: Primary Accumulated PnL (Full Span) ──────────────────
        AppCard(
          padding: const EdgeInsets.all(20),
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
                        decoration: BoxDecoration(
                          color: profitColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: profitColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ACCUMULATED NET PROFIT',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: profitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: profitColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      isProfitable ? 'IN PROFIT' : 'DRAWDOWN',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: profitColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${isProfitable ? '+' : ''}\$${summary.totalProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      color: profitColor,
                      fontFeatures: AppTheme.tabularNumbers,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'USD',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All-time performance across ${summary.totalTrades} closed orders',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${summary.winningTrades}W / ${summary.losingTrades}L',
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Row 2: Split Bento Cells (Win Rate & Execution Geometry) ────
        Row(
          children: [
            // Left Bento: Win Rate Radial Dial
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WIN RATE',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${winRatePercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: winRatePercent >= 50 ? AppColors.success : AppColors.accent,
                            fontFeatures: AppTheme.tabularNumbers,
                          ),
                        ),
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: CustomPaint(
                            painter: _RadialArcPainter(
                              percent: winRatePercent / 100.0,
                              color: winRatePercent >= 50 ? AppColors.success : AppColors.accent,
                              trackColor: const Color(0x1FFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${summary.winningTrades} winning executions',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Bento: Ponytail Strategy Constraints
            const Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RISK : REWARD',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1 : 3.0',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: AppColors.textPrimary,
                        fontFeatures: AppTheme.tabularNumbers,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'SL 500 / TP 1500 pts',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Row 3: Exposure Matrix (Full Span) ──────────────────────────
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRAILING DISCIPLINE',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Step: 500 pts • Offset: 1000 pts',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 5,
                  width: double.infinity,
                  color: const Color(0x1FFFFFFF),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (winRatePercent / 100.0).clamp(0.08, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent,
                            AppColors.success,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RadialArcPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;

  const _RadialArcPainter({
    required this.percent,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.8;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = 2 * math.pi * percent.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialArcPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
