// services/language_service.dart
import 'dart:ui';
import 'preferences_service.dart';

class LanguageService {
  // Singleton
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();
  
  // Servicios
  final PreferencesService _preferencesService = PreferencesService();
  
  // Idiomas disponibles
  final Map<String, Locale> _availableLanguages = {
    'Español': const Locale('es', 'ES'),
    'English': const Locale('en', 'US'),
    'Français': const Locale('fr', 'FR'),
    'Deutsch': const Locale('de', 'DE'),
  };
  
  // Obtener locale actual
  Locale getLocale() {
    final language = _preferencesService.language;
    return _availableLanguages[language] ?? const Locale('es', 'ES');
  }
  
  // Cambiar idioma
  Future<void> setLanguage(String language) async {
    if (_availableLanguages.containsKey(language)) {
      await _preferencesService.setLanguage(language);
    }
  }
  
  // Obtener todos los idiomas disponibles
  List<String> getAvailableLanguages() {
    return _availableLanguages.keys.toList();
  }
}