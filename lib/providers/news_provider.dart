import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/news_repository.dart';
import '../data/models/news_article.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

final newsSearchQueryProvider = StateProvider<String>((ref) => '');

// Always fetches general 'Market' headlines. Used by the home screen ticker/panel.
final generalNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repo = ref.read(newsRepositoryProvider);
  return repo.getGeneralMarketNews('Market Stock Market News');
});

// Fetches news based on the search query. If empty, falls back to general news.
final searchNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repo = ref.read(newsRepositoryProvider);
  final query = ref.watch(newsSearchQueryProvider);
  
  if (query.trim().isEmpty) {
    return repo.getGeneralMarketNews('Market Stock Market News');
  } else {
    return repo.getGeneralMarketNews(query);
  }
});

class StockNewsKey {
  final String symbol;
  final String companyName;

  StockNewsKey(this.symbol, this.companyName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockNewsKey &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          companyName == other.companyName;

  @override
  int get hashCode => symbol.hashCode ^ companyName.hashCode;
}

final stockNewsProvider =
    FutureProvider.family<List<NewsArticle>, StockNewsKey>((ref, key) async {
  final repo = ref.read(newsRepositoryProvider);
  return repo.getNewsForStock(key.symbol, key.companyName);
});
