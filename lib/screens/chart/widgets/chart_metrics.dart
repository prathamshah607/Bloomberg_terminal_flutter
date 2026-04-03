import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../chart_screen.dart';

class ChartMetrics extends ConsumerWidget {
  final String symbol;

  const ChartMetrics({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(chartPeriodProvider);
    final interval = ref.watch(chartIntervalProvider);
    final args = (symbol: symbol, period: period, interval: interval);
    final historyAsync = ref.watch(stockHistoryProvider(args));

    return historyAsync.when(skipLoadingOnReload: true,
        data: (candles) {
        if (candles.isEmpty) return const SizedBox.shrink();

        final current = candles.last.close;
        final start = candles.first.close;
        final diff = current - start;
        final pct = (diff / start) * 100;

        final isPositive = diff >= 0;
        final color = isPositive ? AppColors.positive : AppColors.negative;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹$current',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteText,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: color,
                      size: 16,
                    ),
                    Text(
                      '${diff.abs().toStringAsFixed(2)} (${pct.abs().toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMetric('High', '₹${candles.map((e) => e.high).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}'),
                _buildMetric('Low', '₹${candles.map((e) => e.low).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}'),
                _buildMetric('Vol', _formatVolume(candles.map((e) => e.volume).reduce((a, b) => a + b).toInt())),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      error: (e, s) => SizedBox(height: 60, child: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppColors.whiteText, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toString();
  }
}
