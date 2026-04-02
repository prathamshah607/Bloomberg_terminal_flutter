import 'package:stocksim2/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/portfolio_compute_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatter.dart';

class HoldingsTable extends ConsumerWidget {
  const HoldingsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    final portfolio = ref.watch(portfolioProvider);
    final metricsAsync = ref.watch(portfolioMetricsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CURRENT HOLDINGS', style: TextStyles.terminalBody),
          const Divider(color: AppColors.border),
          portfolio.holdings.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("NO OPEN POSITIONS", style: TextStyles.terminalBodySmall)),
                )
              : metricsAsync.when(skipLoadingOnReload: true,
        data: (metrics) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingTextStyle: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                        dataTextStyle: TextStyles.terminalBodySmall,
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('SYM')),
                          DataColumn(label: Text('QTY'), numeric: true),
                          DataColumn(label: Text('AVG COST'), numeric: true),
                          DataColumn(label: Text('PRICE'), numeric: true),
                          DataColumn(label: Text('TOTAL VAL'), numeric: true),
                          DataColumn(label: Text('TOTAL P&L'), numeric: true),
                        ],
                        rows: portfolio.holdings.entries.map((entry) {
                          final symbol = entry.key;
                          final qty = entry.value;
                          final avgCost = portfolio.averageCosts[symbol]!;
                          final value = metrics.assetValues[symbol] ?? (qty * avgCost);
                          final currentPrice = (qty > 0) ? value / qty : avgCost;
                          final pnl = value - (qty * avgCost);
                          final pnlColor = pnl >= 0 ? AppColors.positive : AppColors.negative;

                          return DataRow(
                            cells: [
                              DataCell(Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText))),
                              DataCell(Text(qty.toString())),
                              DataCell(Text(Formatter.formatCurrency(avgCost))),
                              DataCell(Text(Formatter.formatCurrency(currentPrice))),
                              DataCell(Text(Formatter.formatCurrency(value))),
                              DataCell(Text(
                                '${pnl >= 0 ? "+" : ""}${Formatter.formatCurrency(pnl)}',
                                style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold),
                              )),
                            ],
                          );
                        }).toList(),
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
