// services/data_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/item_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/location_controller.dart';
import 'package:file_selector/file_selector.dart';

class DataService {
  // Controladores
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  
  // Exportar inventario a CSV
  Future<String?> exportInventoryToCsv() async {
    try {
      // Solicitar permisos de almacenamiento si es necesario
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            return null;
          }
        }
      }
      
      // Obtener datos
      final items = await _itemController.getAllItems();
      
      // Crear contenido CSV
      List<List<dynamic>> csvData = [];
      
      // Cabecera
      csvData.add([
        'ID', 'Nombre', 'Descripción', 'Valor', 
        'Categoría', 'Ubicación', 'Fecha de compra',
        'Fecha de registro', 'Última actualización'
      ]);
      
      // Datos
      for (var item in items) {
        csvData.add([
          item.id,
          item.name,
          item.description,
          item.value,
          item.categoryName,
          item.locationName,
          item.purchaseDate ?? '',
          item.dateAdded ?? '',
          item.lastUpdated ?? ''
        ]);
      }
      
      // Convertir a string CSV
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('$path/inventario_$timestamp.csv');
      await file.writeAsString(csv);
      
      // Compartir archivo
      await Share.shareXFiles([XFile(file.path)], text: 'Inventario Doméstico');
      
      return file.path;
    } catch (e) {
      print('Error al exportar a CSV: $e');
      return null;
    }
  }
  
  // Exportar inventario a JSON
  Future<String?> exportInventoryToJson() async {
    try {
      // Solicitar permisos de almacenamiento si es necesario
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            return null;
          }
        }
      }
      
      // Obtener datos
      final items = await _itemController.getAllItems();
      final categories = await _categoryController.getAllCategories();
      final locations = await _locationController.getAllLocations();
      
      // Crear estructura de datos JSON
      final Map<String, dynamic> jsonData = {
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'value': item.value,
          'category_id': item.categoryId,
          'location_id': item.locationId,
          'image_urls': item.imageUrls,
          'purchase_date': item.purchaseDate,
          'date_added': item.dateAdded,
          'last_updated': item.lastUpdated,
        }).toList(),
        'categories': categories.map((category) => {
          'id': category.id,
          'name': category.name,
          'description': category.description,
        }).toList(),
        'locations': locations.map((location) => {
          'id': location.id,
          'name': location.name,
          'description': location.description,
        }).toList(),
      };
      
      // Convertir a string JSON
      String jsonString = jsonEncode(jsonData);
      
      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('$path/inventario_$timestamp.json');
      await file.writeAsString(jsonString);
      
      // Compartir archivo
      await Share.shareXFiles([XFile(file.path)], text: 'Inventario Doméstico');
      
      return file.path;
    } catch (e) {
      print('Error al exportar a JSON: $e');
      return null;
    }
  }
  
  // Importar inventario desde archivo JSON
Future<bool> importInventoryFromJson() async {
  try {
    // Definir los tipos de archivo permitidos
    const XTypeGroup jsonTypeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
    );
    
    // Seleccionar archivo
    final XFile? file = await openFile(
      acceptedTypeGroups: [jsonTypeGroup],
    );
    
    if (file != null) {
      // Leer archivo
      final jsonString = await file.readAsString();
      
      // Decodificar JSON
      final jsonData = jsonDecode(jsonString);
      
      // TODO: Implementar la lógica para guardar los datos en la base de datos
      // Esto dependerá de la implementación de tu API y servicios
      
      return true;
    }
    
    return false;
  } catch (e) {
    print('Error al importar desde JSON: $e');
    return false;
  }
}
  
  // Realizar copia de seguridad
  Future<bool> createBackup() async {
    // En una implementación real, esto podría subir los datos a un servicio en la nube
    // Por ahora, simplemente creamos un archivo JSON local
    final result = await exportInventoryToJson();
    return result != null;
  }
}