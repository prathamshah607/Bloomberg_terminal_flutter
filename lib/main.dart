import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const StockSimApp(),
    ),
  );
}

class StockSimApp extends ConsumerWidget {
  const StockSimApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly watch settings so they are loaded and applied to the Formatter.
    ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Mock Terminal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.bloombergTheme,
      home: const HomeScreen(),
    );
  }
}
