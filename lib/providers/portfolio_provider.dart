import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

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

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'isBuy': isBuy,
        'quantity': quantity,
        'price': price,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      symbol: json['symbol'],
      isBuy: json['isBuy'],
      quantity: json['quantity'],
      price: json['price'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
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

  Map<String, dynamic> toJson() => {
        'cashBalance': cashBalance,
        'holdings': holdings,
        'averageCosts': averageCosts,
        'tradeHistory': tradeHistory.map((t) => t.toJson()).toList(),
      };

  factory PortfolioState.fromJson(Map<String, dynamic> json) {
    return PortfolioState(
      cashBalance: (json['cashBalance'] as num).toDouble(),
      holdings: Map<String, int>.from(json['holdings'] ?? {}),
      averageCosts: (json['averageCosts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      tradeHistory: (json['tradeHistory'] as List<dynamic>?)
              ?.map((t) => TradeRecord.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  Timer? _saveTimer;
  File? _portfolioFile;

  PortfolioNotifier()
      : super(PortfolioState(
          cashBalance: 100000.0, // ₹100k starting virtual cash
          holdings: {},
          averageCosts: {},
          tradeHistory: [],
        )) {
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _portfolioFile = File('${directory.path}/portfolio.json');

      if (await _portfolioFile!.exists()) {
        final content = await _portfolioFile!.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          state = PortfolioState.fromJson(json);
        }
      }
    } catch (e) {
      print('Error loading portfolio: $e');
    }

    // Set up periodic saving (e.g., every 5 minutes)
    _saveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _savePortfolio();
    });
  }

  Future<void> _savePortfolio() async {
    if (_portfolioFile == null) return;
    try {
      final json = jsonEncode(state.toJson());
      await _portfolioFile!.writeAsString(json);
    } catch (e) {
      print('Error saving portfolio: $e');
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Final save on shutdown/disposal if called
    _savePortfolio();
    super.dispose();
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
        tradeHistory: [
          ...state.tradeHistory,
          TradeRecord(
            symbol: symbol,
            isBuy: true,
            quantity: quantity,
            price: price,
            timestamp: DateTime.now(),
          )
        ],
      );
      
      // Save after trade
      _savePortfolio();
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
        tradeHistory: [
          ...state.tradeHistory,
          TradeRecord(
            symbol: symbol,
            isBuy: false,
            quantity: quantity,
            price: price,
            timestamp: DateTime.now(),
          )
        ],
      );
      
      // Save after trade
      _savePortfolio();
    } else {
      throw Exception('Insufficient shares to sell');
    }
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  return PortfolioNotifier();
});
