class StockQuote {
  final String symbol;
  final double price;
  final double previousClose;
  final int volume;
  final double marketCap;
  final double fiftyTwoWeekHigh;
  final double fiftyTwoWeekLow;

  StockQuote({
    required this.symbol,
    required this.price,
    required this.previousClose,
    required this.volume,
    required this.marketCap,
    required this.fiftyTwoWeekHigh,
    required this.fiftyTwoWeekLow,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      previousClose: (json['previous_close'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toInt(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      fiftyTwoWeekHigh: (json['fifty_two_week_high'] ?? 0).toDouble(),
      fiftyTwoWeekLow: (json['fifty_two_week_low'] ?? 0).toDouble(),
    );
  }

  double get change => price - previousClose;
  double get changePercent => (change / previousClose) * 100;
}
