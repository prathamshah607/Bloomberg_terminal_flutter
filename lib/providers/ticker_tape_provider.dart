import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'market_provider.dart';
import '../data/models/stock_quote.dart';
import 'polling_provider.dart';

final asyncTickerTapeProvider = FutureProvider<List<StockQuote>>((ref) async {
  // Automatically refresh when global poll ticks
  ref.watch(pollTickProvider);

  final marketRepo = ref.read(marketRepositoryProvider);

  // Ticker tape constants to scroll
  final symbols = [
    '^GSPC',
    '^IXIC',
    '^DJI',
    'BTC-INR',
    'ETH-INR',
    'GC=F',
    'CL=F'
  ];

  final quotes = <StockQuote>[];

  for (var symbol in symbols) {
    try {
      final quote = await marketRepo.getQuote(symbol);
      quotes.add(quote);
    } catch (_) {
      // Silently fail for a single ticker to not break the tape
    }
  }

  return quotes;
});
