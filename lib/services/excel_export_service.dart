import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
      
      // Agregar encabezados para la hoja de ítems
      final List<String> itemHeaders = [
        'ID', 'Nombre', 'Descripción', 'Valor', 
        'Categoría', 'Ubicación', 'Fecha de Compra',
        'Fecha de registro', 'Última actualización'
      ];
      
      // Estilo para encabezados
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#DDDDDD',
        horizontalAlign: HorizontalAlign.Center,
      );
      
      // Aplicar encabezados con estilo
      for (int i = 0; i < itemHeaders.length; i++) {
        final cell = itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = itemHeaders[i];
        cell.cellStyle = headerStyle;
      }
      
      // Agregar datos de ítems
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final int rowIndex = i + 1; // +1 porque la fila 0 tiene los encabezados
        
        // ID del ítem
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = item.id.toString();
        
        // Nombre del ítem
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = item.name;
        
        // Descripción del ítem
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = item.description ?? '';
        
        // Valor del ítem
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = item.value ?? 0.0;
        
        // Nombre de la categoría
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = item.categoryName ?? 'Sin categoría';
        
        // Nombre de la ubicación
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = item.locationName ?? 'Sin ubicación';
        
        // Fecha de compra
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = item.purchaseDate ?? '';
          
        // Fecha de registro
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = item.dateAdded ?? '';
          
        // Última actualización
        itemSheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = item.lastUpdated ?? '';
      }
      
      // Ajustar ancho de columnas (método actualizado)
      // En versiones recientes del paquete excel, esto se hace a través del mapa de columnas
      itemSheet.setColWidth(0, 10); // ID
      itemSheet.setColWidth(1, 25); // Nombre
      itemSheet.setColWidth(2, 40); // Descripción
      itemSheet.setColWidth(3, 15); // Valor
      itemSheet.setColWidth(4, 20); // Categoría
      itemSheet.setColWidth(5, 20); // Ubicación
      itemSheet.setColWidth(6, 20); // Fecha de compra
      itemSheet.setColWidth(7, 20); // Fecha de registro
      itemSheet.setColWidth(8, 20); // Última actualización
      
      // SEGUNDA HOJA: Categorías
      final Sheet categorySheet = excel['Categorías'];
      
      // Encabezados para categorías
      final List<String> categoryHeaders = ['ID', 'Nombre', 'Descripción', 'Ítems'];
      
      // Aplicar encabezados
      for (int i = 0; i < categoryHeaders.length; i++) {
        final cell = categorySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = categoryHeaders[i];
        cell.cellStyle = headerStyle;
      }
      
      // Contar ítems por categoría
      final Map<int?, int> itemsPerCategory = {};
      for (final item in items) {
        itemsPerCategory[item.categoryId] = (itemsPerCategory[item.categoryId] ?? 0) + 1;
      }
      
      // Agregar datos de categorías
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final int rowIndex = i + 1;
        
        // ID de la categoría
        categorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = category.id.toString();
        
        // Nombre de la categoría
        categorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = category.name;
        
        // Descripción de la categoría
        categorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = category.description ?? '';
        
        // Cantidad de ítems
        categorySheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = itemsPerCategory[category.id] ?? 0;
      }
      
      // Ajustar ancho de columnas
      categorySheet.setColWidth(0, 10); // ID
      categorySheet.setColWidth(1, 25); // Nombre
      categorySheet.setColWidth(2, 40); // Descripción
      categorySheet.setColWidth(3, 15); // Ítems
      
      // TERCERA HOJA: Ubicaciones
      final Sheet locationSheet = excel['Ubicaciones'];
      
      // Encabezados para ubicaciones
      final List<String> locationHeaders = ['ID', 'Nombre', 'Descripción', 'Ítems'];
      
      // Aplicar encabezados
      for (int i = 0; i < locationHeaders.length; i++) {
        final cell = locationSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = locationHeaders[i];
        cell.cellStyle = headerStyle;
      }
      
      // Contar ítems por ubicación
      final Map<int?, int> itemsPerLocation = {};
      for (final item in items) {
        itemsPerLocation[item.locationId] = (itemsPerLocation[item.locationId] ?? 0) + 1;
      }
      
      // Agregar datos de ubicaciones
      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final int rowIndex = i + 1;
        
        // ID de la ubicación
        locationSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = location.id.toString();
        
        // Nombre de la ubicación
        locationSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = location.name;
        
        // Descripción de la ubicación
        locationSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = location.description ?? '';
        
        // Cantidad de ítems
        locationSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = itemsPerLocation[location.id] ?? 0;
      }
      
      // Ajustar ancho de columnas
      locationSheet.setColWidth(0, 10); // ID
      locationSheet.setColWidth(1, 25); // Nombre
      locationSheet.setColWidth(2, 40); // Descripción
      locationSheet.setColWidth(3, 15); // Ítems
      
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
        await Share.shareFiles([filePath], text: 'Inventario Doméstico');
        return true;
      }
      return false;
    } catch (e) {
      print('Error al compartir archivo Excel: $e');
      return false;
    }
  }
}