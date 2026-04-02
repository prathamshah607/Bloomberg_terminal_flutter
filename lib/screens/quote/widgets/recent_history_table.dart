import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/market_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class RecentHistoryTable extends ConsumerWidget {
  final String symbol;

  const RecentHistoryTable({Key? key, required this.symbol}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch last 1mo of daily data
    final historyAsync = ref.watch(stockHistoryProvider((symbol: symbol, period: '1mo', interval: '1d')));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT HISTORY (OHLCV)', style: TextStyles.terminalBody.copyWith(color: AppColors.whiteText, fontWeight: FontWeight.bold)),
          const Divider(color: AppColors.border),
          historyAsync.when(skipLoadingOnReload: true,
            data: (candles) {
              if (candles.isEmpty) return const Text('NO DATA', style: TextStyles.terminalBodySmall);
              
              // Sort descending (latest first) and take top 5
              final list = candles.toList()..sort((a,b) => b.date.compareTo(a.date));
              final recent = list.take(5).toList();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                  dataTextStyle: TextStyles.terminalBodySmall.copyWith(color: AppColors.primaryText),
                  columnSpacing: 24,
                  horizontalMargin: 0,
                  dividerThickness: 0.1,
                  columns: const [
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('OPEN'), numeric: true),
                    DataColumn(label: Text('HIGH'), numeric: true),
                    DataColumn(label: Text('LOW'), numeric: true),
                    DataColumn(label: Text('CLOSE'), numeric: true),
                    DataColumn(label: Text('VOLUME'), numeric: true),
                  ],
                  rows: recent.map((c) {
                    final dateStr = "${c.date.year}-${c.date.month.toString().padLeft(2,'0')}-${c.date.day.toString().padLeft(2,'0')}";
                    final color = c.close >= c.open ? AppColors.positive : AppColors.negative;
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(dateStr, style: TextStyle(color: AppColors.whiteText))),
                        DataCell(Text(c.open.toStringAsFixed(2))),
                        DataCell(Text(c.high.toStringAsFixed(2), style: TextStyle(color: AppColors.positive))),
                        DataCell(Text(c.low.toStringAsFixed(2), style: TextStyle(color: AppColors.negative))),
                        DataCell(Text(c.close.toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.bold))),
                        DataCell(Text(_formatCompact(c.volume))),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('ERROR: $err', style: TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(dynamic value) {
    if (value == null) return 'N/A';
    num val = value is num ? value : num.tryParse(value.toString()) ?? 0;
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(2)}M';
    } else if (val >= 1000) {
       return '${(val / 1000).toStringAsFixed(2)}K';
    }
    return val.toStringAsFixed(0);
  }
}
