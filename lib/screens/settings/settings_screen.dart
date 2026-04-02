import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/terminal_scaffold.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return TerminalScaffold(
      title: 'SYSTEM CONFIGURATION',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('DISPLAY PREFERENCES'),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('BASE CURRENCY', style: TextStyles.terminalBody),
            subtitle: Text('Select the default currency symbol rendered on screens.', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
            trailing: DropdownButton<String>(
              dropdownColor: AppColors.panelBackground,
              value: settings.currency,
              style: TextStyles.terminalBody.copyWith(color: AppColors.primaryText),
              underline: const SizedBox(),
              items: ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD'].map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  settingsNotifier.updateCurrency(val);
                }
              },
            ),
          ),
          const Divider(color: AppColors.border, height: 32),
          
          _buildHeader('DATA REFRESH'),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('POLLING FREQUENCY', style: TextStyles.terminalBody),
            subtitle: Text('How often the live market providers ping the backend.', style: TextStyles.terminalBodySmall.copyWith(color: AppColors.secondaryText)),
            trailing: DropdownButton<int>(
              dropdownColor: AppColors.panelBackground,
              value: settings.updateFrequencySeconds,
              style: TextStyles.terminalBody.copyWith(color: AppColors.primaryText),
              underline: const SizedBox(),
              items: [5, 10, 15, 30, 60, 300].map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text('${s}s'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  settingsNotifier.updateFrequency(val);
                }
              },
            ),
          ),
          const Divider(color: AppColors.border, height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      color: AppColors.primaryText.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        '< $title >',
        style: TextStyles.terminalBody.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
      ),
    );
  }
}
