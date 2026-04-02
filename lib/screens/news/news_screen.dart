import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/terminal_scaffold.dart';
import '../../providers/news_provider.dart';
import '../../widgets/loading_shimmer.dart';
import '../../core/utils/formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final _searchController = TextEditingController();

  final List<String> _quickChips = [
    'All',
    'Fed & Rates',
    'Tech',
    'Crypto',
    'Commodities',
    'Earnings',
    'M&A'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(newsSearchQueryProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    ref.read(newsSearchQueryProvider.notifier).state = query;
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(searchNewsProvider);
    final currentSearch = ref.watch(newsSearchQueryProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return TerminalScaffold(
      title: currentSearch.isEmpty ? 'GLOBAL HEADLINES' : 'NEWS: ${currentSearch.toUpperCase()}',
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyles.terminalBody.copyWith(color: AppColors.primaryText),
              cursorColor: AppColors.primaryText,
              decoration: InputDecoration(
                hintText: 'SEARCH FINANCIAL NEWS...',
                hintStyle: TextStyles.terminalBody.copyWith(color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                suffixIcon: currentSearch.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.secondaryText),
                        onPressed: () {
                          _searchController.clear();
                          _submitSearch('');
                        },
                      )
                    : null,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryText),
                ),
                filled: true,
                fillColor: AppColors.panelBackground,
              ),
              onSubmitted: _submitSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Quick Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _quickChips.length,
              itemBuilder: (context, index) {
                final chip = _quickChips[index];
                final isSelected = currentSearch.toLowerCase() == chip.toLowerCase() || (chip == 'All' && currentSearch.isEmpty);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(chip, style: TextStyles.terminalBodySmall.copyWith(
                      color: isSelected ? AppColors.background : AppColors.primaryText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppColors.primaryText,
                    backgroundColor: AppColors.panelBackground,
                    side: BorderSide(color: isSelected ? AppColors.primaryText : AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onSelected: (selected) {
                      if (chip == 'All') {
                        _searchController.clear();
                        _submitSearch('');
                      } else {
                        _searchController.text = chip;
                        _submitSearch(chip);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          
          Expanded(
            child: newsAsync.when(
              skipLoadingOnReload: true,
              data: (articles) {
                if (articles.isEmpty) {
                  return const Center(child: Text("NO NEWS FOUND", style: TextStyles.terminalBody));
                }

                return RefreshIndicator(
                  color: AppColors.primaryText,
                  backgroundColor: AppColors.panelBackground,
                  onRefresh: () async {
                    ref.invalidate(searchNewsProvider);
                  },
                  child: isDesktop 
                      ? _buildDesktopGrid(articles) 
                      : _buildMobileList(articles),
                );
              },
              loading: () => ListView.separated(
                itemCount: 10,
                separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                itemBuilder: (_, __) => const SizedBox(height: 100, width: double.infinity, child: TerminalLoading()),
              ),
              error: (e, s) => Center(child: Text("ERROR FETCHING FEED: $e", style: TextStyles.terminalBodySmall.copyWith(color: AppColors.negative))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<dynamic> articles) {
    return ListView.separated(
      itemCount: articles.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
      itemBuilder: (context, index) {
        return _NewsTile(article: articles[index]);
      },
    );
  }

  Widget _buildDesktopGrid(List<dynamic> articles) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisExtent: 160,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return _DesktopNewsCard(article: articles[index]);
      },
    );
  }
}

class _NewsTile extends StatelessWidget {
  final dynamic article;

  const _NewsTile({required this.article});

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: TextStyles.terminalBody.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(article.source, style: TextStyles.terminalBodySmall.copyWith(fontSize: 10, color: AppColors.whiteText)),
                ),
                Text(Formatter.formatDateTime(article.pubDate), style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopNewsCard extends StatelessWidget {
  final dynamic article;

  const _DesktopNewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = Uri.parse(article.link);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panelBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(article.source, style: TextStyles.terminalBodySmall.copyWith(fontSize: 10, color: AppColors.whiteText)),
                ),
                Text(Formatter.formatDateTime(article.pubDate), style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                article.title,
                style: TextStyles.terminalBody.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
