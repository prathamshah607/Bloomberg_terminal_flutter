import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/formatter.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

class AppSettings {
  final String currency;
  final int updateFrequencySeconds;

  const AppSettings({
    this.currency = 'INR',
    this.updateFrequencySeconds = 15,
  });

  AppSettings copyWith({
    String? currency,
    int? updateFrequencySeconds,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      updateFrequencySeconds: updateFrequencySeconds ?? this.updateFrequencySeconds,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final currency = prefs.getString('setting_currency') ?? 'INR';
    final freq = prefs.getInt('setting_update_frequency') ?? 15;
    state = AppSettings(currency: currency, updateFrequencySeconds: freq);
    Formatter.updateCurrency(currency);
  }

  Future<void> updateCurrency(String newCurrency) async {
    await prefs.setString('setting_currency', newCurrency);
    state = state.copyWith(currency: newCurrency);
    Formatter.updateCurrency(newCurrency);
  }

  Future<void> updateFrequency(int seconds) async {
    await prefs.setInt('setting_update_frequency', seconds);
    state = state.copyWith(updateFrequencySeconds: seconds);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
