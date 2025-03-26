// controllers/location_controller.dart
import 'dart:io';
import '../models/location.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';

class LocationController {
  // Obtener todas las ubicaciones
  Future<List<Location>> getAllLocations() async {
    try {
      // Primero intentamos obtener datos de la API
      final locations = await ApiService.getLocations();
      
      // Si no hay datos o hay un error, usamos datos de prueba para desarrollo
      if (locations.isEmpty) {
        bool isConnected = await ApiService.checkApiConnection();
        if (!isConnected) {
          return _getTestLocations();
        }
      }
      
      return locations;
    } catch (e) {
      print('Error en getAllLocations: $e');
      // En caso de error, devolvemos datos de prueba para no bloquear la UI
      return _getTestLocations();
    }
  }
  
  // Datos de prueba para desarrollo
  List<Location> _getTestLocations() {
    return [
      Location(
        id: 1, 
        name: 'Sala de estar', 
        description: 'Área principal',
        imageUrls: ['https://ejemplo.com/sala.jpg']
      ),
      Location(
        id: 2, 
        name: 'Dormitorio', 
        description: 'Habitación principal',
        imageUrls: ['https://ejemplo.com/dormitorio.jpg']
      ),
      // ... otros datos de prueba
    ];
  }
  
  // Obtener una ubicación por ID
  Future<Location> getLocation(int id) async {
    try {
      return await ApiService.getLocationById(id);
    } catch (e) {
      print('Error en getLocation: $e');
      // Si no se puede obtener la ubicación, buscarla en los datos de prueba
      final testLocations = _getTestLocations();
      final location = testLocations.firstWhere(
        (location) => location.id == id,
        orElse: () => throw Exception('Ubicación no encontrada'),
      );
      return location;
    }
  }
  
  // Crear una nueva ubicación con imágenes
  Future<int> createLocation(Location location, {List<File>? imageFiles}) async {
    try {
      List<String> imageUrls = [];
      
      // Procesar imágenes si hay
      if (imageFiles != null && imageFiles.isNotEmpty) {
        // Optimizar imágenes
        List<File> optimizedImages = await ImageService.optimizeImages(imageFiles);
        
        // Subir imágenes
        imageUrls = await ApiService.uploadMultipleImages(optimizedImages);
      }
      
      // Crear ubicación con las URLs de imágenes
      final locationWithImages = location.clone(
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null
      );
      
      return await ApiService.createLocation(locationWithImages);
    } catch (e) {
      print('Error en createLocation: $e');
      // Para modo de desarrollo, devolvemos un ID falso
      return -1;
    }
  }
  
  // Actualizar una ubicación existente con imágenes
  Future<void> updateLocation(Location location, {List<File>? newImageFiles}) async {
    try {
      // Obtener las URLs de imágenes existentes
      List<String> allImageUrls = location.imageUrls ?? [];
      
      // Procesar nuevas imágenes si hay
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        // Optimizar imágenes
        List<File> optimizedImages = await ImageService.optimizeImages(newImageFiles);
        
        // Subir nuevas imágenes
        List<String> newImageUrls = await ApiService.uploadMultipleImages(optimizedImages);
        
        // Añadir nuevas URLs a la lista existente
        allImageUrls.addAll(newImageUrls);
      }
      
      // Crear ubicación actualizada con todas las URLs de imágenes
      final updatedLocation = location.clone(
        imageUrls: allImageUrls.isNotEmpty ? allImageUrls : null
      );
      
      print('LocationController: Actualizando ubicación ${updatedLocation.id} - ${updatedLocation.name}');
      await ApiService.updateLocation(updatedLocation);
    } catch (e) {
      print('Error en LocationController.updateLocation: $e');
      rethrow;
    }
  }
  
  // Eliminar una ubicación
  Future<void> deleteLocation(int id) async {
    try {
      // Obtener la ubicación para manejar sus imágenes
      final location = await getLocation(id);
      
      // Eliminar imágenes asociadas si existen
      if (location.imageUrls != null) {
        for (var imageUrl in location.imageUrls!) {
          await ApiService.deleteImage(imageUrl);
        }
      }
      
      // Eliminar la ubicación
      print('LocationController: Eliminando ubicación con ID $id');
      await ApiService.deleteLocation(id);
    } catch (e) {
      print('Error en LocationController.deleteLocation: $e');
      rethrow;
    }
  }
  
  // Eliminar una imagen específica de una ubicación
  Future<Location> removeLocationImage(Location location, String imageUrl) async {
    try {
      // Intentar eliminar la imagen del servidor
      final deleteSuccess = await ApiService.deleteImage(imageUrl);
      
      if (deleteSuccess) {
        // Crear una nueva ubicación sin la imagen eliminada
        return location.removeImage(imageUrl);
      }
      
      // Si la eliminación falla, devolver la ubicación original
      return location;
    } catch (e) {
      print('Error al eliminar imagen de ubicación: $e');
      return location;
    }
  }
  
  // Buscar ubicaciones por nombre
  Future<List<Location>> searchLocationsByName(String query) async {
    try {
      final locations = await getAllLocations();
      if (query.isEmpty) return locations;
      
      query = query.toLowerCase();
      return locations.where((location) {
        return location.name.toLowerCase().contains(query) ||
               location.description.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      print('Error en searchLocationsByName: $e');
      return [];
    }
  }
}