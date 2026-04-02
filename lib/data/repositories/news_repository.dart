import '../models/news_article.dart';
import '../datasources/rss_feed_parser.dart';

class NewsRepository {
  Future<List<NewsArticle>> getNewsForStock(String symbol, String companyName) async {
    try {
      final articles = await RssFeedParser.fetchGoogleNews(symbol, companyName);
      return articles;
    } catch (e) {
      print("Error fetching news in repository: $e");
      return [];
    }
  }

  Future<List<NewsArticle>> getGeneralMarketNews([String query = 'Market Stock Market News']) async {
    try {
      final articles = await RssFeedParser.fetchSearchNews(query);
      return articles;
    } catch (e) {
      print("Error fetching market news in repository: $e");
      return [];
    }
  }
}
