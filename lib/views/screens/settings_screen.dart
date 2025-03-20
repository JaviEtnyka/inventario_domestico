// views/screens/settings_screen.dart (implementado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/preferences_service.dart';
import '../../services/notification_service.dart';
import '../../services/data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Servicios
  final PreferencesService _preferencesService = PreferencesService();
  final NotificationService _notificationService = NotificationService();
  final DataService _dataService = DataService();
  
  // Estado
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isBackingUp = false;
  
  @override
  Widget build(BuildContext context) {
    // Acceder a los proveedores
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    // Flags para opciones de configuración
    bool darkModeEnabled = themeProvider.isDarkMode;
    String selectedLanguage = languageProvider.currentLanguage;
    bool notificationsEnabled = _preferencesService.notificationsEnabled;
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de apariencia
          _buildSectionHeader('Apariencia'),
          _buildSettingSwitch(
            title: 'Modo oscuro',
            subtitle: 'Cambiar entre tema claro y oscuro',
            value: darkModeEnabled,
            onChanged: (value) async {
              await themeProvider.toggleTheme();
            },
            icon: Icons.dark_mode,
          ),
          
          _buildSettingTile(
            title: 'Idioma',
            subtitle: 'Seleccionar idioma de la aplicación',
            trailing: Text(selectedLanguage),
            onTap: () {
              _showLanguageSelector(context, languageProvider);
            },
            icon: Icons.language,
          ),
          
          const Divider(),
          
          // Sección de notificaciones
          _buildSectionHeader('Notificaciones'),
          _buildSettingSwitch(
            title: 'Activar notificaciones',
            subtitle: 'Recibir alertas sobre tu inventario',
            value: notificationsEnabled,
            onChanged: (value) async {
              await _preferencesService.setNotificationsEnabled(value);
              
              // Mostrar notificación de prueba si se activan
              if (value) {
                await _notificationService.showNotification(
                  title: 'Notificaciones activadas',
                  body: 'Recibirás alertas sobre tu inventario',
                );
              } else {
                await _notificationService.cancelAllNotifications();
              }
              
              setState(() {});
            },
            icon: Icons.notifications,
          ),
          
          const Divider(),
          
          // Sección de datos
          _buildSectionHeader('Datos'),
          _buildSettingTile(
            title: 'Exportar inventario',
            subtitle: 'Generar archivo CSV con tus datos',
            trailing: _isExporting ? const CircularProgressIndicator() : null,
            onTap: _isExporting ? null : () async {
              setState(() {
                _isExporting = true;
              });
              
              // Mostrar opciones de exportación
              await _showExportOptions(context);
              
              setState(() {
                _isExporting = false;
              });
            },
            icon: Icons.upload_file,
          ),
          
          _buildSettingTile(
            title: 'Importar datos',
            subtitle: 'Cargar inventario desde archivo',
            trailing: _isImporting ? const CircularProgressIndicator() : null,
            onTap: _isImporting ? null : () async {
              setState(() {
                _isImporting = true;
              });
              
              // Importar desde JSON
              final success = await _dataService.importInventoryFromJson();
              
              setState(() {
                _isImporting = false;
              });
              
              // Mostrar resultado
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                      ? 'Datos importados correctamente' 
                      : 'Error al importar datos'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            icon: Icons.download,
          ),
          
          _buildSettingTile(
            title: 'Realizar copia de seguridad',
            subtitle: 'Guardar datos en la nube',
            trailing: _isBackingUp ? const CircularProgressIndicator() : null,
            onTap: _isBackingUp ? null : () async {
              setState(() {
                _isBackingUp = true;
              });
              
              // Realizar copia de seguridad
              final success = await _dataService.createBackup();
              
              setState(() {
                _isBackingUp = false;
              });
              
              // Mostrar resultado
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                      ? 'Copia de seguridad realizada correctamente' 
                      : 'Error al realizar copia de seguridad'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            icon: Icons.backup,
          ),
          
          const Divider(),
          
          // Sección Acerca de
          _buildSectionHeader('Acerca de'),
          _buildSettingTile(
            title: 'Versión',
            subtitle: AppConfig.appVersion,
            onTap: null,
            icon: Icons.info_outline,
          ),
          
          _buildSettingTile(
            title: 'Términos y condiciones',
            subtitle: 'Información legal',
            onTap: () {
              _showTextDialog(context, 'Términos y Condiciones', AppConfig.termsAndConditions);
            },
            icon: Icons.gavel,
          ),
          
          _buildSettingTile(
            title: 'Política de privacidad',
            subtitle: 'Uso de tus datos',
            onTap: () {
              _showTextDialog(context, 'Política de Privacidad', AppConfig.privacyPolicy);
            },
            icon: Icons.privacy_tip,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
  
  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _showLanguageSelector(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Seleccionar idioma'),
        children: provider.availableLanguages.map((language) {
          return SimpleDialogOption(
            onPressed: () {
              provider.setLanguage(language);
              Navigator.pop(context);
              
              // Mostrar mensaje de confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Idioma cambiado a $language'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  provider.currentLanguage == language
                      ? const Icon(Icons.radio_button_checked, color: AppTheme.primaryColor)
                      : const Icon(Icons.radio_button_unchecked),
                  const SizedBox(width: 16),
                  Text(language),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Future<void> _showExportOptions(BuildContext context) async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Exportar inventario'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.table_chart, color: Colors.green),
                  SizedBox(width: 16),
                  Text('Exportar como CSV'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'json'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.code, color: Colors.blue),
                  SizedBox(width: 16),
                  Text('Exportar como JSON'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    
    if (option == null) return;
    
    String? filePath;
    if (option == 'csv') {
      filePath = await _dataService.exportInventoryToCsv();
    } else if (option == 'json') {
      filePath = await _dataService.exportInventoryToJson();
    }
    
    // Mostrar resultado
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filePath != null 
              ? 'Archivo exportado correctamente' 
              : 'Error al exportar archivo'),
          backgroundColor: filePath != null ? Colors.green : Colors.red,
        ),
      );
    }
  }
  
  void _showTextDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadius),
                  topRight: Radius.circular(AppTheme.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    title.contains('Términos') ? Icons.gavel : Icons.privacy_tip,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            
            // Botón de cerrar
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}