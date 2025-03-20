// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../models/location.dart';

class ApiService {
  // ========== ITEMS ==========
  
  /// Obtiene todos los items del inventario
  static Future<List<Item>> getItems() async {
    try {
      print('Obteniendo items desde: ${ApiConfig.readItems}');
      final response = await http.get(Uri.parse(ApiConfig.readItems));
      
      print('Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (!decodedData.containsKey('records')) {
          print('La respuesta no contiene la clave "records"');
          return [];
        }
        
        final List<dynamic> itemsJson = decodedData['records'];
        print('Items encontrados: ${itemsJson.length}');
        
        return itemsJson.map((json) => Item.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron items (404)');
        return [];
      } else {
        throw Exception('Error al obtener los items: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en getItems: $e');
      // Para desarrollo, devuelve una lista vacía en lugar de lanzar otra excepción
      return [];
    }
  }
  
  /// Obtiene un item por su ID
  static Future<Item> getItemById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.readOneItem}?id=$id'));
      
      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getItemById: $e');
      rethrow;
    }
  }
  
  /// Crea un nuevo item
  static Future<int> createItem(Item item) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createItem),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson())
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('id')) {
          return int.parse(data['id'].toString());
        } else {
          return 0; // Si no hay ID, devolvemos 0 temporalmente
        }
      } else {
        throw Exception('Error al crear el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createItem: $e');
      rethrow;
    }
  }
  
  /// Actualiza un item existente
