import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/terminal_scaffold.dart';
import '../home/widgets/watchlist_panel.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TerminalScaffold(
      title: 'WATCHLIST MANAGER',
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 16),
            WatchlistPanel(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
