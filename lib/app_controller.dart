import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void changeLanguage(String lang) {
    _locale = Locale(lang);
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}