static Future<void> updateItem(Item item) async {
  try {
    // Imprimir el contenido del JSON que enviamos
    final jsonData = item.toJson();
    print('Actualizando item ID ${item.id}');
    print('JSON enviado: ${json.encode(jsonData)}');
    print('URL: ${ApiConfig.updateItem}');
    
    final response = await http.post(
      Uri.parse(ApiConfig.updateItem),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(jsonData)
    ).timeout(const Duration(seconds: 15)); // Añadir timeout para evitar esperas largas
    
    print('Respuesta HTTP: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el item: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    // En caso de error de conexión, proporcionar más información
    if (e.toString().contains('XMLHttpRequest error') || 
        e.toString().contains('SocketException') ||
        e.toString().contains('TimeoutException')) {
      print('Error de conexión detectado: $e');
      
      // Intentar verificar si el servidor está disponible directamente
      try {
        final testResponse = await http.get(
          Uri.parse(ApiConfig.baseUrl),
        ).timeout(const Duration(seconds: 5));
        
        print('Prueba de conexión al servidor: ${testResponse.statusCode}');
      } catch (connectionError) {
        print('Error confirmado al intentar conectar con el servidor: $connectionError');
      }
    }
    
    print('Error detallado en updateItem: $e');
    rethrow;
  }
}
  
  /// Elimina un item por su ID
  static Future<void> deleteItem(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteItem),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteItem: $e');
      rethrow;
    }
  }
  
  // ========== CATEGORÍAS ==========
  
  /// Obtiene todas las categorías
  static Future<List<Category>> getCategories() async {
    try {
      print('Obteniendo categorías desde: ${ApiConfig.readCategories}');
      final response = await http.get(Uri.parse(ApiConfig.readCategories));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (!decodedData.containsKey('records')) {
          print('La respuesta no contiene la clave "records"');
          return [];
        }
        
        final List<dynamic> categoriesJson = decodedData['records'];
        print('Categorías encontradas: ${categoriesJson.length}');
        
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron categorías (404)');
        return [];
      } else {
        throw Exception('Error al obtener las categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en getCategories: $e');
      return [];
    }
  }

  static Future<bool> isServerAvailable() async {
  try {
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl),
    ).timeout(const Duration(seconds: 5));
    
    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (e) {
    print('Error al verificar disponibilidad del servidor: $e');
    return false;
  }
}
  
  /// Obtiene una categoría por su ID
  static Future<Category> getCategoryById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.readOneCategory}?id=$id'));
      
      if (response.statusCode == 200) {
        return Category.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener la categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getCategoryById: $e');
      rethrow;
    }
  }
  
  /// Crea una nueva categoría
  static Future<int> createCategory(Category category) async {
  try {
    print('Enviando datos: ${json.encode(category.toJson())}');
    
    final response = await http.post(
      Uri.parse(ApiConfig.createCategory),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toJson())
    );
    
    print('Respuesta HTTP: ${response.statusCode}');
    print('Cuerpo de respuesta: ${response.body}');
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Manejar si el servidor devuelve un id
      if (data.containsKey('id')) {
        return int.parse(data['id'].toString());
      } 
      // Si no hay id pero la creación fue exitosa, devolver un valor temporal
      else {
        print('Advertencia: Categoría creada pero no se recibió ID');
        return 1; // Valor temporal
      }
    } else {
      throw Exception('Error al crear la categoría: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Excepción detallada en createCategory: $e');
    // En desarrollo, en lugar de fallar completamente, retornar valor temporal
    return -1; // Valor negativo para indicar error
  }
}
  
  static Future<void> updateCategory(Category category) async {
  try {
    // Crear el mapa de datos directamente, convirtiendo el ID a string
    final Map<String, dynamic> data = {
      'id': category.id.toString(), // ID como string
      'name': category.name,
      'description': category.description,
    };
    
    print('Intentando actualizar categoría: ${json.encode(data)}');
    print('URL: ${ApiConfig.updateCategory}');

    final response = await http.post(
      Uri.parse(ApiConfig.updateCategory),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data)
    ).timeout(const Duration(seconds: 15));
    
    print('Código de respuesta: ${response.statusCode}');
    print('Respuesta: ${response.body}');
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la categoría: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    // Solución temporal para desarrollo
    if (e.toString().contains('XMLHttpRequest error') || 
        e.toString().contains('SocketException') ||
        e.toString().contains('TimeoutException')) {
      print('Error de conexión detectado, usando modo sin conexión para desarrollo');
      await Future.delayed(const Duration(milliseconds: 800));
      return; // Simular éxito para desarrollo
    }
    
    print('Error detallado en updateCategory: $e');
    rethrow;
  }
}
  
  /// Elimina una categoría por su ID
  static Future<void> deleteCategory(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteCategory),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteCategory: $e');
      rethrow;
    }
  }
  
  // ========== UBICACIONES ==========
  
  /// Obtiene todas las ubicaciones
  static Future<List<Location>> getLocations() async {
    try {
      print('Obteniendo ubicaciones desde: ${ApiConfig.readLocations}');
      final response = await http.get(Uri.parse(ApiConfig.readLocations));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (!decodedData.containsKey('records')) {
          print('La respuesta no contiene la clave "records"');
          return [];
        }
        
        final List<dynamic> locationsJson = decodedData['records'];
        print('Ubicaciones encontradas: ${locationsJson.length}');
        
        return locationsJson.map((json) => Location.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron ubicaciones (404)');
        return [];
      } else {
        throw Exception('Error al obtener las ubicaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en getLocations: $e');
      return [];
    }
  }
  
  /// Obtiene una ubicación por su ID
  static Future<Location> getLocationById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.readOneLocation}?id=$id'));
      
      if (response.statusCode == 200) {
        return Location.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getLocationById: $e');
      rethrow;
    }
  }
  
  /// Crea una nueva ubicación
  static Future<int> createLocation(Location location) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConfig.createLocation),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(location.toJson())
    );
    
    print('Respuesta crear ubicación: ${response.statusCode} - ${response.body}');
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('id')) {
        return int.parse(data['id'].toString());
      } else {
        // Si la creación fue exitosa pero no hay ID, devolvemos un valor temporal
        print('Ubicación creada correctamente pero no se recibió ID');
        return 1; // ID temporal para desarrollo
      }
    } else {
      throw Exception('Error al crear la ubicación: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en createLocation: $e');
    // Para desarrollo, podríamos devolver un ID temporal en lugar de lanzar un error
    return -1; // Valor negativo para indicar error
  }
}
  
  /// Actualiza una ubicación existente
  static Future<void> updateLocation(Location location) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson())
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateLocation: $e');
      rethrow;
    }
  }
  
  /// Elimina una ubicación por su ID
  static Future<void> deleteLocation(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteLocation: $e');
      rethrow;
    }
  }
  
  // ========== IMÁGENES ==========
  
  /// Sube una sola imagen al servidor
  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadImage),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['imageUrl'];
      } else {
        throw Exception('Error al subir la imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en uploadImage: $e');
      rethrow;
    }
  }
  
  /// Sube múltiples imágenes al servidor
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadMultipleImages),
      );
      
      for (var file in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]',
          file.path,
          filename: file.path.split('/').last,
        ));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return List<String>.from(responseData['imageUrls']);
      } else {
        throw Exception('Error al subir las imágenes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en uploadMultipleImages: $e');
      // En caso de error, devolver lista vacía para desarrollo
      return [];
    }
  }
  
  // ========== UTILIDADES ==========
  
  /// Comprueba si la API está disponible
  static Future<bool> checkApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error al comprobar la conexión con la API: $e');
      return false;
    }
  }
}