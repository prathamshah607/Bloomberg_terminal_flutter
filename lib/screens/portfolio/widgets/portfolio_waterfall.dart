import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/charts/terminal_waterfall_chart.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/portfolio_compute_provider.dart';

class PortfolioWaterfall extends ConsumerWidget {
  const PortfolioWaterfall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final metricsAsync = ref.watch(portfolioMetricsProvider);

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12.0),
      child: metricsAsync.when(
        skipLoadingOnReload: true,
        data: (metrics) {
          final cash = portfolio.cashBalance;
          final basis = metrics.totalCostBasis;
          final pnl = metrics.totalPnL;
          final total = metrics.totalValue;
          
          List<WaterfallNode> nodes = [
            WaterfallNode(label: 'Cash Bal', value: cash, isTotal: true),
            WaterfallNode(label: 'Invested', value: basis),
            WaterfallNode(label: 'Gross P&L', value: pnl),
            WaterfallNode(label: 'Net Val', value: total, isTotal: true),
          ];

          return TerminalWaterfallChart(
            nodes: nodes,
            title: 'PORTFOLIO BREAKDOWN : WATERFALL',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text("ERR: $err", style: TextStyles.terminalBodySmall.copyWith(color: AppColors.negative))),
      ),
    );
  }
}
