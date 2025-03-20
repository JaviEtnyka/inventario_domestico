// models/category.dart
class Category {
  final int? id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  
  Category({
    this.id,
    required this.name,
    this.description = '',
    this.createdAt,
    this.updatedAt,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
  
  return data;
}
}