import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider(this.prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final isDark = prefs.getBool(StorageKeys.themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(StorageKeys.themeKey, isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(StorageKeys.themeKey, isDark);
    notifyListeners();
  }
}
