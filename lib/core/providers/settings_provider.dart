import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/hive_service.dart';

class AppSettings {
  final String currency;
  final Locale locale;
  final bool hasSeenOnboarding;

  const AppSettings({
    this.currency = 'JD',
    this.locale = const Locale('en'),
    this.hasSeenOnboarding = false,
  });

  AppSettings copyWith({
    String? currency,
    Locale? locale,
    bool? hasSeenOnboarding,
  }) =>
      AppSettings(
        currency: currency ?? this.currency,
        locale: locale ?? this.locale,
        hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  void _load() {
    final box = HiveService.settingsBox;
    final currency = box.get('currency', defaultValue: 'JD') as String;
    // Until the user explicitly picks a language in Settings, follow the
    // device locale (Arabic if the phone is Arabic, English otherwise).
    final lang = box.containsKey('locale')
        ? box.get('locale') as String
        : (PlatformDispatcher.instance.locale.languageCode == 'ar'
            ? 'ar'
            : 'en');
    final seen =
        box.get('hasSeenOnboarding', defaultValue: false) as bool;
    state = AppSettings(
      currency: currency,
      locale: Locale(lang),
      hasSeenOnboarding: seen,
    );
  }

  Future<void> setCurrency(String currency) async {
    await HiveService.settingsBox.put('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> setLocale(Locale locale) async {
    await HiveService.settingsBox.put('locale', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> markOnboardingSeen() async {
    if (state.hasSeenOnboarding) return;
    await HiveService.settingsBox.put('hasSeenOnboarding', true);
    state = state.copyWith(hasSeenOnboarding: true);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (_) => SettingsNotifier(),
);
