import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/market_provider.dart';
import '../../../widgets/charts/terminal_waterfall_chart.dart';

class QuoteFinancials extends ConsumerWidget {
  final String symbol;

  const QuoteFinancials({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financialsAsync = ref.watch(stockFinancialsProvider(symbol));

    return Container(
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12.0),
      child: financialsAsync.when(
        skipLoadingOnReload: true,
        data: (data) {
          if (data == null || data['data'] == null || data['data'].isEmpty) {
            String msg = "NO FINANCIALS DATA";
            if (symbol.startsWith('^')) {
              msg = "INDEX - NO INCOME STATEMENT";
            }
            return Center(child: Text(msg, style: TextStyles.terminalBody.copyWith(color: AppColors.secondaryText)));
          }
          final fin = data['data'].first;
          final revenue = (fin['revenue'] ?? 0) as num;
          final cogs = (fin['cost_of_revenue'] ?? 0) as num;
          final gross = (fin['gross_profit'] ?? 0) as num;
          final opex = (fin['operating_expense'] ?? 0) as num;
          final opInc = (fin['operating_income'] ?? 0) as num;
          final other = (fin['other_expenses'] ?? 0) as num;
          final net = (fin['net_income'] ?? 0) as num;
          
          List<WaterfallNode> nodes = [
            WaterfallNode(label: 'Revenue', value: revenue.toDouble(), isTotal: true),
            WaterfallNode(label: 'COGS', value: -cogs.toDouble()),
            WaterfallNode(label: 'Gross', value: gross.toDouble(), isTotal: true),
            WaterfallNode(label: 'OpEx', value: -opex.toDouble()),
            WaterfallNode(label: 'OpInc', value: opInc.toDouble(), isTotal: true),
            WaterfallNode(label: 'Other', value: -other.toDouble()),
            WaterfallNode(label: 'Net', value: net.toDouble(), isTotal: true),
          ];

          return TerminalWaterfallChart(
            nodes: nodes,
            title: 'RECENT FINANCIALS : WATERFALL',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text("ERR: $err", style: TextStyles.terminalBodySmall.copyWith(color: AppColors.negative))),
      ),
    );
  }
}
