import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/terminal_scaffold.dart';

import 'widgets/pnl_summary.dart';
import 'widgets/allocation_pie.dart';
import 'widgets/holdings_table.dart';
import 'widgets/portfolio_waterfall.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TerminalScaffold(
      title: 'PORTFOLIO DASHBOARD',
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 16),
            PnLSummary(),
            SizedBox(height: 24),
            AllocationPie(),
            SizedBox(height: 24),
            PortfolioWaterfall(),
            SizedBox(height: 24),
            HoldingsTable(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
