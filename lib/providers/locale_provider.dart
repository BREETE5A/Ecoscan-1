import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final notifier = LocaleNotifier();
  notifier.loadSavedLocale();
  return notifier;
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr'));

  static const _key = 'selected_locale';
  static const _supportedCodes = ['fr', 'en', 'ar', 'es'];

  static const supported = [
    Locale('fr'), Locale('en'), Locale('ar'), Locale('es'),
  ];

  static const supportedLanguages = [
    {'code': 'fr', 'name': 'Français',  'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'en', 'name': 'English',   'flag': '🇬🇧', 'native': 'English'},
    {'code': 'ar', 'name': 'العربية',   'flag': '🇲🇦', 'native': 'العربية'},
    {'code': 'es', 'name': 'Español',   'flag': '🇪🇸', 'native': 'Español'},
  ];

  Future<void> loadSavedLocale() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString(_key);
    if (saved != null) {
      state = Locale(saved);
    } else {
      state = _detectSystemLocale();
    }
  }

  Locale _detectSystemLocale() {
    for (final loc in ui.PlatformDispatcher.instance.locales) {
      if (_supportedCodes.contains(loc.languageCode)) {
        return Locale(loc.languageCode);
      }
    }
    return const Locale('fr');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, locale.languageCode);
  }

  Future<void> resetToSystem() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
    state = _detectSystemLocale();
  }

  String get langCode => state.languageCode;
  bool get isArabic => state.languageCode == 'ar';
}
