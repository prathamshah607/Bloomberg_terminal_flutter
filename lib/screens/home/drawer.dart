import 'package:flutter/material.dart';
import '../watchlist/watchlist_screen.dart';
import '../trade_history/trade_history_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../news/news_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

Widget buildHomeDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: AppColors.background,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: AppColors.panelBackground,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Text(
            'STOCKS SIM\nTERMINAL',
            style: TextStyles.terminalBody,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.list_alt, color: AppColors.whiteText),
          title: const Text('Watchlist', style: TextStyles.terminalBody),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WatchlistScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.history, color: AppColors.whiteText),
          title: const Text('Trade History', style: TextStyles.terminalBody),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TradeHistoryScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.pie_chart, color: AppColors.whiteText),
          title: const Text('Portfolio', style: TextStyles.terminalBody),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.newspaper, color: AppColors.whiteText),
          title: const Text('News', style: TextStyles.terminalBody),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()));
          },
        ),
        const Divider(color: AppColors.border),
        ListTile(
          leading: const Icon(Icons.settings, color: AppColors.whiteText),
          title: const Text('Settings', style: TextStyles.terminalBody),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
    ),
  );
}
