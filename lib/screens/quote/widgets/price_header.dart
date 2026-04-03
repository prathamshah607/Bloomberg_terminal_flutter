import 'package:stocksim2/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/market_provider.dart';
import '../../../widgets/change_badge.dart';
import '../../../core/utils/formatter.dart';

class PriceHeader extends ConsumerWidget {
  final String symbol;
  const PriceHeader({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    final quoteAsync = ref.watch(stockQuoteProvider(symbol));

    return quoteAsync.when(skipLoadingOnReload: true,
        data: (quote) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₹${quote.price.toStringAsFixed(2)}',
                    style: TextStyles.terminalBody.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChangeBadge(change: quote.changePercent, isPercent: true),
                  const SizedBox(width: 8),
                  ChangeBadge(change: quote.change, isPercent: false),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('VOL: ${Formatter.formatVolume(quote.volume)}', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
                  const SizedBox(width: 16),
                  Text('PREV CLOSE: ₹${quote.previousClose.toStringAsFixed(2)}', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(height: 60, child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator())),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('ERROR LOADING QUOTE', style: TextStyle(color: AppColors.negative)),
      ),
    );
  }
}
