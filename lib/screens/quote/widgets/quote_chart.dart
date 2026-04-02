import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../widgets/charts/terminal_line_chart.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class QuoteChart extends ConsumerWidget {
  final String symbol;

  const QuoteChart({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Let's use 1d data and 5m intervals for a true intraday chart, or 1mo 1d
    final args = (symbol: symbol, period: '1d', interval: '5m');
    final historyAsync = ref.watch(stockHistoryProvider(args));

    return historyAsync.when(skipLoadingOnReload: true,
        data: (candles) {
        if (candles.isEmpty) return const SizedBox.shrink();
        return Container(
          height: 400,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1D CHART', style: TextStyles.terminalBody),
              const Divider(color: AppColors.border),
              Expanded(child: TerminalLineChart(data: candles)),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const TerminalLoading(),
      ),
      error: (e, s) => Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Text('Chart Error: $e', style: TextStyles.terminalBody.copyWith(color: AppColors.negative)),
      ),
    );
  }
}
