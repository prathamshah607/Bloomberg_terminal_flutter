import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatter.dart';
import '../../providers/market_provider.dart';
import 'chart_screen.dart';

class ChartAnalyseScreen extends ConsumerWidget {
  final String symbol;

  const ChartAnalyseScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(chartPeriodProvider);
    final interval = ref.watch(chartIntervalProvider);
    final args = (symbol: symbol, period: period, interval: interval);
    final historyAsync = ref.watch(stockHistoryProvider(args));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ANALYSE: $symbol ($period)', style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.panelBackground,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: historyAsync.when(
        data: (candles) {
          if (candles.isEmpty) return const Center(child: Text('NO DATA'));

          final first = candles.first;
          final last = candles.last;
          final totalReturn = (last.close - first.close) / first.close;

          double minPrice = double.infinity;
          double maxPrice = double.negativeInfinity;
          double maxDrawdown = 0.0;
          double peakPrice = double.negativeInfinity;
          double sumVolume = 0;
          
          List<double> returns = [];
          for (int i = 0; i < candles.length; i++) {
            final c = candles[i];
            if (c.low < minPrice) minPrice = c.low;
            if (c.high > maxPrice) maxPrice = c.high;
            
            if (c.high > peakPrice) peakPrice = c.high;
            final drawdown = (peakPrice - c.low) / peakPrice;
            if (drawdown > maxDrawdown) maxDrawdown = drawdown;

            sumVolume += c.volume;

            if (i > 0) {
               returns.add((c.close - candles[i-1].close) / candles[i-1].close);
            }
          }

          final avgVolume = sumVolume / candles.length;

          // Volatility
          double volatility = 0.0;
          if (returns.isNotEmpty) {
            final meanReturn = returns.reduce((a, b) => a + b) / returns.length;
            final sumSqDiff = returns.map((r) => pow(r - meanReturn, 2)).reduce((a, b) => a + b);
            final variance = sumSqDiff / returns.length;
            volatility = sqrt(variance);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCards('PERFORMANCE SUMMARY', [
                  _StatItem('PERIOD RETURN', Formatter.formatPercent(totalReturn), color: totalReturn >= 0 ? AppColors.positive : AppColors.negative),
                  _StatItem('START PRICE', Formatter.formatCurrency(first.close)),
                  _StatItem('END PRICE', Formatter.formatCurrency(last.close)),
                ]),
                const SizedBox(height: 24),
                _buildStatCards('PRICE STATISTICS', [
                  _StatItem('PERIOD HIGH', Formatter.formatCurrency(maxPrice), color: AppColors.positive),
                  _StatItem('PERIOD LOW', Formatter.formatCurrency(minPrice), color: AppColors.negative),
                  _StatItem('PRICE RANGE', Formatter.formatCurrency(maxPrice - minPrice)),
                  _StatItem('MAX DRAWDOWN', '-${(maxDrawdown * 100).toStringAsFixed(2)}%', color: AppColors.negative),
                  _StatItem('VOLATILITY (StDev)', '${(volatility * 100).toStringAsFixed(2)}%'),
                ]),
                const SizedBox(height: 24),
                _buildStatCards('VOLUME & TRADING', [
                  _StatItem('AVERAGE VOL', Formatter.formatCompactCurrency(avgVolume).replaceAll('\$', '')),
                  _StatItem('TOTAL VOL', Formatter.formatCompactCurrency(sumVolume).replaceAll('\$', '')),
                  _StatItem('DATA POINTS', '${candles.length} Candles'),
                ]),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('ERR: $e', style: const TextStyle(color: AppColors.negative))),
      ),
    );
  }

  Widget _buildStatCards(String title, List<_StatItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyles.terminalBody.copyWith(color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.panelBackground,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label, style: TextStyles.terminalBodySmall),
                    Text(item.value, style: TextStyles.terminalBody.copyWith(color: item.color, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem(this.label, this.value, {this.color = AppColors.whiteText});
}
