// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../models/location.dart';
import 'dart:async' show TimeoutException;

class ApiService {
  /// Diagnóstico detallado de endpoints de subida de imágenes
  static Future<void> diagnoseSeverUploadEndpoints() async {
    // Lista de URLs potenciales para probar
    final possibleUrls = [
      // URLs basadas en la configuración actual
      '${ApiConfig.baseUrl}/upload-multiple.php',
      '${ApiConfig.baseUrl}/api/upload-multiple.php',
      
      // URLs alternativas
      'http://rek-internova.com/inventario-api/upload-multiple.php',
      'http://rek-internova.com/inventario-api/api/upload-multiple.php',
      'http://rek-internova.com/uploads/upload-multiple.php',
    ];

    print('🔍 Iniciando diagnóstico de endpoints de subida');
    
    for (var url in possibleUrls) {
      try {
        print('\n🌐 Probando URL: $url');
        
        // Intentar una solicitud GET para verificar accesibilidad
        final getResponse = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Tiempo de espera agotado')
        );
        
        print('📡 Respuesta GET:');
        print('   - Código de estado: ${getResponse.statusCode}');
        print('   - Encabezados: ${getResponse.headers}');
        print('   - Contenido: ${getResponse.body}');

        // Intentar una solicitud POST simulada
        try {
          var request = http.MultipartRequest('POST', Uri.parse(url));
          request.files.add(
            http.MultipartFile.fromBytes(
              'test_file', 
              [1, 2, 3], 
              filename: 'test.txt'
            )
          );

          var postResponse = await request.send().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Tiempo de espera agotado en POST')
          );

          var responseBody = await postResponse.stream.bytesToString();
          
          print('📡 Respuesta POST:');
          print('   - Código de estado: ${postResponse.statusCode}');
          print('   - Contenido: $responseBody');
        } catch (postError) {
          print('❌ Error en solicitud POST: $postError');
        }
      } catch (e) {
        print('❌ Error al probar URL $url: $e');
      }
    }

    // Información adicional del servidor
    try {
      final serverInfoResponse = await http.get(
        Uri.parse('http://rek-internova.com/inventario-api/'),
        headers: {'Accept': 'text/html,application/xhtml+xml,application/xml'}
      ).timeout(const Duration(seconds: 10));
      
      print('\n🌍 Información del servidor:');
      print('   - Código de estado: ${serverInfoResponse.statusCode}');
      print('   - Servidor: ${serverInfoResponse.headers['server']}');
    } catch (e) {
      print('❌ No se pudo obtener información del servidor: $e');
    }
  }
  
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
      // Imprimir el JSON para depuración
      final jsonData = item.toJson();
      print('Creando item: ${json.encode(jsonData)}');
      print('URL: ${ApiConfig.createItem}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.createItem),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData)
      ).timeout(const Duration(seconds: 15));
      
      print('Respuesta HTTP: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('id')) {
          return int.parse(data['id'].toString());
        } else {
          return 0; // Si no hay ID, devolvemos 0 temporalmente
        }
      } else {
        throw Exception('Error al crear el item: ${response.statusCode} - ${response.body}');
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
      ).timeout(const Duration(seconds: 15));
      
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
      // Convertir id a string para asegurar compatibilidad con la API
      final Map<String, dynamic> data = {
        'id': id.toString()
      };
      
      print('Intentando eliminar categoría ID: $id');
      print('URL: ${ApiConfig.deleteCategory}');
      print('Datos enviados: ${json.encode(data)}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.deleteCategory),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data)
      ).timeout(const Duration(seconds: 15));
      
      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la categoría: ${response.statusCode} - ${response.body}');
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
      
      print('Error detallado en deleteCategory: $e');
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
   /// Crea una nueva ubicación
  static Future<int> createLocation(Location location) async {
    try {
      // Crear el mapa de datos, incluyendo URLs de imágenes si existen
      final Map<String, dynamic> data = {
        'name': location.name,
        'description': location.description,
      };
      
      // Añadir URLs de imágenes si existen
      if (location.imageUrls != null && location.imageUrls!.isNotEmpty) {
        // Convertir a JSON string para el backend
        data['image_urls'] = json.encode(location.imageUrls);
      }
      
      print('Enviando datos de ubicación: ${json.encode(data)}');
      print('URL: ${ApiConfig.createLocation}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.createLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data)
      );
      
      print('Respuesta crear ubicación: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('id')) {
          return int.parse(responseData['id'].toString());
        } else {
          // Si la creación fue exitosa pero no hay ID, devolvemos un valor temporal
          print('Ubicación creada correctamente pero no se recibió ID');
          return 1; // ID temporal para desarrollo
        }
      } else {
        throw Exception('Error al crear la ubicación: ${response.statusCode} - ${response.body}');
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
      // Crear el mapa de datos, asegurándose de incluir las URLs de imágenes
      final Map<String, dynamic> data = {
        'id': location.id.toString(), // Convertir ID a string
        'name': location.name,
        'description': location.description,
      };
      
      // Añadir URLs de imágenes si existen
      if (location.imageUrls != null && location.imageUrls!.isNotEmpty) {
        // Convertir a JSON string para el backend
        data['image_urls'] = json.encode(location.imageUrls);
      }
      
      print('Intentando actualizar ubicación: ${json.encode(data)}');
      print('URL: ${ApiConfig.updateLocation}');

      final response = await http.post(
        Uri.parse(ApiConfig.updateLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data)
      ).timeout(const Duration(seconds: 15));
      
      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la ubicación: ${response.statusCode} - ${response.body}');
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
      
      print('Error detallado en updateLocation: $e');
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
  
  /// Sube una única imagen al servidor
  static Future<String> uploadImage(File imageFile) async {
    try {
      // Validar que el archivo existe y no está vacío
      if (!await imageFile.exists()) {
        throw Exception('El archivo no existe');
      }

      // Crear solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadImage),
      );
      
      // Añadir el archivo a la solicitud
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));

      // Depuración de la solicitud
      print('🌐 URL de subida de imagen única: ${ApiConfig.uploadImage}');
      print('📸 Archivo a subir:');
      print('   - Ruta: ${imageFile.path}');
      print('   - Existe: ${await imageFile.exists()}');
      print('   - Tamaño: ${await imageFile.length()} bytes');

      // Enviar solicitud con timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('Tiempo de espera agotado al subir imagen'),
      );

      // Procesar respuesta
      var response = await http.Response.fromStream(streamedResponse);
      
      // Depuración de la respuesta
      print('📡 Detalles de la respuesta de imagen única:');
      print('   - Código de estado: ${response.statusCode}');
      print('   - Encabezados: ${response.headers}');
      print('   - Cuerpo completo: ${response.body}');

      // Procesar respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        
        // Extraer URL de la imagen
        if (responseBody is Map && responseBody.containsKey('url')) {
          final imageUrl = responseBody['url'] as String;
          print('✅ URL de imagen subida: $imageUrl');
          return imageUrl;
        }
        
        // Manejar caso de respuesta inesperada
        print('❓ Formato de respuesta no esperado');
        throw Exception('Respuesta del servidor inválida');
      } else {
        // Manejar códigos de error
        print('❌ Error en la subida. Código: ${response.statusCode}');
        print('❌ Mensaje de error: ${response.body}');
        throw HttpException('Error al subir imagen: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('⏰ Tiempo de espera agotado al subir imagen: $e');
      throw Exception('La subida de la imagen ha excedido el tiempo límite');
    } on SocketException catch (e) {
      print('🌐 Error de conexión al subir imagen: $e');
      throw Exception('No se puede conectar al servidor. Verifique su conexión a internet.');
    } on http.ClientException catch (e) {
      print('🚫 Error de cliente HTTP al subir imagen: $e');
      throw Exception('Error de comunicación con el servidor');
    } catch (e, stackTrace) {
      print('❌ Error inesperado en subida de imagen: $e');
      print('🔍 Traza de error: $stackTrace');
      rethrow;
    }
  }
  
  /// Sube múltiples imágenes al servidor
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    // Validar que hay archivos para subir
    if (imageFiles.isEmpty) {
      print('🚫 No hay imágenes para subir');
      return [];
    }

    try {
      // Depuración detallada de la URL
      final uploadUrl = ApiConfig.uploadMultipleImages;
      print('🌐 URL de subida múltiple: $uploadUrl');
      
      // Crear solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadUrl),
      );
      
      // Añadir archivos a la solicitud
      for (int i = 0; i < imageFiles.length; i++) {
        var file = imageFiles[i];
        String fileName = file.path.split('/').last;
        
        print('📸 Archivo a subir ($i):');
        print('   - Ruta: ${file.path}');
        print('   - Existe: ${await file.exists()}');
        print('   - Tamaño: ${await file.length()} bytes');

        request.files.add(await http.MultipartFile.fromPath(
          'images[]', 
          file.path,
          filename: fileName,
        ));
      }

      // Enviar solicitud con timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏰ Tiempo de espera agotado al subir imágenes');
          throw TimeoutException('Tiempo de espera agotado al subir imágenes');
        },
      );

      // Procesar respuesta
      var response = await http.Response.fromStream(streamedResponse);
      
      // Depuración exhaustiva de la respuesta
      print('📡 Detalles de la respuesta múltiple:');
      print('   - Código de estado: ${response.statusCode}');
      print('   - Encabezados: ${response.headers}');
      print('   - Cuerpo completo: ${response.body}');

      // Manejar diferentes códigos de estado
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        
        // Manejar diferentes formatos de respuesta
        if (responseBody is Map && responseBody.containsKey('imageUrls')) {
          final urls = List<String>.from(responseBody['imageUrls']);
          print('✅ URLs de imágenes subidas: $urls');
          return urls;
        }
        
        if (responseBody is List) {
          final urls = responseBody.map((url) => url.toString()).toList();
          print('✅ URLs de imágenes subidas: $urls');
          return urls;
        }
        
        print('❓ Formato de respuesta no esperado');
        throw FormatException('Respuesta del servidor en formato inesperado');
      } else {
        // Manejar códigos de error
        print('❌ Error en la subida. Código: ${response.statusCode}');
        print('❌ Mensaje de error: ${response.body}');
        throw HttpException('Error al subir imágenes: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('⏰ Tiempo de espera agotado: $e');
      throw Exception('La subida de imágenes ha excedido el tiempo límite');
    } on SocketException catch (e) {
      print('🌐 Error de conexión: $e');
      throw Exception('No se puede conectar al servidor. Verifique su conexión a internet.');
    } on http.ClientException catch (e) {
      print('🚫 Error de cliente HTTP: $e');
      throw Exception('Error de comunicación con el servidor');
    } catch (e, stackTrace) {
      print('❌ Error inesperado en subida de imágenes: $e');
      print('🔍 Traza de error: $stackTrace');
      rethrow;
    }
  }
  
  /// Registra detalles de la respuesta para depuración
  static void _logResponseDetails(http.Response response) {
    print('URL de subida: ${ApiConfig.uploadMultipleImages}');
    print('Código de respuesta: ${response.statusCode}');
    print('Cuerpo de respuesta: ${response.body}');
  }

  /// Filtra archivos válidos para subida
  static Future<List<File>> _filterValidFiles(List<File> files) async {
    return Future.wait(
      files.map((file) async {
        if (await file.exists() && await file.length() > 0) {
          return file;
        }
        print('Archivo inválido omitido: ${file.path}');
        return null;
      })
    ).then((files) => files.whereType<File>().toList());
  }

  /// Procesa la respuesta de subida de imágenes
  static List<String> _processUploadResponse(http.Response response) {
    // Verificar código de respuesta
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Error al subir imágenes: ${response.statusCode} - ${response.body}'
      );
    }

    // Decodificar respuesta JSON
    final responseData = json.decode(response.body);
    
    // Manejar diferentes formatos de respuesta
    if (responseData is Map && responseData.containsKey('imageUrls')) {
      final urls = List<String>.from(responseData['imageUrls']);
      print('URLs de imágenes subidas: $urls');
      return urls;
    } 
    
    if (responseData is List) {
      final urls = responseData.map((url) => url.toString()).toList();
      print('URLs de imágenes subidas: $urls');
      return urls;
    } 
    
    if (responseData is String) {
      print('URL de imagen subida: $responseData');
      return [responseData];
    }
    
    // Formato de respuesta no reconocido
    print('Formato de respuesta de URL no reconocido');
    return [];
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
  
  /// Verifica si los endpoints de imágenes funcionan correctamente
  static Future<bool> checkImageUploadEndpoint() async {
    try {
      // Probamos primero con un GET para ver si el endpoint existe
      final testResponse = await http.get(
        Uri.parse(ApiConfig.uploadImage),
      ).timeout(const Duration(seconds: 5));
      
      print('Test de endpoint de imágenes:');
      print('Código: ${testResponse.statusCode}');
      
      // No es importante que devuelva un código exitoso en GET
      // Lo importante es que el servidor responda
      return testResponse.statusCode != 0;
    } catch (e) {
      print('Error al verificar endpoint de imágenes: $e');
      return false;
    }
  }
  
  /// Obtiene la URL base de las imágenes desde el servidor
  static Future<String?> getImageBaseUrl() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/config.php'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('imageBaseUrl')) {
          return data['imageBaseUrl'];
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener URL base de imágenes: $e');
      return null;
    }
  }
  
  /// Modo de prueba sin conexión - Determina si debemos usar datos de ejemplo
  static Future<bool> shouldUseOfflineMode() async {
    // Verificar si el servidor está disponible
    final isAvailable = await checkApiConnection();
    
    // También podríamos considerar crear una configuración
    // que permita al usuario forzar el modo sin conexión
    
    return !isAvailable;
  }
  /// Elimina una imagen del servidor usando su URL
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // Crear un endpoint específico para eliminar imágenes
      final deleteImageUrl = '${ApiConfig.baseUrl}/delete-image.php';
      
      print('🗑️ Intentando eliminar imagen: $imageUrl');
      
      final response = await http.post(
        Uri.parse(deleteImageUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'image_url': imageUrl,
        })
      ).timeout(const Duration(seconds: 15));
      
      print('🌐 Respuesta de eliminación de imagen:');
      print('   - Código de estado: ${response.statusCode}');
      print('   - Cuerpo de respuesta: ${response.body}');
      
      // Considerar códigos de éxito
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Imagen eliminada correctamente');
        return true;
      } else {
        print('❌ Error al eliminar imagen: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción al eliminar imagen: $e');
      return false;
    }
  }
}