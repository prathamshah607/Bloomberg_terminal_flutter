import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/market_repository.dart';
import '../data/models/stock_quote.dart';
import '../data/models/candle_data.dart';
import 'polling_provider.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository();
});

final stockQuoteProvider =
    FutureProvider.family<StockQuote, String>((ref, symbol) async {
  // Automatically refresh when global poll ticks
  ref.watch(pollTickProvider);    

  final repo = ref.read(marketRepositoryProvider);
  return repo.getQuote(symbol);
});

// A family provider for periodicity
typedef HistoryArgs = ({String symbol, String period, String interval});

final stockHistoryProvider =
    FutureProvider.family<List<CandleData>, HistoryArgs>(
        (ref, args) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getHistory(args.symbol, period: args.period, interval: args.interval);
});

final stockInfoProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getInfo(symbol);
});

final stockFinancialsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getFinancials(symbol);
});


final stockStatementsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getStatements(symbol);
});

final searchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, query) async {
  final repo = ref.read(marketRepositoryProvider);
  if (query.isEmpty) return [];
  return repo.search(query);
});


final stockOptionsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getOptions(symbol);
});

final stockHoldersProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getHolders(symbol);
});

final stockAnalystsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
  final repo = ref.read(marketRepositoryProvider);
  return repo.getAnalysts(symbol);
});
