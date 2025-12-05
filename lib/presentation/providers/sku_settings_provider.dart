import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkuSettings {
  final String pattern;
  final bool autoGenerate;
  final int lastSequentialNumber;

  const SkuSettings({
    this.pattern = '{category}-{name}-{number}',
    this.autoGenerate = false,
    this.lastSequentialNumber = 0,
  });

  SkuSettings copyWith({
    String? pattern,
    bool? autoGenerate,
    int? lastSequentialNumber,
  }) {
    return SkuSettings(
      pattern: pattern ?? this.pattern,
      autoGenerate: autoGenerate ?? this.autoGenerate,
      lastSequentialNumber: lastSequentialNumber ?? this.lastSequentialNumber,
    );
  }
}

class SkuSettingsNotifier extends StateNotifier<SkuSettings> {
  SkuSettingsNotifier() : super(const SkuSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final pattern = prefs.getString('sku_pattern') ?? '{category}-{name}-{number}';
    final autoGenerate = prefs.getBool('sku_auto_generate') ?? false;
    final lastSequentialNumber = prefs.getInt('sku_last_sequential_number') ?? 0;

    state = SkuSettings(
      pattern: pattern,
      autoGenerate: autoGenerate,
      lastSequentialNumber: lastSequentialNumber,
    );
  }

  Future<void> saveSettings({
    String? pattern,
    bool? autoGenerate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (pattern != null) {
      await prefs.setString('sku_pattern', pattern);
    }
    
    if (autoGenerate != null) {
      await prefs.setBool('sku_auto_generate', autoGenerate);
    }
    
    state = state.copyWith(
      pattern: pattern,
      autoGenerate: autoGenerate,
    );
  }

  Future<int> getNextSequentialNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final nextNumber = state.lastSequentialNumber + 1;
    
    await prefs.setInt('sku_last_sequential_number', nextNumber);
    state = state.copyWith(lastSequentialNumber: nextNumber);
    
    return nextNumber;
  }

  Future<void> resetSequentialNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sku_last_sequential_number', 0);
    state = state.copyWith(lastSequentialNumber: 0);
  }
}

final skuSettingsProvider = StateNotifierProvider<SkuSettingsNotifier, SkuSettings>((ref) {
  return SkuSettingsNotifier();
});
