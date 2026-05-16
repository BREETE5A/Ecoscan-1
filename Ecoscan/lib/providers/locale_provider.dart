import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr'));

  static const supported = [
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
  ];

  void setLocale(Locale locale) => state = locale;

  String get langCode => state.languageCode;

  bool get isArabic => state.languageCode == 'ar';
}
