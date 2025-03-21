// config/api_config.dart
class ApiConfig {
  // Cambiar a la dirección de tu servidor PHP
  static const String baseUrl = 'http://rek-internova.com/inventario-api/api';
  
  // Endpoints de items
  static const String itemsEndpoint = '$baseUrl/items';
  static const String readItems = '$itemsEndpoint/read.php';
  static const String readOneItem = '$itemsEndpoint/read_one.php';
  static const String createItem = '$itemsEndpoint/create.php';
  static const String updateItem = '$itemsEndpoint/update.php';
  static const String deleteItem = '$itemsEndpoint/delete.php';
  
  // Endpoints de categorías
  static const String categoriesEndpoint = '$baseUrl/categories';
  static const String readCategories = '$categoriesEndpoint/read.php';
  static const String readOneCategory = '$categoriesEndpoint/read_one.php';
  static const String createCategory = '$categoriesEndpoint/create.php';
  static const String updateCategory = '$categoriesEndpoint/update.php';
  static const String deleteCategory = '$categoriesEndpoint/delete.php';
  
  // Endpoints de ubicaciones
  static const String locationsEndpoint = '$baseUrl/locations';
  static const String readLocations = '$locationsEndpoint/read.php';
  static const String readOneLocation = '$locationsEndpoint/read_one.php';
  static const String createLocation = '$locationsEndpoint/create.php';
  static const String updateLocation = '$locationsEndpoint/update.php';
  static const String deleteLocation = '$locationsEndpoint/delete.php';
  
  // Endpoints de imágenes
  static const String uploadImage = 'http://rek-internova.com/inventario-api/api/upload.php';
  static const String uploadMultipleImages = 'http://rek-internova.com/inventario-api/api/upload-multiple.php';
}