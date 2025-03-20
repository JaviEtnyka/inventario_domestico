// config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF3F51B5);    // Indigo
  static const Color secondaryColor = Color(0xFF2196F3);  // Azul
  
  // Colores para categorías específicas
  static const Color inventoryColor = Color(0xFF2196F3);  // Azul
  static const Color categoryColor = Color(0xFFFF9800);   // Naranja
  static const Color locationColor = Color(0xFF4CAF50);   // Verde
  
  // Colores complementarios
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris claro
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);      // Rojo
  
  // Radios de borde
  static const double borderRadius = 12.0;
  static const double buttonRadius = 8.0;
  
  // Sombras
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
  
  // Tema claro para la aplicación
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    primarySwatch: Colors.indigo,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: titleStyle,
      titleMedium: subtitleStyle,
      bodyMedium: bodyStyle,
      bodySmall: captionStyle,
    ),
  );
}