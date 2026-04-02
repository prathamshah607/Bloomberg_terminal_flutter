import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/candle_data.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatter.dart';
import 'package:intl/intl.dart';

class TerminalLineChart extends StatelessWidget {
  final List<CandleData> data;
  final Color lineColor;

  const TerminalLineChart({
    Key? key,
    required this.data,
    this.lineColor = AppColors.primaryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text("NO DATA AVAILABLE", style: TextStyles.terminalBodySmall),
      );
    }

    final double minX = data.first.date.millisecondsSinceEpoch.toDouble();
    final double maxX = data.last.date.millisecondsSinceEpoch.toDouble();

    double minY = double.infinity;
    double maxY = -double.infinity;

    final spots = data.map((d) {
      if (d.low < minY) minY = d.low;
      if (d.high > maxY) maxY = d.high;
      return FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.close);
    }).toList();

    // Add padding to Y axis
    final yRange = maxY - minY;
    minY -= yRange * 0.1;
    maxY += yRange * 0.1;

    // Detect overall color (if open < close then green, else red, or just stick to standard terminal color)
    final actualLineColor = (data.last.close >= data.first.close)
        ? AppColors.positive
        : AppColors.negative;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 4.0, top: 16.0, bottom: 8.0),
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: yRange == 0 ? 1 : (yRange / 4) > 0 ? (yRange / 4) : 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: AppColors.border,
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: AppColors.border,
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Changed to left for terminal flow
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toStringAsFixed(2),
                      style: TextStyles.terminalBodySmall,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: (maxX - minX) / 3 > 0 ? (maxX - minX) / 3 : 1,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: TextStyles.terminalBodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.border),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: actualLineColor,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: actualLineColor.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.background,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                  final formattedDate = Formatter.formatDateTime(date);
                  final val = touchedSpot.y.toStringAsFixed(2);
                  return LineTooltipItem(
                    '$formattedDate\n$val',
                    TextStyles.terminalBodySmall.copyWith(color: actualLineColor, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
