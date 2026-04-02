import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../chart_screen.dart';

class TimeframeSelector extends ConsumerWidget {
  const TimeframeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPeriod = ref.watch(chartPeriodProvider);

    return Container(
      color: AppColors.panelBackground,
      height: 48,
      child: Row(
        children: [
          _buildBtn(ref, currentPeriod, '1D', '1d', '5m'),
          _buildBtn(ref, currentPeriod, '1W', '5d', '15m'),
          _buildBtn(ref, currentPeriod, '1M', '1mo', '1d'),
          _buildBtn(ref, currentPeriod, '3M', '3mo', '1d'),
          _buildBtn(ref, currentPeriod, '1Y', '1y', '1d'),
          _buildBtn(ref, currentPeriod, '5Y', '5y', '1wk'),
        ],
      ),
    );
  }

  Widget _buildBtn(WidgetRef ref, String activeP, String label, String p, String i) {
    final isActive = activeP == p;
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(chartPeriodProvider.notifier).state = p;
          ref.read(chartIntervalProvider.notifier).state = i;
        },
        child: Container(
          color: isActive ? AppColors.border : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyles.terminalBodySmall.copyWith(
              color: isActive ? AppColors.whiteText : AppColors.secondaryText,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
