import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class FundamentalsCard extends ConsumerWidget {
  final String symbol;
  const FundamentalsCard({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(stockInfoProvider(symbol));

    return infoAsync.when(skipLoadingOnReload: true,
        data: (data) {
        final info = data['info'] ?? {};
        final summary = info['longBusinessSummary']?.toString() ?? 'No profile available.';
        
        return Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.panelBackground,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COMPANY PROFILE', style: TextStyles.terminalBody.copyWith(color: AppColors.whiteText, fontWeight: FontWeight.bold)),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              Text(
                summary,
                style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text('KEY STATISTICS & VALUATION', style: TextStyles.terminalBody.copyWith(color: AppColors.whiteText, fontWeight: FontWeight.bold)),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _buildColumn([
                    _buildItem('Sector', info['sector']?.toString() ?? 'N/A'),
                    _buildItem('Industry', info['industry']?.toString() ?? 'N/A'),
                    _buildItem('Employees', info['fullTimeEmployees']?.toString() ?? 'N/A'),
                    _buildItem('Website', info['website']?.toString() ?? 'N/A'),
                  ]),
                  _buildColumn([
                    _buildItem('Market Cap', _formatCompact(info['marketCap'])),
                    _buildItem('Enterprise Val', _formatCompact(info['enterpriseValue'])),
                    _buildItem('Trailing P/E', _formatValue(info['trailingPE'])),
                    _buildItem('Forward P/E', _formatValue(info['forwardPE'])),
                  ]),
                  _buildColumn([
                    _buildItem('P/S Ratio', _formatValue(info['priceToSalesTrailing12Months'])),
                    _buildItem('P/B Ratio', _formatValue(info['priceToBook'])),
                    _buildItem('PEG Ratio', _formatValue(info['pegRatio'])),
                    _buildItem('Beta', _formatValue(info['beta'])),
                  ]),
                  _buildColumn([
                    _buildItem('Gross Margin', _formatPercent(info['grossMargins'])),
                    _buildItem('Op Margin', _formatPercent(info['operatingMargins'])),
                    _buildItem('Profit Margin', _formatPercent(info['profitMargins'])),
                    _buildItem('Return on Equity', _formatPercent(info['returnOnEquity'])),
                  ]),
                  _buildColumn([
                    _buildItem('Total Debt', _formatCompact(info['totalDebt'])),
                    _buildItem('Total Cash', _formatCompact(info['totalCash'])),
                    _buildItem('Current Ratio', _formatValue(info['currentRatio'])),
                    _buildItem('Debt/Equity', _formatValue(info['debtToEquity'])),
                  ]),
                  _buildColumn([
                    _buildItem('52W High', _formatCurrency(info['fiftyTwoWeekHigh'])),
                    _buildItem('52W Low', _formatCurrency(info['fiftyTwoWeekLow'])),
                    _buildItem('50D Avg', _formatCurrency(info['fiftyDayAverage'])),
                    _buildItem('200D Avg', _formatCurrency(info['twoHundredDayAverage'])),
                  ]),
                  _buildColumn([
                    _buildItem('Target High', _formatCurrency(info['targetHighPrice'])),
                    _buildItem('Target Low', _formatCurrency(info['targetLowPrice'])),
                    _buildItem('Target Mean', _formatCurrency(info['targetMeanPrice'])),
                    _buildItem('Recommendation', info['recommendationKey']?.toString().toUpperCase().replaceAll('_', ' ') ?? 'N/A'),
                  ]),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('ERROR: DATA UNAVAILABLE', style: TextStyle(color: AppColors.negative)),
      ),
    );
  }

  Widget _buildColumn(List<Widget> children) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyles.terminalBodySmall.copyWith(color: AppColors.whiteText, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    num val = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return val.toStringAsFixed(2);
  }
  
  String _formatCurrency(dynamic value) {
    if (value == null) return 'N/A';
    num val = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return '\$${val.toStringAsFixed(2)}';
  }

  String _formatCompact(dynamic value) {
    if (value == null) return 'N/A';
    num val = value is num ? value : num.tryParse(value.toString()) ?? 0;
    if (val >= 1000000000000) {
      return '\$${(val / 1000000000000).toStringAsFixed(2)}T';
    } else if (val >= 1000000000) {
      return '\$${(val / 1000000000).toStringAsFixed(2)}B';
    } else if (val >= 1000000) {
      return '\$${(val / 1000000).toStringAsFixed(2)}M';
    }
    return '\$${val.toStringAsFixed(0)}';
  }

  String _formatPercent(dynamic value) {
    if (value == null) return 'N/A';
    num val = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return '${(val * 100).toStringAsFixed(2)}%';
  }
}
