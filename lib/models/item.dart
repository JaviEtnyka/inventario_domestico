// models/item.dart
class Item {
  final int? id;
  final String name;
  final String description;
  final double value;
  final String? purchaseDate;
  final int? categoryId;
  final int? locationId;
  final String imageUrls;
  final String? dateAdded;
  final String? lastUpdated;
  
  // Campos adicionales
  final String? categoryName;
  final String? locationName;
  
  Item({
    this.id,
    required this.name,
    required this.description,
    required this.value,
    this.purchaseDate,
    this.categoryId,
    this.locationId,
    this.imageUrls = '',
    this.dateAdded,
    this.lastUpdated,
    this.categoryName,
    this.locationName,
  });
  
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      value: json['value'] is String ? double.parse(json['value']) : json['value']?.toDouble() ?? 0.0,
      purchaseDate: json['purchase_date'],
      categoryId: json['category_id'] is String && json['category_id'] != '' 
          ? int.parse(json['category_id']) 
          : json['category_id'],
      locationId: json['location_id'] is String && json['location_id'] != '' 
          ? int.parse(json['location_id']) 
          : json['location_id'],
      imageUrls: json['image_urls'] ?? '',
      dateAdded: json['date_added'],
      lastUpdated: json['last_updated'],
      categoryName: json['category_name'],
      locationName: json['location_name'],
    );
  }
  
 Map<String, dynamic> toJson() {
  // Asegurarse de que id sea string si es requerido por la API
  return {
    'id': id.toString(), // Asegurarse que id sea string
    'name': name,
    'description': description ?? '', // Usar cadena vacía si es null
    'value': value.toString(), // Convertir a string si la API lo espera así
    'purchase_date': purchaseDate ?? '', // Usar cadena vacía si es null
    'category_id': categoryId?.toString(), // Puede ser null
    'location_id': locationId?.toString(), // Puede ser null
    'image_urls': imageUrls ?? '',
  };
}
  
  List<String> getImageUrlsList() {
    if (imageUrls.isEmpty) return [];
    return imageUrls.split(',');
  }
}