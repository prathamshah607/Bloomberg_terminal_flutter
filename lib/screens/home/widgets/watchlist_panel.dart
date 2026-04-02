import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocksim2/screens/quote/quote_screen.dart';
import '../../../providers/watchlist_provider.dart';
import '../../../providers/market_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/change_badge.dart';

class WatchlistPanel extends ConsumerWidget {
  const WatchlistPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    if (watchlist.isEmpty) {
      return const Center(child: Text("Watchlist is Empty", style: TextStyles.terminalBodySmall));
    }

    return ListView.separated(
      itemCount: watchlist.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final symbol = watchlist[index];
        return _WatchlistRowAsync(symbol: symbol);
      },
    );
  }
}

class _WatchlistRowAsync extends ConsumerWidget {
  final String symbol;
  const _WatchlistRowAsync({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(stockQuoteProvider(symbol));

    return quoteAsync.when(skipLoadingOnReload: true,
        data: (quote) {
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => QuoteScreen(symbol: symbol)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  symbol,
                  style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      quote.price.toStringAsFixed(2),
                      style: TextStyles.terminalBody,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70, // Fixed width for alignment
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ChangeBadge(change: quote.changePercent, isPercent: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(symbol, style: TextStyles.terminalBody),
            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(symbol, style: TextStyles.terminalBody),
            Text("ERR", style: TextStyle(color: AppColors.negative)),
          ],
        ),
      ),
    );
  }
}
