class NewsArticle {
  final String title;
  final String link;
  final String source;
  final DateTime pubDate;

  NewsArticle({
    required this.title,
    required this.link,
    required this.source,
    required this.pubDate,
  });

  @override
  String toString() {
    return 'NewsArticle(title: $title, source: $source, pubDate: $pubDate)';
  }
}
