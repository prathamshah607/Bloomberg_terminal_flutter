import 'package:stocksim2/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../quote/quote_screen.dart';
import '../../portfolio/portfolio_screen.dart';

class PortfolioPanel extends ConsumerWidget {
  const PortfolioPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    final portfolio = ref.watch(portfolioProvider);
    
    double totalCostBasis = 0;
    portfolio.holdings.forEach((symbol, qty) {
      final avgCost = portfolio.averageCosts[symbol] ?? 0;
      totalCostBasis += (avgCost * qty);
    });

    final totalPortfolioValue = portfolio.cashBalance + totalCostBasis;

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen())),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryData('CASH BAL', Formatter.formatCurrency(portfolio.cashBalance)),
            _buildSummaryData('EQUITY  ', Formatter.formatCurrency(totalCostBasis)),
            const Divider(color: AppColors.border),
            _buildSummaryData('TOTAL   ', Formatter.formatCurrency(totalPortfolioValue), isTotal: true),
            const SizedBox(height: 16),
            Text("POSITIONS", style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText, decoration: TextDecoration.underline)),
            const SizedBox(height: 8),
            
            Expanded(
              child: portfolio.holdings.isEmpty 
               ? Center(child: Text("NO POSITIONS", style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)))
               : ListView.separated(
                    itemCount: portfolio.holdings.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                       final symbol = portfolio.holdings.keys.elementAt(index);
                       final qty = portfolio.holdings[symbol]!;
                       final avgCost = portfolio.averageCosts[symbol] ?? 0.0;
                       final marketValue = qty * avgCost; 
                       return Padding(
                           padding: const EdgeInsets.symmetric(vertical: 4.0),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text("$symbol ($qty SHS)", style: TextStyles.terminalBody),
                               Text(Formatter.formatCurrency(marketValue), style: TextStyles.terminalBody),
                             ]
                           ),
                         );
                    },
               ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryData(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyles.terminalBody.copyWith(color: isTotal ? AppColors.primaryText : AppColors.secondaryText)),
          Text(value, style: TextStyles.terminalBody.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primaryText : AppColors.whiteText,
          )),
        ],
      ),
    );
  }
}
