// providers/language_provider.dart
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/preferences_service.dart';

class LanguageProvider extends ChangeNotifier {
  // Servicios
  final LanguageService _languageService = LanguageService();
  final PreferencesService _preferencesService = PreferencesService();
  
  // Estado
  late String _currentLanguage;
  
  // Constructor
  LanguageProvider() {
    _currentLanguage = _preferencesService.language;
  }
  
  // Getters
  String get currentLanguage => _currentLanguage;
  Locale get locale => _languageService.getLocale();
  List<String> get availableLanguages => _languageService.getAvailableLanguages();
  
  // Cambiar idioma
  Future<void> setLanguage(String language) async {
    await _languageService.setLanguage(language);
    _currentLanguage = _preferencesService.language;
    notifyListeners();
  }
}