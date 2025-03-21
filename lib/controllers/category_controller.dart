// controllers/category_controller.dart
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryController {
  // Obtener todas las categorías
  Future<List<Category>> getAllCategories() async {
    try {
      // Para pruebas iniciales, puedes usar datos estáticos
      // return _getTestCategories();
      
      // Para conectar con la API real
      return await ApiService.getCategories();
    } catch (e) {
      print('Error en getAllCategories: $e');
      throw Exception('Error al obtener las categorías: $e');
    }
  }
  
  // Datos de prueba para desarrollo inicial
  List<Category> _getTestCategories() {
    return [
      Category(id: 1, name: 'Electrónica', description: 'Dispositivos electrónicos'),
      Category(id: 2, name: 'Muebles', description: 'Mobiliario del hogar'),
      Category(id: 3, name: 'Ropa', description: 'Vestimenta y accesorios'),
      Category(id: 4, name: 'Joyería', description: 'Objetos de valor'),
      Category(id: 5, name: 'Libros', description: 'Libros y documentos'),
    ];
  }
  
  // Obtener una categoría por ID
  Future<Category> getCategory(int id) async {
    return await ApiService.getCategoryById(id);
  }
  
  // Crear una nueva categoría
  Future<int> createCategory(Category category) async {
    return await ApiService.createCategory(category);
  }

  // En category_controller.dart
Future<void> updateCategory(Category category) async {
  try {
    print('CategoryController: Actualizando categoría ${category.id} - ${category.name}');
    await ApiService.updateCategory(category);
  } catch (e) {
    print('Error en CategoryController.updateCategory: $e');
    rethrow;
  }
}
// Eliminar una categoría
Future<void> deleteCategory(int id) async {
  try {
    print('CategoryController: Eliminando categoría con ID $id');
    await ApiService.deleteCategory(id);
  } catch (e) {
    print('Error en CategoryController.deleteCategory: $e');
    rethrow;
  }
}
}