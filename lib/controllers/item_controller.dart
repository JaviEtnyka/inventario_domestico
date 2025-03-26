// controllers/item_controller.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../config/api_config.dart';

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
      // Primero, si hay imágenes, subir y obtener URLs
      List<String> imageUrls = [];
      
      if (imageFiles.isNotEmpty) {
        try {
          // Optimiza imágenes para reducir su tamaño
          List<File> optimizedImages = await ImageService.optimizeImages(imageFiles);
          
          // Intenta subir imágenes
          imageUrls = await ApiService.uploadMultipleImages(optimizedImages);
          print('URLs de imágenes obtenidas: $imageUrls');
        } catch (imageError) {
          print('Error al subir imágenes: $imageError');
          // Continuar sin imágenes en caso de error
        }
      }
      
      // Crear copia del ítem con URLs de imágenes
      final itemWithImages = Item(
        name: item.name,
        description: item.description,
        value: item.value,
        categoryId: item.categoryId,
        locationId: item.locationId,
        imageUrls: imageUrls.join(','), // Unir URLs con coma
      );
      
      // Imprimir JSON para depuración
      print('Item a guardar: ${json.encode(itemWithImages.toJson())}');
      
      // Crear ítem
      return await ApiService.createItem(itemWithImages);
    } catch (e) {
      print('Error en createItem: $e');
      rethrow;
    }
  }
  
  // Actualizar un item existente
  Future<void> updateItem(Item item, List<File> newImageFiles, {List<String> imagesToDelete = const []}) async {
    try {
      // Si hay imágenes para eliminar, procesarlas primero
      if (imagesToDelete.isNotEmpty) {
        for (String imageUrl in imagesToDelete) {
          try {
            await deleteImage(imageUrl);
          } catch (e) {
            print('Error al eliminar imagen $imageUrl: $e');
            // Continuamos incluso si falla una eliminación
          }
        }
      }
      
      // Filtrar las URLs de imágenes existentes que no están marcadas para eliminar
      List<String> remainingImageUrls = item.getImageUrlsList()
          .where((url) => !imagesToDelete.contains(url))
          .toList();
      
      // Si hay nuevas imágenes, optimizarlas y subirlas
      if (newImageFiles.isNotEmpty) {
        try {
          List<File> optimizedImages = await ImageService.optimizeImages(newImageFiles);
          final newImageUrls = await ApiService.uploadMultipleImages(optimizedImages);
          remainingImageUrls.addAll(newImageUrls);
        } catch (e) {
          print('Error al procesar nuevas imágenes: $e');
          // Continuamos con las imágenes que se hayan podido procesar
        }
      }
      
      // Crear una copia del item con las URLs de imágenes actualizadas
      final itemWithImages = Item(
        id: item.id,
        name: item.name,
        description: item.description,
        value: item.value,
        purchaseDate: item.purchaseDate,
        categoryId: item.categoryId,
        locationId: item.locationId,
        imageUrls: remainingImageUrls.join(','),
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

  // Elimina una imagen del servidor
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      print('🗑️ Eliminando imagen: $imageUrl');
      
      final response = await http.post(
        Uri.parse(ApiConfig.deleteImage),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imageUrl': imageUrl})
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Respuesta de eliminación:');
      print('   - Código: ${response.statusCode}');
      print('   - Cuerpo: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al eliminar imagen: $e');
      return false;
    }
  }
}