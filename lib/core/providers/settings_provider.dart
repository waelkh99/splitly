import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/hive_service.dart';

class AppSettings {
  final String currency;
  final Locale locale;

  const AppSettings({
    this.currency = 'JD',
    this.locale = const Locale('en'),
  });

  AppSettings copyWith({String? currency, Locale? locale}) => AppSettings(
        currency: currency ?? this.currency,
        locale: locale ?? this.locale,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  void _load() {
    final box = HiveService.settingsBox;
    final currency = box.get('currency', defaultValue: 'JD') as String;
    final lang = box.get('locale', defaultValue: 'en') as String;
    state = AppSettings(currency: currency, locale: Locale(lang));
  }

  Future<void> setCurrency(String currency) async {
    await HiveService.settingsBox.put('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> setLocale(Locale locale) async {
    await HiveService.settingsBox.put('locale', locale.languageCode);
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (_) => SettingsNotifier(),
);
