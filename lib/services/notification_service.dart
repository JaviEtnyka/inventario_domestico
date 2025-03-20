// services/notification_service.dart (compatible con todas las versiones)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'preferences_service.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  // Variables
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final PreferencesService _preferencesService = PreferencesService();
  bool _initialized = false;
  
  // Inicializar notificaciones
  Future<void> init() async {
    if (_initialized) return;
    
    // Configurar notificaciones para Android
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configurar notificaciones para iOS
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Configuración general
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Inicializar plugin
    await _notifications.initialize(initSettings);
    
    _initialized = true;
  }
  
  // Mostrar notificación inmediata
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_preferencesService.notificationsEnabled) return;
    
    await init();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'inventory_channel',
      'Inventario Doméstico',
      channelDescription: 'Notificaciones de la aplicación Inventario Doméstico',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await init();
    await _notifications.cancelAll();
  }
}