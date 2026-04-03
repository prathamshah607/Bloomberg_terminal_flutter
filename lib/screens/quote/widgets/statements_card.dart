import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class StatementsCard extends ConsumerWidget {
  final String symbol;

  const StatementsCard({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementsAsync = ref.watch(stockStatementsProvider(symbol));

    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border.all(color: AppColors.border),
      ),
      child: statementsAsync.when(skipLoadingOnReload: true,
        data: (data) {
          final inc = data['income_stmt'] as Map<String, dynamic>? ?? {};
          final bal = data['balance_sheet'] as Map<String, dynamic>? ?? {};
          final csh = data['cashflow'] as Map<String, dynamic>? ?? {};

          return DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('FINANCIAL STATEMENTS', style: TextStyles.terminalBody.copyWith(color: AppColors.whiteText, fontWeight: FontWeight.bold)),
                ),
                const TabBar(
                  indicatorColor: AppColors.primaryText,
                  labelColor: AppColors.primaryText,
                  unselectedLabelColor: AppColors.secondaryText,
                  tabs: [
                    Tab(text: "INCOME"),
                    Tab(text: "BALANCE"),
                    Tab(text: "CASH FLOW"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTable(inc),
                      _buildTable(bal),
                      _buildTable(csh),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('ERROR: $err', style: TextStyles.terminalBody.copyWith(color: AppColors.negative))),
      ),
    );
  }

  Widget _buildTable(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: Text("NO DATA AVAILABLE", style: TextStyles.terminalBodySmall));
    }

    // Extract dates from the first metric's keys
    final firstMetricKey = data.keys.first;
    final firstMetricMap = data[firstMetricKey] as Map<String, dynamic>? ?? {};
    final dates = firstMetricMap.keys.toList()..sort((a,b) => b.compareTo(a)); // Sort descending
    
    // Sort metrics alphabetically
    final sortedMetrics = data.keys.toList()..sort();

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            headingTextStyle: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
            dataTextStyle: TextStyles.terminalBodySmall.copyWith(color: AppColors.whiteText),
            columnSpacing: 32,
            horizontalMargin: 0,
            columns: [
              const DataColumn(label: Text('METRIC')),
              ...dates.map((d) => DataColumn(label: Text(d), numeric: true)),
            ],
            rows: sortedMetrics.map((metric) {
              final vals = data[metric] as Map<String, dynamic>? ?? {};
              return DataRow(
                cells: [
                  DataCell(Text(metric, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ...dates.map((d) => DataCell(Text(_formatCompact(vals[d])))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _formatCompact(dynamic value) {
    if (value == null) return '-';
    num val = value is num ? value : num.tryParse(value.toString()) ?? 0;
    if (val == 0) return '-';
    
    final isNegative = val < 0;
    val = val.abs();
    
    String formatted = '';
    if (val >= 1000000000) {
      formatted = '${(val / 1000000000).toStringAsFixed(2)}B';
    } else if (val >= 1000000) {
      formatted = '${(val / 1000000).toStringAsFixed(2)}M';
    } else if (val >= 1000) {
      formatted = '${(val / 1000).toStringAsFixed(2)}K';
    } else {
      formatted = val.toStringAsFixed(0);
    }
    
    return isNegative ? "(₹$formatted)" : "₹$formatted";
  }
}
