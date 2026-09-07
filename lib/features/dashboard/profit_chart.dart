import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/api/dashboard_api.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class ProfitChart extends StatefulWidget {
  final List<ProfitPoint> data;
  final int height;

  const ProfitChart({
    super.key,
    required this.data,
    this.height = 220,
  });

  @override
  State<ProfitChart> createState() => _ProfitChartState();
}

class _ProfitChartState extends State<ProfitChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return _buildEmptyState();
    final spots = _buildSpots();
    final minY = _getMinY(spots);
    final maxY = _getMaxY(spots);
    final range = maxY - minY;
    final padding = range * 0.15;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          SizedBox(
            height: widget.height.toDouble(),
            child: LineChart(
              _buildChartData(spots, minY, maxY, padding),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
          begin: 0.06, end: 0, duration: 500.ms, delay: 200.ms);
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Cumulative P&L',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '${widget.data.length} days',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildSpots() {
    return widget.data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.cumulativeProfit))
        .toList();
  }

  double _getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    return spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    return spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
  }

  LineChartData _buildChartData(
    List<FlSpot> spots, double minY, double maxY, double padding,
  ) {
    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: _calcInterval(minY, maxY),
        getDrawingHorizontalLine: (value) => const FlLine(
          color: AppColors.border,
          strokeWidth: 0.5,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            interval: _calcInterval(minY, maxY),
            getTitlesWidget: (value, meta) => _buildYLabel(value),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: _calcXInterval(),
            getTitlesWidget: (value, meta) => _buildXLabel(value),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (widget.data.length - 1).toDouble(),
      minY: minY - padding,
      maxY: maxY + padding,
      lineTouchData: _buildTouchData(),
      lineBarsData: [_buildLineBar(spots)],
    );
  }

  double _calcInterval(double min, double max) {
    final range = max - min;
    if (range <= 0) return 1;
    return _niceNumber(range / 4);
  }

  double _calcXInterval() {
    final count = widget.data.length;
    if (count <= 7) return 1;
    return (count / 6).ceilToDouble();
  }

  double _niceNumber(double value) {
    if (value <= 0) return 1;
    final exp = math.log(value.abs()) / math.ln10;
    final floorExp = exp.floor();
    final fraction = value.abs() / math.pow(10, floorExp);
    double niceFraction;
    if (fraction <= 1.5) { niceFraction = 1; }
    else if (fraction <= 3) { niceFraction = 2; }
    else if (fraction <= 7) { niceFraction = 5; }
    else { niceFraction = 10; }
    return niceFraction * math.pow(10, floorExp);
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      touchCallback: (event, response) {
        setState(() {
          if (response?.lineBarSpots != null &&
              response!.lineBarSpots!.isNotEmpty) {
            touchedIndex = response.lineBarSpots!.first.spotIndex;
          } else {
            touchedIndex = null;
          }
        });
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => AppColors.surface,
        tooltipRoundedRadius: 12,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipBorder: const BorderSide(color: AppColors.border),
        getTooltipItems: (spots) => spots.map((spot) {
          final point = widget.data[spot.spotIndex];
          return LineTooltipItem(
            '${DateFormat('MMM dd').format(DateTime.parse(point.date))}\n',
            const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            children: [
              TextSpan(
                text: '\$${point.cumulativeProfit.toStringAsFixed(2)}',
                style: TextStyle(
                  color: point.cumulativeProfit >= 0
                      ? AppColors.success : AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
            ],
          );
        }).toList(),
      ),
      getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map(
        (index) => TouchedSpotIndicatorData(
          FlLine(
            color: AppColors.accent.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          FlDotData(
            getDotPainter: (spot, percent, barData, i) =>
                FlDotCirclePainter(
              radius: 5,
              color: AppColors.accent,
              strokeWidth: 2,
              strokeColor: AppColors.background,
            ),
          ),
        ),
      ).toList(),
    );
  }

  LineChartBarData _buildLineBar(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: AppColors.accent,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) {
          final isTouched = touchedIndex == index;
          return FlDotCirclePainter(
            radius: isTouched ? 4 : 2,
            color: isTouched
                ? AppColors.accent : AppColors.accent.withValues(alpha: 0.4),
            strokeWidth: isTouched ? 2 : 1,
            strokeColor: AppColors.background,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.25),
            AppColors.accent.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildYLabel(double value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        '\$${value.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildXLabel(double value) {
    final index = value.toInt();
    if (index < 0 || index >= widget.data.length) return const SizedBox.shrink();
    final date = DateTime.tryParse(widget.data[index].date);
    if (date == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        DateFormat('M/d').format(date),
        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      child: SizedBox(
        height: widget.height.toDouble(),
        child: const Center(
          child: Text(
            'No profit data available',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
