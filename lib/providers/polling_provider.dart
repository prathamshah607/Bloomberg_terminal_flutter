import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

final pollTickProvider = StreamProvider<int>((ref) {
  final freq = ref.watch(settingsProvider.select((s) => s.updateFrequencySeconds));
  return Stream.periodic(Duration(seconds: freq), (count) => count);
});
