import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

/// P&L period summary data model.
class PnLPeriodData {
  final double pnl;
  final double percentChange;
  final int trades;

  const PnLPeriodData({
    required this.pnl,
    required this.percentChange,
    required this.trades,
  });
}

/// P&L cards showing Day/Week/Month summary with animated counter.
class PnLCards extends StatefulWidget {
  final PnLPeriodData dayData;
  final PnLPeriodData weekData;
  final PnLPeriodData monthData;

  const PnLCards({
    super.key,
    required this.dayData,
    required this.weekData,
    required this.monthData,
  });

  @override
  State<PnLCards> createState() => _PnLCardsState();
}

class _PnLCardsState extends State<PnLCards> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'P&L Overview',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _PnLCard(
                  label: 'Today',
                  data: widget.dayData,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PnLCard(
                  label: 'This Week',
                  data: widget.weekData,
                  delay: 100,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PnLCard(
                  label: 'This Month',
                  data: widget.monthData,
                  delay: 200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PnLCard extends StatefulWidget {
  final String label;
  final PnLPeriodData data;
  final int delay;

  const _PnLCard({
    required this.label,
    required this.data,
    this.delay = 0,
  });

  @override
  State<_PnLCard> createState() => _PnLCardState();
}

class _PnLCardState extends State<_PnLCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _valueAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _valueAnimation = Tween<double>(begin: 0, end: widget.data.pnl).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.delay + 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_PnLCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.pnl != widget.data.pnl) {
      _valueAnimation = Tween<double>(
        begin: _valueAnimation.value,
        end: widget.data.pnl,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
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
    final isPositive = widget.data.pnl >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final sign = isPositive ? '+' : '';

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _valueAnimation,
            builder: (context, _) {
              return Text(
                '$sign\$${NumberFormat('#,##0.00').format(_valueAnimation.value)}',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$sign${widget.data.percentChange.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.data.trades} trades',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: widget.delay))
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 600.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOutCubic,
        );
  }
}


/// Compact animated counter widget for reuse elsewhere.
class AnimatedPnLCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final int decimalPlaces;
  final Duration duration;

  const AnimatedPnLCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '\$',
    this.decimalPlaces = 2,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedPnLCounter> createState() => _AnimatedPnLCounterState();
}

class _AnimatedPnLCounterState extends State<AnimatedPnLCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPnLCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final isNegative = _animation.value < 0;
        final displayValue = _animation.value.abs();
        final formatted = '${isNegative ? '-' : ''}${widget.prefix}${NumberFormat('#,##0.${'0' * widget.decimalPlaces}').format(displayValue)}';
        return Text(
          formatted,
          style: widget.style ??
              TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isNegative ? AppColors.error : AppColors.success,
              ),
        );
      },
    );
  }
}

