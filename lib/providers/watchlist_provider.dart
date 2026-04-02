import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super(['AAPL', 'MSFT', 'TSLA', 'GOOGL']);

  void addSymbol(String symbol) {
    if (!state.contains(symbol)) {
      state = [...state, symbol];
    }
  }

  void removeSymbol(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  return WatchlistNotifier();
});
