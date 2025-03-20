// controllers/item_controller.dart (corregido)
import 'dart:io';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';

class ItemController {
  // Obtener todos los items
  Future<List<Item>> getAllItems() async {
    try {
      // Primero intentamos obtener datos de la API
      final items = await ApiService.getItems();
      
      // Si no hay datos o hay un error, usamos datos de prueba para desarrollo
      if (items.isEmpty) {
        bool isConnected = await ApiService.checkApiConnection();
        if (!isConnected) {
          return _getTestItems();
        }
      }
      
      return items;
    } catch (e) {
      print('Error en getAllItems: $e');
      // En caso de error, devolvemos datos de prueba para no bloquear la UI
      return _getTestItems();
    }
  }
  
  // Datos de prueba para desarrollo
  List<Item> _getTestItems() {
    return [
      Item(
        id: 1,
        name: 'Televisor Samsung',
        description: 'TV de 55 pulgadas 4K Smart TV',
        value: 1200.0,
        imageUrls: '',
        categoryId: 1,
        locationId: 1,
        categoryName: 'Electrónica',
        locationName: 'Sala de estar',
      ),
      Item(
        id: 2,
        name: 'Sofá',
        description: 'Sofá de 3 plazas color gris',
        value: 800.0,
        imageUrls: '',
        categoryId: 2,
        locationId: 1,
        categoryName: 'Muebles',
        locationName: 'Sala de estar',
      ),
      Item(
        id: 3,
        name: 'MacBook Pro',
        description: 'Laptop Apple 16" i9 32GB RAM',
        value: 2500.0,
        imageUrls: '',
        categoryId: 1,
        locationId: 4,
        categoryName: 'Electrónica',
        locationName: 'Oficina',
      ),
    ];
  }
  
  // Obtener un item por ID
  Future<Item> getItem(int id) async {
    try {
      return await ApiService.getItemById(id);
    } catch (e) {
      print('Error en getItem: $e');
      // Si no se puede obtener el item, buscarlo en los datos de prueba
      final testItems = _getTestItems();
      final item = testItems.firstWhere(
        (item) => item.id == id,
        orElse: () => throw Exception('Item no encontrado'),
      );
      return item;
    }
  }
  
  // Crear un nuevo item con imágenes
  Future<int> createItem(Item item, List<File> imageFiles) async {
    try {
      // Evitar procesar si no hay imágenes
      if (imageFiles.isEmpty) {
        return await ApiService.createItem(item);
      }
      
      // Optimizar imágenes antes de subirlas
      List<File> optimizedImages = [];
      for (var file in imageFiles) {
        try {
          File optimized = await ImageService.optimizeImage(file);
          optimizedImages.add(optimized);
        } catch (e) {
          print('Error optimizando imagen: $e');
          // Si falla la optimización, usar la original
          optimizedImages.add(file);
        }
      }
      
      // Subir imágenes
      List<String> imageUrls = await ApiService.uploadMultipleImages(optimizedImages);
      
      // Crear una copia del item con las URLs de las imágenes
      final itemWithImages = Item(
        name: item.name,
        description: item.description,
        value: item.value,
        categoryId: item.categoryId,
        locationId: item.locationId,
        imageUrls: imageUrls.join(','),
      );
      
      // Crear el item
      return await ApiService.createItem(itemWithImages);
    } catch (e) {
      print('Error en createItem: $e');
      // Para modo de desarrollo, devolvemos un ID falso
      return -1;
    }
  }
  
  // Actualizar un item existente
  Future<void> updateItem(Item item, List<File> newImageFiles) async {
    try {
      // Lista de todas las URLs de imágenes existentes
      List<String> allImageUrls = item.getImageUrlsList();
      
      // Si hay nuevas imágenes, optimizarlas y subirlas
      if (newImageFiles.isNotEmpty) {
        List<File> optimizedImages = [];
        for (var file in newImageFiles) {
          try {
            File optimized = await ImageService.optimizeImage(file);
            optimizedImages.add(optimized);
          } catch (e) {
            print('Error optimizando imagen: $e');
            optimizedImages.add(file);
          }
        }
        
        final newImageUrls = await ApiService.uploadMultipleImages(optimizedImages);
        allImageUrls.addAll(newImageUrls);
      }
      
      // Crear una copia del item con todas las URLs de las imágenes
      final itemWithImages = Item(
        id: item.id,
        name: item.name,
        description: item.description,
        value: item.value,
        purchaseDate: item.purchaseDate,
        categoryId: item.categoryId,
        locationId: item.locationId,
        imageUrls: allImageUrls.join(','),
      );
      
      // Actualizar el item
      await ApiService.updateItem(itemWithImages);
    } catch (e) {
      print('Error en updateItem: $e');
      rethrow;
    }
  }
  
  // Eliminar un item
  Future<void> deleteItem(int id) async {
    try {
      await ApiService.deleteItem(id);
    } catch (e) {
      print('Error en deleteItem: $e');
      rethrow;
    }
  }
  
  // Buscar items por texto
  Future<List<Item>> searchItems(String query) async {
    try {
      final items = await getAllItems();
      if (query.isEmpty) return items;
      
      query = query.toLowerCase();
      return items.where((item) {
        return item.name.toLowerCase().contains(query) ||
               item.description.toLowerCase().contains(query) ||
               (item.categoryName?.toLowerCase().contains(query) ?? false) ||
               (item.locationName?.toLowerCase().contains(query) ?? false);
      }).toList();
    } catch (e) {
      print('Error en searchItems: $e');
      return [];
    }
  }
  
  // Filtrar items por categoría
  Future<List<Item>> filterByCategory(int categoryId) async {
    try {
      final items = await getAllItems();
      return items.where((item) => item.categoryId == categoryId).toList();
    } catch (e) {
      print('Error en filterByCategory: $e');
      return [];
    }
  }
  
  // Filtrar items por ubicación
  Future<List<Item>> filterByLocation(int locationId) async {
    try {
      final items = await getAllItems();
      return items.where((item) => item.locationId == locationId).toList();
    } catch (e) {
      print('Error en filterByLocation: $e');
      return [];
    }
  }
  
  // Obtener el valor total del inventario
  Future<double> getTotalInventoryValue() async {
    try {
      final items = await getAllItems();
      double total = 0.0;
      for (var item in items) {
        total += item.value;
      }
      return total;
    } catch (e) {
      print('Error en getTotalInventoryValue: $e');
      return 0.0;
    }
  }
}