import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import '../../../providers/ticker_tape_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class TerminalTickerTape extends ConsumerWidget {
  const TerminalTickerTape({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tapeAsync = ref.watch(asyncTickerTapeProvider);

    return Container(
      height: 30,
      width: double.infinity,
      color: AppColors.panelBackground,
      child: tapeAsync.when(skipLoadingOnReload: true,
        data: (quotes) {
          if (quotes.isEmpty) {
            return const Center(
              child: Text(
                'NO MARKET DATA CONNECTED...',
                style: TextStyles.terminalBodySmall,
              ),
            );
          }

          final buffer = StringBuffer();
          for (var q in quotes) {
            // Reformat DJI and GSPC to be friendlier
            String alias = q.symbol;
            if (alias == '^GSPC') alias = 'S&P500';
            if (alias == '^IXIC') alias = 'NASDAQ';
            if (alias == '^DJI') alias = 'DOW';

            final isPos = q.change >= 0;
            final sign = isPos ? '+' : '';
            buffer.write('  $alias ${q.price.toStringAsFixed(2)} (${sign}${q.changePercent.toStringAsFixed(2)}%) •');
          }

          return Marquee(
            text: buffer.toString(),
            style: TextStyles.terminalBody.copyWith(
              color: AppColors.primaryText, // Amber
              fontWeight: FontWeight.bold,
            ),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: 100.0,
            velocity: 40.0,
            startPadding: 10.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          );
        },
        loading: () => const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'WAITING FOR MARKET DATA...',
              style: TextStyles.terminalBodySmall,
            ),
          ),
        ),
        error: (err, stack) => const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'MARKET DATA OFFLINE (ERROR)',
              style: TextStyle(color: AppColors.negative, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
