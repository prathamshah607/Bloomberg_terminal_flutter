import 'package:stocksim2/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/portfolio_compute_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatter.dart';
import '../../../widgets/loading_shimmer.dart';

class PnLSummary extends ConsumerWidget {
  const PnLSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    final portfolio = ref.watch(portfolioProvider);
    final metricsAsync = ref.watch(portfolioMetricsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border.all(color: AppColors.border),
      ),
      child: metricsAsync.when(skipLoadingOnReload: true,
        data: (metrics) {
          final isPositive = metrics.totalPnL >= 0;
          final color = isPositive ? AppColors.positive : AppColors.negative;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL PORTFOLIO VALUE', style: TextStyles.terminalBodySmall),
              const SizedBox(height: 8),
              Text(
                Formatter.formatCurrency(metrics.totalValue),
                style: TextStyles.terminalBody.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('CASH BAL', Formatter.formatCurrency(portfolio.cashBalance)),
                  _buildMetric('TOTAL P&L', '${isPositive ? "+" : ""}${Formatter.formatCurrency(metrics.totalPnL)}', color: color),
                  _buildMetric('EQUITY', Formatter.formatCurrency(metrics.latestEquityValue)),
                ],
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          width: double.infinity,
          height: 100,
          child: TerminalLoading(),
        ),
        error: (e, s) => Center(child: Text('Error: $e', style: TextStyles.terminalBodySmall)),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {Color color = AppColors.whiteText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 4),
        Text(value, style: TextStyles.terminalBody.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
