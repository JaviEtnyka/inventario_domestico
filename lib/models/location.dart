// models/location.dart
class Location {
  final int? id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  List<String>? imageUrls; // Nueva propiedad para almacenar URLs de imágenes
  
  Location({
    this.id,
    required this.name,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.imageUrls,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
       imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : null,
    );
  }

  Location clone() {
    return Location(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imageUrls: imageUrls != null ? List<String>.from(imageUrls!) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = {
    'name': name,
    'description': description,
  };
  
  // Solo añadir el ID si no es nulo (para updates)
  if (id != null) {
    data['id'] = id;
  }

  if (imageUrls != null) {
      data['image_urls'] = imageUrls;
    }
  
  return data;
}
}