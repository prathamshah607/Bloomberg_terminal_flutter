import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'portfolio_provider.dart';
import 'market_provider.dart';

class PortfolioMetric {
  final double totalValue;
  final double totalCostBasis;
  final double totalPnL;
  final double latestEquityValue;
  final Map<String, double> assetValues;

  PortfolioMetric({
    required this.totalValue,
    required this.totalCostBasis,
    required this.totalPnL,
    required this.latestEquityValue,
    required this.assetValues,
  });
}

final portfolioMetricsProvider = FutureProvider.autoDispose<PortfolioMetric>((ref) async {
  final portfolio = ref.watch(portfolioProvider);
  
  double equityValue = 0;
  double costBasis = 0;
  Map<String, double> values = {};

  final repos = ref.read(marketRepositoryProvider);

  for (final symbol in portfolio.holdings.keys) {
    final qty = portfolio.holdings[symbol]!;
    final avgCost = portfolio.averageCosts[symbol]!;
    
    // Fallback to average cost if API fails
    double currentPrice = avgCost;
    try {
      final quote = await repos.getQuote(symbol);
      currentPrice = quote.price;
    } catch (_) {}

    final value = qty * currentPrice;
    values[symbol] = value;
    equityValue += value;
    costBasis += (qty * avgCost);
  }

  final totalBalance = portfolio.cashBalance + equityValue;
  final pnl = equityValue - costBasis;

  return PortfolioMetric(
    totalValue: totalBalance,
    totalCostBasis: costBasis,
    totalPnL: pnl,
    latestEquityValue: equityValue,
    assetValues: values,
  );
});
