// services/theme_service.dart
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'preferences_service.dart';

class ThemeService {
  // Singleton
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();
  
  // Servicios
  final PreferencesService _preferencesService = PreferencesService();
  
  // Temas
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;
  
  // Inicializar temas
  void init() {
    _lightTheme = AppTheme.lightTheme;
    
    // Crear tema oscuro basado en el tema claro
    _darkTheme = ThemeData.dark().copyWith(
      primaryColor: AppTheme.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        error: AppTheme.errorColor,
      ),
      appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
        backgroundColor: Colors.grey[900],
      ),
      cardTheme: AppTheme.lightTheme.cardTheme.copyWith(
        color: Colors.grey[850],
      ),
      elevatedButtonTheme: AppTheme.lightTheme.elevatedButtonTheme,
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Roboto',
      ),
    );
  }
  
  // Obtener tema actual
  ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? _darkTheme : _lightTheme;
  }
  
  // Cambiar tema
  Future<void> toggleTheme() async {
    final isDarkMode = _preferencesService.darkMode;
    await _preferencesService.setDarkMode(!isDarkMode);
  }
}