import '../datasources/yfinance_api.dart';
import '../models/stock_quote.dart';
import '../models/candle_data.dart';

class MarketRepository {
  final YFinanceApi _api;

  MarketRepository({YFinanceApi? api}) : _api = api ?? YFinanceApi();

  Future<StockQuote> getQuote(String symbol) async {
    final data = await _api.getQuote(symbol);
    return StockQuote.fromJson(data);
  }

  Future<List<CandleData>> getHistory(String symbol,
      {String period = '1mo', String interval = '1d'}) async {
    final data =
        await _api.getHistory(symbol, period: period, interval: interval);
    final List<dynamic> records = data['data'];
    return records.map((e) => CandleData.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getInfo(String symbol) async {
    return await _api.getInfo(symbol);
  }

  Future<Map<String, dynamic>> getFinancials(String symbol) async {
    return await _api.getFinancials(symbol);
  }

    Future<Map<String, dynamic>> getStatements(String symbol) async {
    return await _api.getStatements(symbol);
  }


  Future<Map<String, dynamic>> getOptions(String symbol, {String? date}) async {
    return await _api.getOptions(symbol, date: date);
  }

  Future<Map<String, dynamic>> getHolders(String symbol) async {
    return await _api.getHolders(symbol);
  }

  Future<Map<String, dynamic>> getAnalysts(String symbol) async {
    return await _api.getAnalysts(symbol);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final data = await _api.search(query);
    final List<dynamic> results = data['results'];
    return results.cast<Map<String, dynamic>>();
  }
}
