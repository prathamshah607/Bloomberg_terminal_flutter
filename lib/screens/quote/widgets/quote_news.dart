import 'package:stocksim2/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/market_provider.dart';
import '../../../providers/news_provider.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatter.dart';

class QuoteNews extends ConsumerWidget {
  final String symbol;

  const QuoteNews({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    // Try to get longName from info provider if available, otherwise just use symbol
    final infoAsync = ref.watch(stockInfoProvider(symbol));
    String companyName = symbol;
    if (infoAsync.hasValue && infoAsync.value != null) {
      final longName = infoAsync.value!['longName'];
      if (longName != null && longName.toString().isNotEmpty) {
        companyName = longName.toString().split(' ')[0]; // Just take first part to avoid overly complex queries
      }
    }

    final key = StockNewsKey(symbol, companyName);
    final newsAsync = ref.watch(stockNewsProvider(key));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMPANY NEWS', style: TextStyles.terminalBody),
          const Divider(color: AppColors.border),
          newsAsync.when(skipLoadingOnReload: true,
        data: (articles) {
              if (articles.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('NO NEWS FOUND', style: TextStyles.terminalBodySmall)),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length > 5 ? 5 : articles.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return InkWell(
                    onTap: () async {
                      final url = Uri.parse(article.link);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  article.source,
                                  style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                Formatter.formatDateTime(article.pubDate),
                                style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: TerminalLoading(),
              ),
            ),
            error: (e, s) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load news: $e', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.negative)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
