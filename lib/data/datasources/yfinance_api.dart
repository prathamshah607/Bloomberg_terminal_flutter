import 'dart:convert';
import 'package:http/http.dart' as http;

class YFinanceApi {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/Web/Desktop
  // Assuming desktop linux here based on the environment
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> getQuote(String symbol) async {
    final response = await http.get(Uri.parse('$baseUrl/quote/$symbol'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load quote for $symbol');
    }
  }

  Future<Map<String, dynamic>> getHistory(String symbol,
      {String period = '1mo', String interval = '1d'}) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/history/$symbol?period=$period&interval=$interval'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load history for $symbol');
    }
  }

  Future<Map<String, dynamic>> getInfo(String symbol) async {
    final response = await http.get(Uri.parse('$baseUrl/info/$symbol'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load info for $symbol');
    }
  }

  Future<Map<String, dynamic>> getFinancials(String symbol) async {
    final response = await http.get(Uri.parse('$baseUrl/financials/$symbol'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load financials for $symbol');
    }
  }

    Future<Map<String, dynamic>> getStatements(String symbol) async {
    final response = await http.get(Uri.parse('$baseUrl/advanced/statements/$symbol'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load statements for $symbol');
    }
  }


  Future<Map<String, dynamic>> getOptions(String symbol, {String? date}) async {
    String url = '$baseUrl/advanced/options/$symbol';
    if (date != null) url += '?date=$date';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load options for $symbol');
    }
  }

  Future<Map<String, dynamic>> getHolders(String symbol) async {
    final response = await http.get(Uri.parse('$baseUrl/advanced/holders/$symbol'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load holders for $symbol');
    }
  }

  Future<Map<String, dynamic>> getAnalysts(String symbol) async {
    final response = await http.get(Uri.parse('$baseUrl/advanced/analysts/$symbol'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load analysts for $symbol');
    }
  }

  Future<Map<String, dynamic>> search(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search for $query');
    }
  }
}
