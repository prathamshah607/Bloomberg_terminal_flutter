import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/charts/terminal_line_chart.dart';
import '../../quote/quote_screen.dart';

class MarketOverviewPanel extends ConsumerStatefulWidget {
  const MarketOverviewPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketOverviewPanel> createState() => _MarketOverviewPanelState();
}

class _MarketOverviewPanelState extends ConsumerState<MarketOverviewPanel> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: AppColors.primaryText,
            unselectedLabelColor: AppColors.secondaryText,
            indicatorColor: AppColors.primaryText,
            tabs: [
              Tab(text: 'Global Indices'),
              Tab(text: 'Currencies'),
              Tab(text: 'My Portfolio'),
            ],
          ),
          const Divider(height: 1),
          const Expanded(
            child: TabBarView(
              children: [
                _MiniChartGrid(symbols: ['^GSPC', '^IXIC', '^DJI', '^RUT', '^VIX', '^FTSE']),
                _MiniChartGrid(symbols: ['USDINR=X', 'EURINR=X', 'GBPINR=X', 'JPYINR=X', 'AUDINR=X', 'SGDINR=X']),
                _PortfolioGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioGrid extends ConsumerWidget {
  const _PortfolioGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final holds = portfolio.holdings.keys.toList();

    if (holds.isEmpty) {
      return const Center(child: Text("NO HOLDINGS IN PORTFOLIO"));
    }

    return _MiniChartGrid(symbols: holds);
  }
}

class _MiniChartGrid extends StatelessWidget {
  final List<String> symbols;

  const _MiniChartGrid({Key? key, required this.symbols}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.2,
      ),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        return _MiniChartCard(symbol: symbols[index]);
      },
    );
  }
}

class _MiniChartCard extends ConsumerWidget {
  final String symbol;

  const _MiniChartCard({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (symbol: symbol, period: '1mo', interval: '1d');
    final historyAsync = ref.watch(stockHistoryProvider(args));

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => QuoteScreen(symbol: symbol)));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          color: AppColors.panelBackground,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symbol,
              style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: historyAsync.when(
                skipLoadingOnReload: true,
                data: (candles) {
                  if (candles.isEmpty) {
                    return const Center(child: Text('NO DATA', style: TextStyles.terminalBodySmall));
                  }
                  return TerminalLineChart(data: candles);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('ERR', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.negative))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
