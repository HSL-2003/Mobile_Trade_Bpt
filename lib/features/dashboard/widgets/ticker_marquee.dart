import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class MarketTickerItem {
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;

  const MarketTickerItem({
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
  });
}

class TickerMarquee extends StatefulWidget {
  final List<MarketTickerItem> items;
  final double height;

  const TickerMarquee({
    super.key,
    this.items = const [
      MarketTickerItem(
        symbol: 'XAUUSD',
        price: '2,908.45',
        change: '+1.42%',
        isPositive: true,
      ),
      MarketTickerItem(
        symbol: 'BTCUSD',
        price: '89,420.10',
        change: '+3.18%',
        isPositive: true,
      ),
      MarketTickerItem(
        symbol: 'EURUSD',
        price: '1.0842',
        change: '-0.24%',
        isPositive: false,
      ),
      MarketTickerItem(
        symbol: 'GBPUSD',
        price: '1.2915',
        change: '+0.12%',
        isPositive: true,
      ),
      MarketTickerItem(
        symbol: 'USOIL',
        price: '71.85',
        change: '-0.85%',
        isPositive: false,
      ),
    ],
    this.height = 36,
  });

  @override
  State<TickerMarquee> createState() => _TickerMarqueeState();
}

class _TickerMarqueeState extends State<TickerMarquee> {
  late final ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarquee();
    });
  }

  void _startMarquee() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= maxExtent) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(current + 1.2);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = [
      ...widget.items,
      ...widget.items,
      ...widget.items,
    ];

    return Container(
      height: widget.height,
      decoration: const BoxDecoration(
        color: Color(0xFF0B1019),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Color(0x14FFFFFF),
            width: 0.8,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final item = displayList[index];
          final deltaColor = item.isPositive ? AppColors.success : AppColors.error;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: deltaColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: deltaColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.symbol,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item.change,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: deltaColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
