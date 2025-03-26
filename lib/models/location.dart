// models/location.dart
import 'dart:convert';

class Location {
  final int? id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  final List<String>? imageUrls;
  
  Location({
    this.id,
    required this.name,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.imageUrls,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    // Procesar URLs de imágenes
    List<String>? processedImageUrls;
    
    // Manejar diferentes formatos de image_urls
    if (json['image_urls'] != null) {
      try {
        if (json['image_urls'] is String) {
          // Intentar decodificar como JSON
          final decoded = jsonDecode(json['image_urls']);
          if (decoded is List) {
            processedImageUrls = List<String>.from(decoded);
          } else if (decoded is String) {
            processedImageUrls = [decoded];
          }
        } else if (json['image_urls'] is List) {
          // Si ya es una lista
          processedImageUrls = List<String>.from(json['image_urls']);
        }
      } catch (e) {
        // Si la decodificación falla, tratar como cadena separada por comas
        final String urlString = json['image_urls'].toString();
        processedImageUrls = urlString
            .split(',')
            .where((url) => url.trim().isNotEmpty)
            .toList();
      }
    }
    
    return Location(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? json['created'],
      updatedAt: json['updated_at'] ?? json['modified'],
      imageUrls: processedImageUrls,
    );
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description ?? '',
    };
    
    // Añadir ID si existe
    if (id != null) {
      data['id'] = id.toString();
    }
    
    // Añadir URLs de imágenes como JSON string
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      // Convertir a JSON string
      data['image_urls'] = jsonEncode(imageUrls);
    }
    
    return data;
  }
  
  // Método clone mejorado
  Location clone({
    int? id,
    String? name,
    String? description,
    List<String>? imageUrls,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
  
  // Método para obtener la primera imagen o imagen de marcador de posición
  String getFirstImageUrl() {
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return imageUrls![0];
    }
    return 'https://via.placeholder.com/400x300?text=No+Image';
  }
  
  // Método para añadir una imagen
  Location addImage(String imageUrl) {
    final updatedImageUrls = List<String>.from(imageUrls ?? []);
    if (!updatedImageUrls.contains(imageUrl)) {
      updatedImageUrls.add(imageUrl);
    }
    return clone(imageUrls: updatedImageUrls);
  }
  
  // Método para eliminar una imagen
  Location removeImage(String imageUrl) {
    if (imageUrls == null) return this;
    
    final updatedImageUrls = List<String>.from(imageUrls!);
    updatedImageUrls.remove(imageUrl);
    
    return clone(
      imageUrls: updatedImageUrls.isEmpty ? null : updatedImageUrls
    );
  }
  
  // Verificar si hay imágenes
  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;
  
  // Obtener número de imágenes
  int get imageCount => imageUrls?.length ?? 0;
}