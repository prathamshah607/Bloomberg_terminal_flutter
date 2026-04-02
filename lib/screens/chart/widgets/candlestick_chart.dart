import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/market_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/charts/terminal_line_chart.dart';
import '../chart_screen.dart';

class InteractiveCandleData implements CandleData {
  @override
  final int timestamp;
  @override
  final double? open;
  @override
  final double? high;
  @override
  final double? low;
  @override
  final double? close;
  @override
  final double? volume;
  
  @override
  List<double?> trends = [];

  InteractiveCandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });
}

// Global provider to track whether we're in 'line' or 'candle' mode.
final chartStyleProvider = StateProvider<String>((ref) => 'candle');

class CandlestickChart extends ConsumerWidget {
  final String symbol;

  const CandlestickChart({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(chartPeriodProvider);
    final interval = ref.watch(chartIntervalProvider);
    final chartStyle = ref.watch(chartStyleProvider);

    final args = (symbol: symbol, period: period, interval: interval);
    final historyAsync = ref.watch(stockHistoryProvider(args));

    return Column(
      children: [
        // Style Toggle
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _StyleToggle(
                label: 'LINE',
                isSelected: chartStyle == 'line',
                onTap: () =>
                    ref.read(chartStyleProvider.notifier).state = 'line',
              ),
              const SizedBox(width: 8),
              _StyleToggle(
                label: 'CANDLE',
                isSelected: chartStyle == 'candle',
                onTap: () =>
                    ref.read(chartStyleProvider.notifier).state = 'candle',
              ),
            ],
          ),
        ),

        Expanded(
          child: historyAsync.when(
            skipLoadingOnReload: true,
            data: (candles) {
              if (candles.isEmpty)
                return const Center(
                    child: Text('NO DATA',
                        style: TextStyle(color: AppColors.secondaryText)));

              
              

              final chartData = candles
                  .map((e) => InteractiveCandleData(
                        timestamp: e.date.millisecondsSinceEpoch,
                        open: e.open,
                        high: e.high,
                        low: e.low,
                        close: e.close,
                        volume: e.volume,
                      ))
                  .toList();

              final isLine = chartStyle == 'line';
              if (isLine) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TerminalLineChart(data: candles),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                ),
                child: InteractiveChart(
                  candles: chartData,
                  style: ChartStyle(
                    priceGainColor: AppColors.positive,
                    priceLossColor: AppColors.negative,
                    
                    priceGridLineColor: AppColors.border.withAlpha(128),
                    
                    timeLabelStyle: const TextStyle(
                        color: AppColors.secondaryText, fontSize: 10),
                    priceLabelStyle: const TextStyle(
                        color: AppColors.secondaryText, fontSize: 10),
                    overlayBackgroundColor: AppColors.panelBackground,
                    overlayTextStyle: const TextStyle(
                        color: AppColors.whiteText, fontSize: 12),
                    volumeColor: AppColors.secondaryText.withAlpha(51),
                  ),
                  overlayInfo: (data) {
                    final dateStr = DateFormat('MMM dd HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(data.timestamp));
                    return {
                      'Date': dateStr,
                      'O': (data.open ?? 0).toStringAsFixed(2),
                      'H': (data.high ?? 0).toStringAsFixed(2),
                      'L': (data.low ?? 0).toStringAsFixed(2),
                      'C': (data.close ?? 0).toStringAsFixed(2),
                      'Vol': data.volume?.toStringAsFixed(0) ?? '0',
                    };
                  },
                ),
              );
            },
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryText)),
            error: (e, s) => Center(
                child: Text('ERR: $e',
                    style: const TextStyle(color: AppColors.negative))),
          ),
        ),
      ],
    );
  }
}

class _StyleToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryText : AppColors.panelBackground,
          border: Border.all(
              color: isSelected ? AppColors.primaryText : AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.primaryText,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
