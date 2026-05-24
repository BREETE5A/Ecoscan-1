import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier()..loadSavedTheme(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  static const _key = 'selected_theme';

  Future<void> loadSavedTheme() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString(_key);
    state = switch (saved) {
      'light'  => ThemeMode.light,
      'dark'   => ThemeMode.dark,
      _        => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, switch (mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    });
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }

  bool get isDark => state == ThemeMode.dark;

  String get modeLabel => switch (state) {
    ThemeMode.light  => 'Clair',
    ThemeMode.dark   => 'Sombre',
    ThemeMode.system => 'Système',
  };

  String get modeEmoji => switch (state) {
    ThemeMode.light  => '☀️',
    ThemeMode.dark   => '🌙',
    ThemeMode.system => '📱',
  };
}
