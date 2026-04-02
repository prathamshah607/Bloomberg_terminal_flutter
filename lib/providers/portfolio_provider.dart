import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradeRecord {
  final String symbol;
  final bool isBuy;
  final int quantity;
  final double price;
  final DateTime timestamp;

  TradeRecord({
    required this.symbol,
    required this.isBuy,
    required this.quantity,
    required this.price,
    required this.timestamp,
  });
}

class PortfolioState {
  final double cashBalance;
  final Map<String, int> holdings; // Symbol -> Quantity
  final Map<String, double> averageCosts; // Symbol -> Average Cost Basis
  final List<TradeRecord> tradeHistory;

  PortfolioState({
    required this.cashBalance,
    required this.holdings,
    required this.averageCosts,
    required this.tradeHistory,
  });

  PortfolioState copyWith({
    double? cashBalance,
    Map<String, int>? holdings,
    Map<String, double>? averageCosts,
    List<TradeRecord>? tradeHistory,
  }) {
    return PortfolioState(
      cashBalance: cashBalance ?? this.cashBalance,
      holdings: holdings ?? this.holdings,
      averageCosts: averageCosts ?? this.averageCosts,
      tradeHistory: tradeHistory ?? this.tradeHistory,
    );
  }
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier()
      : super(PortfolioState(
          cashBalance: 100000.0, // \$100k starting virtual cash
          holdings: {},
          averageCosts: {},
          tradeHistory: [],
        )) {
    // In the future, we load this from shared_preferences or a local DB
  }

  void buyStock(String symbol, int quantity, double price) {
    final cost = quantity * price;
    if (state.cashBalance >= cost) {
      final currentQty = state.holdings[symbol] ?? 0;
      final currentAvgCost = state.averageCosts[symbol] ?? 0.0;

      final totalValueNow = currentQty * currentAvgCost;
      final newTotalValue = totalValueNow + cost;
      final newQty = currentQty + quantity;

      final newAvgCost = newTotalValue / newQty;

      final newHoldings = Map<String, int>.from(state.holdings);
      final newAvgCosts = Map<String, double>.from(state.averageCosts);

      newHoldings[symbol] = newQty;
      newAvgCosts[symbol] = newAvgCost;

      state = state.copyWith(
        cashBalance: state.cashBalance - cost,
        holdings: newHoldings,
        averageCosts: newAvgCosts,
        tradeHistory: [...state.tradeHistory, TradeRecord(symbol: symbol, isBuy: true, quantity: quantity, price: price, timestamp: DateTime.now())],
      );
    } else {
      throw Exception('Insufficient funds');
    }
  }

  void sellStock(String symbol, int quantity, double price) {
    final currentQty = state.holdings[symbol] ?? 0;
    if (currentQty >= quantity) {
      final revenue = quantity * price;

      final newHoldings = Map<String, int>.from(state.holdings);
      final newAvgCosts = Map<String, double>.from(state.averageCosts);

      newHoldings[symbol] = currentQty - quantity;
      if (newHoldings[symbol] == 0) {
        newHoldings.remove(symbol);
        newAvgCosts.remove(symbol);
      }

      state = state.copyWith(
        cashBalance: state.cashBalance + revenue,
        holdings: newHoldings,
        averageCosts: newAvgCosts,
        tradeHistory: [...state.tradeHistory, TradeRecord(symbol: symbol, isBuy: true, quantity: quantity, price: price, timestamp: DateTime.now())],
      );
    } else {
      throw Exception('Insufficient shares to sell');
    }
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  return PortfolioNotifier();
});
