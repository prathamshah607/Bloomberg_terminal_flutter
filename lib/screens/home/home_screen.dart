import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/resizable_split_view.dart';
import '../../widgets/terminal_scaffold.dart';
import '../watchlist/watchlist_screen.dart';
import '../trade_history/trade_history_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../settings/settings_screen.dart';
import '../screener/screener_screen.dart';
import '../news/news_screen.dart';
import 'widgets/market_overview.dart';
import 'widgets/portfolio_panel.dart';
import 'widgets/watchlist_panel.dart';
import 'widgets/news_panel.dart';
import 'widgets/ticker_tape.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TerminalScaffold(
      title: 'BLOOMBERG TERMINAL',
      drawer: null, // removes drawer icon
      actions: [
        IconButton(
          icon: const Icon(Icons.list_alt, color: AppColors.primaryText),
          tooltip: 'Watchlist',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WatchlistScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.history, color: AppColors.primaryText),
          tooltip: 'Trade History',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TradeHistoryScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.pie_chart, color: AppColors.primaryText),
          tooltip: 'Portfolio',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.newspaper, color: AppColors.primaryText),
          tooltip: 'News',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primaryText),
          tooltip: 'Search & Screener',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenerScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.primaryText),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          const TerminalTickerTape(),
          const SizedBox(height: 8),
          Expanded(
            child: ResizableSplitView(
              axis: Axis.horizontal,
              initialFraction: 0.3,
              first: _buildLeftColumn(),
              second: _buildRightColumn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return const ResizableSplitView(
      axis: Axis.vertical,
      initialFraction: 0.35, 
      first: PortfolioPanel(),
      second: WatchlistPanel(),
    );
  }

  Widget _buildRightColumn() {
    return const ResizableSplitView(
      axis: Axis.vertical,
      initialFraction: 0.65, 
      first: MarketOverviewPanel(),
      second: NewsPanel(),
    );
  }
}
