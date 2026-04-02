import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/text_styles.dart';

class ChangeBadge extends StatelessWidget {
  final double change;
  final bool isPercent;

  const ChangeBadge({
    Key? key,
    required this.change,
    this.isPercent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final color = isPositive ? AppColors.positive : AppColors.negative;
    final String sign = isPositive ? '+' : '';
    final String val = change.toStringAsFixed(2);
    final String suffix = isPercent ? '%' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Text(
        '$sign$val$suffix',
        style: TextStyles.terminalBody.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
