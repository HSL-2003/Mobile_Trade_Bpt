import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

/// Donut chart showing win/loss ratio.
class WinRateChart extends StatefulWidget {
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double size;

  const WinRateChart({
    super.key,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    this.size = 160,
  });

  @override
  State<WinRateChart> createState() => _WinRateChartState();
}

class _WinRateChartState extends State<WinRateChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(WinRateChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winRate != widget.winRate) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.winningTrades + widget.losingTrades;
    if (total == 0) return _buildEmptyState();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Win Rate',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return SizedBox(
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: widget.size * 0.35,
                        sections: _buildSections(),
                      ),
                    ),
                    _buildCenterLabel(),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 800.ms,
          delay: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.winningTrades + widget.losingTrades;
    if (total == 0) return [];

    final winFraction = (widget.winningTrades / total) * _animation.value;
    final lossFraction = (widget.losingTrades / total) * _animation.value;

    return [
      PieChartSectionData(
        color: AppColors.success,
        value: winFraction * 100,
        title: touchedIndex == 0 ? '${(winFraction * 100).toStringAsFixed(1)}%' : '',
        radius: touchedIndex == 0 ? 55 : 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'SpaceGrotesk',
        ),
        titlePositionPercentageOffset: 0.6,
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      PieChartSectionData(
        color: AppColors.error,
        value: lossFraction * 100,
        title: touchedIndex == 1 ? '${(lossFraction * 100).toStringAsFixed(1)}%' : '',
        radius: touchedIndex == 1 ? 55 : 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'SpaceGrotesk',
        ),
        titlePositionPercentageOffset: 0.6,
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];
  }

  Widget _buildCenterLabel() {
    final total = widget.winningTrades + widget.losingTrades;
    final double baseRate;
    if (total > 0) {
      baseRate = ((widget.winningTrades / total) * 100.0).clamp(0.0, 100.0);
    } else {
      baseRate = (widget.winRate > 1.0 ? widget.winRate : widget.winRate * 100.0)
          .clamp(0.0, 100.0);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final displayRate = baseRate * _animation.value;
            return Text(
              '${displayRate.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            );
          },
        ),
        const Text('Win Rate', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: AppColors.success, label: 'Wins', value: '${widget.winningTrades}'),
        const SizedBox(width: 24),
        _legendItem(color: AppColors.error, label: 'Losses', value: '${widget.losingTrades}'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label, required String value}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text('$value $label', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      child: SizedBox(
        height: widget.size + 60,
        child: const Center(
          child: Text('No trade data', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ),
      ),
    );
  }
}


/// A compact win rate indicator for inline use.
class WinRateIndicator extends StatelessWidget {
  final double winRate;
  final double size;

  const WinRateIndicator({
    super.key,
    required this.winRate,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (winRate > 1.0 ? winRate / 100.0 : winRate).clamp(0.0, 1.0);
    final isGood = fraction >= 0.5;
    final color = isGood ? AppColors.success : AppColors.error;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              const CircularProgressIndicator(
                value: 1,
                valueColor: AlwaysStoppedAnimation(AppColors.borderStrong),
              ),
              CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

