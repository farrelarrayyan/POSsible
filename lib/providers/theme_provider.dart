import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Default value
  bool _isDarkMode = false;
  Color _accentColor = Colors.blue;

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;

  // Muat tema yang tersimpan saat app dibuka
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Fungsi untuk mengganti Dark/Light mode
  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    // Simpan ke SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_dark', isDark);
  }

  // Fungsi untuk mengganti warna accent
  void changeAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();

    // Simpan nilai integer dari warna ke SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('accent_color', color.value);
  }

  // Fungsi internal untuk memuat data dari memori
  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark') ?? false; // Default light mode (fasle)
    
    int? colorValue = prefs.getInt('accent_color');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    notifyListeners();
  }

  // Fungsi untuk menghasilkan ThemeData yang akan dipakai oleh aplikasi
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _accentColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}