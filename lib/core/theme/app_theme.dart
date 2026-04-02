import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get bloombergTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryText,
      fontFamily: TextStyles.fontFamily,

      // Default Text Theme overrides for monospace amber
      textTheme: const TextTheme(
        bodyLarge: TextStyles.terminalBody,
        bodyMedium: TextStyles.terminalBody,
        displayLarge: TextStyles.terminalH1,
        displayMedium: TextStyles.terminalH2,
        titleMedium: TextStyles.terminalH2,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.terminalH2,
        iconTheme: IconThemeData(color: AppColors.primaryText),
      ),

      // Card / Container Theme
      cardTheme: CardTheme(
        color: AppColors.panelBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.0,
      ),

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryText, // Amber background
          foregroundColor: AppColors.background, // Black text
          textStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: TextStyles.fontFamily),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}
