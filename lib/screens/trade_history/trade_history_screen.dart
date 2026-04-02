import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatter.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/terminal_scaffold.dart';

class TradeHistoryScreen extends ConsumerWidget {
  const TradeHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final history = portfolio.tradeHistory.reversed.toList();

    return TerminalScaffold(
      title: 'TRADE HISTORY LOG',
      body: history.isEmpty
          ? const Center(
              child: Text(
                'NO TRADES EXECUTED YET',
                style: TextStyles.terminalBody,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final trade = history[index];
                final isBuy = trade.isBuy;
                final color = isBuy ? AppColors.positive : AppColors.negative;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                     color: AppColors.panelBackground,
                     border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: color.withOpacity(0.2),
                        child: Text(
                          isBuy ? 'BUY' : 'SELL',
                          style: TextStyles.terminalBodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        trade.symbol,
                        style: TextStyles.terminalBody.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${trade.quantity} @ ${Formatter.formatCurrency(trade.price)}',
                            style: TextStyles.terminalBody,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trade.timestamp.toString().split('.')[0],
                            style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
