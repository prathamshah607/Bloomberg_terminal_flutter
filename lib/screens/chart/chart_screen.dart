import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/timeframe_selector.dart';
import 'widgets/candlestick_chart.dart';
import 'widgets/chart_metrics.dart';
import 'chart_analyse_screen.dart';

// Providers for Chart state
final chartPeriodProvider = StateProvider<String>((ref) => '1mo');
final chartIntervalProvider = StateProvider<String>((ref) => '1d');

class ChartScreen extends ConsumerWidget {
  final String symbol;

  const ChartScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$symbol - Chart', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.panelBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: AppColors.accent),
            tooltip: "Analyse Data",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChartAnalyseScreen(symbol: symbol)));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChartMetrics(symbol: symbol),
            ),
            const Divider(color: AppColors.border, height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: TimeframeSelector(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 24.0, left: 8.0),
                child: CandlestickChart(symbol: symbol),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
