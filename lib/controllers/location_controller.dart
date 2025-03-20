// controllers/location_controller.dart
import '../models/location.dart';
import '../services/api_service.dart';

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
      Location(id: 1, name: 'Sala de estar', description: 'Área principal'),
      Location(id: 2, name: 'Dormitorio', description: 'Habitación principal'),
      Location(id: 3, name: 'Cocina', description: 'Área de preparación de alimentos'),
      Location(id: 4, name: 'Oficina', description: 'Espacio de trabajo'),
      Location(id: 5, name: 'Garaje', description: 'Almacenamiento y vehículos'),
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
  
  // Crear una nueva ubicación
  Future<int> createLocation(Location location) async {
    try {
      return await ApiService.createLocation(location);
    } catch (e) {
      print('Error en createLocation: $e');
      // Para modo de desarrollo, devolvemos un ID falso
      return -1;
    }
  }
  
  // Actualizar una ubicación existente
  Future<void> updateLocation(Location location) async {
    try {
      await ApiService.updateLocation(location);
    } catch (e) {
      print('Error en updateLocation: $e');
      rethrow;
    }
  }
  
  // Eliminar una ubicación
  Future<void> deleteLocation(int id) async {
    try {
      await ApiService.deleteLocation(id);
    } catch (e) {
      print('Error en deleteLocation: $e');
      rethrow;
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