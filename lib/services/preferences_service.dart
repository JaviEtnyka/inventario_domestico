// services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Claves para preferencias
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyNotifications = 'notifications';
  
  // Singleton
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();
  
  // Valores por defecto
  bool _darkMode = false;
  String _language = 'Español';
  bool _notificationsEnabled = true;
  
  // Getters
  bool get darkMode => _darkMode;
  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  
  // Inicializar preferencias
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(keyDarkMode) ?? false;
    _language = prefs.getString(keyLanguage) ?? 'Español';
    _notificationsEnabled = prefs.getBool(keyNotifications) ?? true;
  }
  
  // Guardar modo oscuro
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDarkMode, value);
    _darkMode = value;
  }
  
  // Guardar idioma
  Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, value);
    _language = value;
  }
  
  // Guardar preferencia de notificaciones
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifications, value);
    _notificationsEnabled = value;
  }
}