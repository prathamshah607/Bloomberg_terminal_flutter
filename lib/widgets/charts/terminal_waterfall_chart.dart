import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatter.dart';

class WaterfallNode {
  final String label;
  final double value;
  final bool isTotal;

  const WaterfallNode({
    required this.label,
    required this.value,
    this.isTotal = false,
  });
}

class TerminalWaterfallChart extends StatelessWidget {
  final List<WaterfallNode> nodes;
  final String title;

  const TerminalWaterfallChart({
    Key? key,
    required this.nodes,
    this.title = 'WATERFALL ANALYSIS',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Center(child: Text("NO DATA", style: TextStyles.terminalBodySmall));
    }

    double minVal = 0.0;
    double maxVal = 0.0;
    double currentSum = 0.0;

    // Calculate Y ranges and bar values
    List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      double fromY = currentSum;
      double toY = 0.0;

      if (node.isTotal) {
        fromY = 0;
        toY = node.value;
        currentSum = node.value; // Reset baseline
      } else {
        toY = currentSum + node.value;
        currentSum = toY;
      }

      if (fromY < minVal) minVal = fromY;
      if (toY < minVal) minVal = toY;
      if (fromY > maxVal) maxVal = fromY;
      if (toY > maxVal) maxVal = toY;

      Color barColor;
      if (node.isTotal) {
        barColor = AppColors.primaryText; // Amber/Primary for totals
      } else {
        barColor = node.value >= 0 ? AppColors.positive : AppColors.negative;
      }

      double drawFromY = fromY;
      double drawToY = toY;
      if (drawFromY > drawToY) {
        drawFromY = toY;
        drawToY = fromY;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: drawFromY,
              toY: drawToY,
              color: barColor,
              width: 14,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    // Add padding to max/min
    final range = maxVal - minVal;
    maxVal += range * 0.1;
    minVal -= range * 0.1;
    if (minVal == maxVal) {
      maxVal += 10;
      minVal -= 10;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyles.terminalBody),
        const Divider(color: AppColors.border),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 8.0, bottom: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal,
                minY: minVal,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.panelBackground,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final node = nodes[groupIndex];
                      return BarTooltipItem(
                        '${node.label}\n',
                        TextStyles.terminalBodySmall.copyWith(color: AppColors.whiteText, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: Formatter.formatCurrency(node.value),
                            style: TextStyles.terminalBodySmall.copyWith(
                              color: node.isTotal
                                  ? AppColors.primaryText
                                  : (node.value >= 0 ? AppColors.positive : AppColors.negative),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < nodes.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                nodes[index].label,
                                style: TextStyles.terminalBodySmall.copyWith(fontSize: 9),
                                softWrap: false,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        // Only show specific intervals if needed, but default is fine
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            Formatter.formatCompactCurrency(value),
                            style: TextStyles.terminalBodySmall.copyWith(fontSize: 10, color: AppColors.secondaryText),
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: range > 0 ? range / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                    left: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
              ),
              swapAnimationDuration: Duration.zero,
            ),
          ),
        ),
      ],
    );
  }
}
