import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/market_provider.dart';
import '../quote/quote_screen.dart';

final screenerQueryProvider = StateProvider<String>((ref) => '');

class ScreenerScreen extends ConsumerWidget {
  const ScreenerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(screenerQueryProvider);
    final searchAsync = ref.watch(searchProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panelBackground,
        title: TextField(
          autofocus: true,
          style: TextStyles.terminalBody.copyWith(color: AppColors.primaryText, fontSize: 16),
          decoration: InputDecoration(
            hintText: '> ENTER SYMBOL OR COMPANY...',
            hintStyle: TextStyles.terminalBody.copyWith(color: AppColors.secondaryText),
            border: InputBorder.none,
          ),
          onSubmitted: (val) {
            ref.read(screenerQueryProvider.notifier).state = val;
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: query.isEmpty
          ? const Center(
              child: Text(
                'AWAITING INPUT...',
                style: TextStyles.terminalBody,
              ),
            )
          : searchAsync.when(skipLoadingOnReload: true,
        data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('NO RESULTS FOUND.', style: TextStyles.terminalBody));
                }
                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final res = results[index];
                    final symbol = res['symbol'] ?? 'UNKNOWN';
                    final name = res['longname'] ?? res['shortname'] ?? res['exchDisp'] ?? '';
                    final type = res['quoteType'] ?? '';

                    return ListTile(
                      title: Text(
                        symbol,
                        style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.whiteText),
                      ),
                      subtitle: Text(
                        '$name - $type',
                        style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuoteScreen(symbol: symbol),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryText)),
              error: (err, stack) => Center(child: Text('ERROR: \$err', style: TextStyle(color: AppColors.negative))),
            ),
    );
  }
}
