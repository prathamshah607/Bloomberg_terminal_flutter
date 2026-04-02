import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

import 'widgets/price_header.dart';
import 'widgets/fundamentals_card.dart';
import 'widgets/order_panel.dart';
import 'widgets/quote_chart.dart';
import 'widgets/quote_news.dart';
import 'widgets/recent_history_table.dart';
import 'widgets/statements_card.dart';
import 'widgets/advanced_data_card.dart';
import '../chart/chart_screen.dart';

class QuoteScreen extends ConsumerWidget {
  final String symbol;

  const QuoteScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Decide layout based on screen width
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panelBackground,
        title: Text(
          'QUOTE : $symbol',
          style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
             icon: const Icon(Icons.show_chart, color: AppColors.primaryText),
             tooltip: 'Technical Chart',
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (_) => ChartScreen(symbol: symbol),
                 ),
               );
             },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Trading & Techs)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PriceHeader(symbol: symbol),
              const SizedBox(height: 16),
              QuoteChart(symbol: symbol),
              const SizedBox(height: 16),
              OrderPanel(symbol: symbol),
              const SizedBox(height: 16),
              RecentHistoryTable(symbol: symbol),
              const SizedBox(height: 16),
              QuoteNews(symbol: symbol),
            ],
          ),
        ),
        
        // Right Column (Fundamentals & Detail)
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FundamentalsCard(symbol: symbol),
              const SizedBox(height: 16),
              DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TabBar(
                      labelColor: AppColors.primaryText,
                      unselectedLabelColor: AppColors.secondaryText,
                      indicatorColor: AppColors.primaryText,
                      tabs: [
                        Tab(text: 'Financial Statements'),
                        Tab(text: 'Advanced Intelligence'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 550,
                      child: TabBarView(
                        children: [
                          StatementsCard(symbol: symbol),
                          AdvancedDataCard(symbol: symbol),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PriceHeader(symbol: symbol),
        const SizedBox(height: 16),
        QuoteChart(symbol: symbol),
        const SizedBox(height: 16),
        OrderPanel(symbol: symbol),
        const SizedBox(height: 16),
        FundamentalsCard(symbol: symbol),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                labelColor: AppColors.primaryText,
                unselectedLabelColor: AppColors.secondaryText,
                indicatorColor: AppColors.primaryText,
                tabs: [
                  Tab(text: 'Statements'),
                  Tab(text: 'Advanced'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 550,
                child: TabBarView(
                  children: [
                    StatementsCard(symbol: symbol),
                    AdvancedDataCard(symbol: symbol),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RecentHistoryTable(symbol: symbol),
        const SizedBox(height: 16),
        QuoteNews(symbol: symbol),
        const SizedBox(height: 32),
      ],
    );
  }
}
