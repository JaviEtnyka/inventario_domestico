// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/screens/home_screen.dart';
import 'config/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'services/preferences_service.dart';
import 'services/theme_service.dart';

void main() async {
  // Asegurar que Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  final preferencesService = PreferencesService();
  await preferencesService.init();
  
  final themeService = ThemeService();
  themeService.init();
  
   
  // Establecer orientación preferida
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Personalizar la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'Inventario Doméstico',
            theme: themeProvider.theme,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
              Locale('en', 'US'),
              Locale('fr', 'FR'),
              Locale('de', 'DE'),
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}