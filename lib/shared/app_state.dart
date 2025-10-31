import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  // Notifiers to allow the app to react to changes at runtime
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );
  static final ValueNotifier<Locale?> locale = ValueNotifier(null);

  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'Claro';
    themeMode.value = theme == 'Oscuro' ? ThemeMode.dark : ThemeMode.light;

    final language = prefs.getString('language');
    if (language != null) {
      locale.value =
          language == 'English' ? const Locale('en') : const Locale('es');
    } else {
      locale.value = null;
    }
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    themeMode.value = theme == 'Oscuro' ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    locale.value =
        language == 'English' ? const Locale('en') : const Locale('es');
  }
}
