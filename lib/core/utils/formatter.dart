import 'package:intl/intl.dart';

class Formatter {
  static NumberFormat _currencyFormat = NumberFormat.simpleCurrency(name: 'USD');
  static NumberFormat _compactCurrency = NumberFormat.compactSimpleCurrency(name: 'USD');
  static final NumberFormat _percentFormat = NumberFormat.decimalPattern()..maximumFractionDigits = 2..minimumFractionDigits = 2;

  static void updateCurrency(String currencyName) {
    _currencyFormat = NumberFormat.simpleCurrency(name: currencyName);
    _compactCurrency = NumberFormat.compactSimpleCurrency(name: currencyName);
  }

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompactCurrency(double amount) {
    return _compactCurrency.format(amount);
  }

  static String formatPercent(double percent) {
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${_percentFormat.format(percent)}%';
  }

  static String formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    }
    return volume.toString();
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MM/dd HH:mm').format(date);
  }
}
