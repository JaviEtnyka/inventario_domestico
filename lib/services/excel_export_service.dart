import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// Añade este import para XFile
import '../controllers/item_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/location_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelExportService {
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  
  // Exportar todo el inventario a Excel
  Future<String?> exportInventoryToExcel() async {
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
      
      // Resto de tu código sin cambios...
      
      // Obtener todos los datos necesarios
      final items = await _itemController.getAllItems();
      final categories = await _categoryController.getAllCategories();
      final locations = await _locationController.getAllLocations();
      
      // Crear una instancia de Excel
      final Excel excel = Excel.createExcel();
      
      // Eliminar la hoja por defecto
      excel.delete('Sheet1');
      
      // Crear hoja para ítems
      final Sheet itemSheet = excel['Inventario'];
      
      // ... El resto de tu código para crear las hojas queda igual ...
      
      // Guardar archivo Excel
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'inventario_$timestamp.xlsx';
      final filePath = '$path/$fileName';
      
      // Guardar el archivo
      final List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        final File file = File(filePath);
        await file.writeAsBytes(excelBytes);
        return filePath;
      }
      
      return null;
    } catch (e) {
      print('Error al exportar a Excel: $e');
      return null;
    }
  }
  
  // Compartir el archivo exportado
  Future<bool> shareExcelFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        // Cambio aquí: usar shareXFiles en lugar de shareFiles
        await Share.shareXFiles([XFile(filePath)], text: 'Inventario Doméstico');
        return true;
      }
      return false;
    } catch (e) {
      print('Error al compartir archivo Excel: $e');
      return false;
    }
  }
}