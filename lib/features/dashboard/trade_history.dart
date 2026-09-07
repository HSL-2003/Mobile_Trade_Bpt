import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/api/dashboard_api.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

/// Filter options for trade history.
enum ProfitLossFilter { all, profit, loss }

/// Closed trades list with filters (symbol, date range, profit/loss).
class TradeHistory extends StatefulWidget {
  final List<Trade> trades;
  final String? selectedSymbol;
  final DateTimeRange? dateRange;
  final ProfitLossFilter pnlFilter;
  final ValueChanged<String?>? onSymbolChanged;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final ValueChanged<ProfitLossFilter>? onPnLFilterChanged;
  final List<String> availableSymbols;

  const TradeHistory({
    super.key,
    required this.trades,
    this.selectedSymbol,
    this.dateRange,
    this.pnlFilter = ProfitLossFilter.all,
    this.onSymbolChanged,
    this.onDateRangeChanged,
    this.onPnLFilterChanged,
    this.availableSymbols = const [],
  });

  @override
  State<TradeHistory> createState() => _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory> {
  @override
  Widget build(BuildContext context) {
    final filteredTrades = _applyFilters();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Trade History',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildFiltersBar(),
          const SizedBox(height: 12),
          if (filteredTrades.isEmpty)
            AppCard(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_list_off,
                        color: AppColors.textMuted,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No trades match filters',
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...filteredTrades.asMap().entries.map((entry) {
              final index = entry.key;
              final trade = entry.value;
              return _TradeHistoryTile(
                trade: trade,
                delay: index * 50,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFiltersBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: widget.selectedSymbol ?? 'All Symbols',
            icon: Icons.pie_chart_outline,
            isActive: widget.selectedSymbol != null,
            onTap: _showSymbolPicker,
            onClear: widget.selectedSymbol != null
                ? () => widget.onSymbolChanged?.call(null)
                : null,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: widget.dateRange != null
                ? '${DateFormat('M/d').format(widget.dateRange!.start)} - ${DateFormat('M/d').format(widget.dateRange!.end)}'
                : 'Date Range',
            icon: Icons.calendar_today_outlined,
            isActive: widget.dateRange != null,
            onTap: _showDateRangePicker,
            onClear: widget.dateRange != null
                ? () => widget.onDateRangeChanged?.call(null)
                : null,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: widget.pnlFilter == ProfitLossFilter.all
                ? 'All P&L'
                : widget.pnlFilter == ProfitLossFilter.profit
                    ? 'Profit Only'
                    : 'Loss Only',
            icon: widget.pnlFilter == ProfitLossFilter.profit
                ? Icons.trending_up
                : widget.pnlFilter == ProfitLossFilter.loss
                    ? Icons.trending_down
                    : Icons.filter_alt_outlined,
            isActive: widget.pnlFilter != ProfitLossFilter.all,
            onTap: _showPnLFilterPicker,
            onClear: widget.pnlFilter != ProfitLossFilter.all
                ? () => widget.onPnLFilterChanged?.call(ProfitLossFilter.all)
                : null,
          ),
        ],
      ),
    );
  }

  List<Trade> _applyFilters() {
    var trades = widget.trades;
    if (widget.selectedSymbol != null) {
      trades = trades.where((t) => t.symbol == widget.selectedSymbol).toList();
    }
    if (widget.dateRange != null) {
      trades = trades.where((t) {
        final date = DateTime.tryParse(t.closedAt);
        if (date == null) return false;
        return !date.isBefore(widget.dateRange!.start) &&
            !date.isAfter(widget.dateRange!.end);
      }).toList();
    }
    switch (widget.pnlFilter) {
      case ProfitLossFilter.profit:
        trades = trades.where((t) => t.profit > 0).toList();
        break;
      case ProfitLossFilter.loss:
        trades = trades.where((t) => t.profit < 0).toList();
        break;
      case ProfitLossFilter.all:
        break;
    }
    return trades;
  }

  void _showSymbolPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _SymbolPickerSheet(
          symbols: widget.availableSymbols,
          selected: widget.selectedSymbol,
          onSelected: (symbol) {
            widget.onSymbolChanged?.call(symbol);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showDateRangePicker() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: widget.dateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      widget.onDateRangeChanged?.call(range);
    }
  }

  void _showPnLFilterPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _PnLFilterSheet(
          selected: widget.pnlFilter,
          onSelected: (filter) {
            widget.onPnLFilterChanged?.call(filter);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}


class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isActive = false,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isActive
                ? AppColors.accent.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? AppColors.accent : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _SymbolPickerSheet extends StatelessWidget {
  final List<String> symbols;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _SymbolPickerSheet({
    required this.symbols,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Symbol',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.select_all, color: AppColors.accent),
              title: const Text('All Symbols', style: TextStyle(color: AppColors.textPrimary)),
              trailing: selected == null ? const Icon(Icons.check, color: AppColors.accent) : null,
              onTap: () => onSelected(null),
            ),
            const Divider(color: AppColors.border),
            ...symbols.map((symbol) {
              return ListTile(
                title: Text(symbol, style: const TextStyle(fontFamily: 'SpaceGrotesk', color: AppColors.textPrimary)),
                trailing: selected == symbol ? const Icon(Icons.check, color: AppColors.accent) : null,
                onTap: () => onSelected(symbol),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PnLFilterSheet extends StatelessWidget {
  final ProfitLossFilter selected;
  final ValueChanged<ProfitLossFilter> onSelected;

  const _PnLFilterSheet({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by P&L',
              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _option(context, 'All Trades', Icons.filter_alt_outlined, ProfitLossFilter.all),
            _option(context, 'Profit Only', Icons.trending_up, ProfitLossFilter.profit, color: AppColors.success),
            _option(context, 'Loss Only', Icons.trending_down, ProfitLossFilter.loss, color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, String label, IconData icon, ProfitLossFilter filter, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.accent),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: selected == filter ? const Icon(Icons.check, color: AppColors.accent) : null,
      onTap: () => onSelected(filter),
    );
  }
}


class _TradeHistoryTile extends StatelessWidget {
  final Trade trade;
  final int delay;

  const _TradeHistoryTile({required this.trade, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    final isProfit = trade.profit >= 0;
    final color = isProfit ? AppColors.success : AppColors.error;
    final isBuy = trade.side.toUpperCase() == 'BUY';
    final closedDate = DateTime.tryParse(trade.closedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isBuy ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
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
                            style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              trade.side.toUpperCase(),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Vol: ${trade.volume}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : ''}\$${trade.profit.toStringAsFixed(2)}',
                      style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 15, fontWeight: FontWeight.w700, color: color),
                    ),
                    if (closedDate != null)
                      Text(DateFormat('MMM d, HH:mm').format(closedDate), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priceDetail('Open', trade.openPrice),
                  const Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                  _priceDetail('Close', trade.closePrice),
                  _priceDetail('Ticket', trade.ticket.toDouble(), isInt: true),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay))
        .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: Duration(milliseconds: delay), curve: Curves.easeOutCubic);
  }

  Widget _priceDetail(String label, double value, {bool isInt = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        Text(
          isInt ? value.toInt().toString() : value.toStringAsFixed(2),
          style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

