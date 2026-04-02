import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/text_styles.dart';

class TerminalScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? drawer;

  const TerminalScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: TextStyles.terminalH2.copyWith(letterSpacing: 2.0),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.primaryText,
            height: 1.0,
          ),
        ),
        actions: actions,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.0),
              color: AppColors.background,
            ),
            child: body,
          ),
        ),
      ),
    );
  }
}
