import 'package:stocksim2/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/news_provider.dart';
import '../../../widgets/loading_shimmer.dart';
import '../../../core/utils/formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';

class NewsPanel extends ConsumerWidget {
  const NewsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);

    final newsAsyncValue = ref.watch(generalNewsProvider);

    return newsAsyncValue.when(skipLoadingOnReload: true,
        data: (articles) {
        if (articles.isEmpty) {
          return const Center(child: Text("NO NEWS FOUND"));
        }
        return ListView.separated(
          itemCount: articles.length,
          separatorBuilder: (context, index) => const Divider(color: AppColors.border),
          itemBuilder: (context, index) {
            final article = articles[index];
            return _NewsListTile(article: article);
          },
        );
      },
      loading: () => ListView.separated(
         itemCount: 8,
         separatorBuilder: (context, index) => const Divider(color: AppColors.border),
         itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.all(8.0),
          child: TerminalLoading(
           ),
         ),
      ),
      error: (error, stack) => Center(
        child: Text(
          "ERR: FAILED TO FETCH NEWS\n${error.toString()}",
          style: TextStyles.terminalBodySmall.copyWith(color: AppColors.negative),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NewsListTile extends StatelessWidget {
  final article;
  
  const _NewsListTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = Uri.parse(article.link);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: TextStyles.terminalBody.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                    style: TextStyles.terminalBodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  Formatter.formatDateTime(article.pubDate),
                  style: TextStyles.terminalBodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
