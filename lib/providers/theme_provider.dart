// providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  // Servicios
  final ThemeService _themeService = ThemeService();
  final PreferencesService _preferencesService = PreferencesService();
  
  // Estado
  late bool _isDarkMode;
  
  // Constructor
  ThemeProvider() {
    _isDarkMode = _preferencesService.darkMode;
  }
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  ThemeData get theme => _themeService.getTheme(_isDarkMode);
  
  // Cambiar tema
  Future<void> toggleTheme() async {
    await _themeService.toggleTheme();
    _isDarkMode = _preferencesService.darkMode;
    notifyListeners();
  }
}