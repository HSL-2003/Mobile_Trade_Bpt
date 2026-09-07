import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/api/dashboard_api.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

/// Price flash state tracking for animation.
class _PriceFlashState {
  double lastPrice;
  int flashTrigger = 0;
  bool isUp = true;
  DateTime lastUpdate;

  _PriceFlashState({
    required this.lastPrice,
    required this.lastUpdate,
  });
}

/// Real-time active orders display with price flash animation.
class ActiveOrdersList extends StatefulWidget {
  final List<Position> positions;
  final VoidCallback? onRefresh;

  const ActiveOrdersList({
    super.key,
    required this.positions,
    this.onRefresh,
  });

  @override
  State<ActiveOrdersList> createState() => _ActiveOrdersListState();
}

class _ActiveOrdersListState extends State<ActiveOrdersList> {
  final Map<int, _PriceFlashState> _priceFlashStates = {};
  Timer? _simulateTimer;

  @override
  void initState() {
    super.initState();
    _initFlashStates();
    _startSimulation();
  }

  @override
  void didUpdateWidget(ActiveOrdersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.positions != widget.positions) {
      _detectPriceChanges(oldWidget.positions);
      _initFlashStates();
    }
  }

  void _initFlashStates() {
    for (final pos in widget.positions) {
      _priceFlashStates.putIfAbsent(
        pos.ticket,
        () => _PriceFlashState(
          lastPrice: pos.profit,
          lastUpdate: DateTime.now(),
        ),
      );
    }
  }

  void _detectPriceChanges(List<Position> oldPositions) {
    for (final pos in widget.positions) {
      final old = oldPositions.where((p) => p.ticket == pos.ticket).firstOrNull;
      if (old != null && old.profit != pos.profit) {
        final flash = _priceFlashStates[pos.ticket];
        if (flash != null) {
          flash.flashTrigger++;
          flash.isUp = pos.profit > old.profit;
          flash.lastUpdate = DateTime.now();
        }
      }
    }
  }

  void _startSimulation() {
    _simulateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || widget.positions.isEmpty) return;
      setState(() {
        for (final pos in widget.positions) {
          final flash = _priceFlashStates[pos.ticket];
          if (flash != null) {
            final delta = (math.Random().nextDouble() - 0.5) * 2;
            flash.flashTrigger++;
            flash.isUp = delta >= 0;
            flash.lastUpdate = DateTime.now();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _simulateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 800.ms)
                      .then()
                      .fadeOut(duration: 800.ms),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Orders',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.positions.length} open',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.positions.isEmpty)
            const AppCard(
              child: SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    'No active orders',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              ),
            )
          else
            ...widget.positions.asMap().entries.map((entry) {
              final index = entry.key;
              final position = entry.value;
              return _ActiveOrderTile(
                position: position,
                flashState: _priceFlashStates[position.ticket],
                delay: index * 80,
              );
            }),
        ],
      ),
    );
  }
}

class _ActiveOrderTile extends StatefulWidget {
  final Position position;
  final _PriceFlashState? flashState;
  final int delay;

  const _ActiveOrderTile({
    required this.position,
    this.flashState,
    this.delay = 0,
  });

  @override
  State<_ActiveOrderTile> createState() => _ActiveOrderTileState();
}

class _ActiveOrderTileState extends State<_ActiveOrderTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  int _lastFlashTrigger = 0;

  @override
  void initState() {
    super.initState();
    _lastFlashTrigger = widget.flashState?.flashTrigger ?? 0;
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_flashController);
  }

  @override
  void didUpdateWidget(_ActiveOrderTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentTrigger = widget.flashState?.flashTrigger ?? 0;
    if (currentTrigger != _lastFlashTrigger && widget.flashState != null) {
      _lastFlashTrigger = currentTrigger;
      final isUp = widget.flashState!.isUp;
      final color = isUp ? AppColors.success : AppColors.error;
      _flashAnimation = ColorTween(
        begin: color.withValues(alpha: 0.2),
        end: Colors.transparent,
      ).animate(
        CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
      );
      _flashController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final pos = widget.position;
    final isBuy = pos.type.toUpperCase() == 'BUY';
    final isProfitPositive = pos.profit >= 0;
    final profitColor = isProfitPositive ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _flashAnimation.value,
            ),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isBuy ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(2),
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
                              pos.symbol,
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isBuy ? AppColors.success : AppColors.error)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isBuy ? 'LONG' : 'SHORT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isBuy ? AppColors.success : AppColors.error,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${pos.volume} lot @ ${pos.openPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (pos.currentPrice > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                '→ ${pos.currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (pos.sl > 0 || pos.tp > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'SL: ${pos.sl > 0 ? pos.sl.toStringAsFixed(2) : "—"}  •  TP: ${pos.tp > 0 ? pos.tp.toStringAsFixed(2) : "—"}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'SpaceGrotesk',
                              color: AppColors.textMuted,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isProfitPositive ? '+' : ''}\$${pos.profit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: profitColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('HH:mm:ss').format(
                          DateTime.tryParse(pos.openTime) ?? DateTime.now(),
                        ),
                        style: const TextStyle(
                          fontSize: 10,
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
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: widget.delay))
        .slideX(
          begin: 0.05, end: 0,
          duration: 500.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOutCubic,
        );
  }
}


/// A compact live price tick display for a single symbol.
class LivePriceTick extends StatefulWidget {
  final String symbol;
  final double price;
  final double changePercent;

  const LivePriceTick({
    super.key,
    required this.symbol,
    required this.price,
    this.changePercent = 0,
  });

  @override
  State<LivePriceTick> createState() => _LivePriceTickState();
}

class _LivePriceTickState extends State<LivePriceTick>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUp = widget.changePercent >= 0;
    final color = isUp ? AppColors.success : AppColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.5 + 0.5 * _pulseController.value),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          widget.symbol,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.price.toStringAsFixed(2),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

