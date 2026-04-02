import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/portfolio_compute_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class AllocationPie extends ConsumerWidget {
  const AllocationPie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(portfolioMetricsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SECTOR ALLOCATION', style: TextStyles.terminalBody),
          const Divider(color: AppColors.border),
          metricsAsync.when(skipLoadingOnReload: true,
        data: (metrics) {
              if (metrics.assetValues.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('NO ALLOCATION - CASH ONLY', style: TextStyles.terminalBodySmall)),
                );
              }

              // Build PieChart colors based on index
              final colors = [
                AppColors.accent,
                AppColors.primaryText,
                const Color(0xFF34C759),
                const Color(0xFFFF3B30),
                const Color(0xFFAF52DE),
                const Color(0xFFFF9500),
              ];

              final entries = metrics.assetValues.entries.toList();
              
              return Container(
                height: 200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: entries.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final isLarge = (item.value / metrics.latestEquityValue) > 0.1;
                            
                            return PieChartSectionData(
                              color: colors[idx % colors.length],
                              value: item.value,
                              title: isLarge ? item.key : '',
                              radius: isLarge ? 50 : 40,
                              titleStyle: TextStyles.terminalBodySmall.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: entries.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final pct = (item.value / metrics.latestEquityValue) * 100;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: colors[idx % colors.length],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.key} (${pct.toStringAsFixed(1)}%)',
                                  style: TextStyles.terminalBodySmall,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
            error: (e, s) => Center(child: Text('ERR: $e', style: TextStyles.terminalBodySmall)),
          ),
        ],
      ),
    );
  }
}
