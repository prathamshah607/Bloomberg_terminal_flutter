import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:http_parser/http_parser.dart';
import '../models/news_article.dart';

class RssFeedParser {
  /// Fetches Google News RSS for an arbitrary search string
  static Future<List<NewsArticle>> fetchSearchNews(String rawQuery) async {
    final query = Uri.encodeComponent(rawQuery);
    final url = Uri.parse('https://news.google.com/rss/search?q=$query&hl=en-US&gl=US&ceid=US:en');
    
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch RSS. Status: ${response.statusCode}');
      }

      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      List<NewsArticle> articles = [];
      for (var node in items) {
        String title = node.findElements('title').singleOrNull?.innerText ?? 'No Title';
        String link = node.findElements('link').singleOrNull?.innerText ?? '';
        String pubDateStr = node.findElements('pubDate').singleOrNull?.innerText ?? '';
        String source = node.findElements('source').singleOrNull?.innerText ?? 'Google News';

        if (title.endsWith(' - $source')) {
          title = title.substring(0, title.length - (source.length + 3));
        }

        DateTime pubDate;
        try {
          pubDate = parseHttpDate(pubDateStr);
        } catch (e) {
          pubDate = DateTime.now();
        }

        articles.add(NewsArticle(
          title: title.trim(),
          link: link.trim(),
          source: source.trim(),
          pubDate: pubDate,
        ));
      }

      articles.sort((a, b) => b.pubDate.compareTo(a.pubDate));
      return articles.take(25).toList();
    } catch (e) {
      print('RSS Parsing Error: $e');
      return [];
    }
  }

  /// Fetches Google News RSS for a specific stock query
  static Future<List<NewsArticle>> fetchGoogleNews(String ticker, String companyName) async {
    return fetchSearchNews('$ticker "$companyName" stock');
  }
}

extension XmlNodeIterable on Iterable<XmlElement> {
  XmlElement? get singleOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) {
      var result = iterator.current;
      if (!iterator.moveNext()) return result;
    }
    return null;
  }
}
