import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TerminalLoading extends StatelessWidget {
  const TerminalLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressPadding(),
    );
  }
}

class CircularProgressPadding extends StatelessWidget {
  const CircularProgressPadding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
        ),
      ),
    );
  }
}
