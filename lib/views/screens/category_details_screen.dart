// views/screens/category_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/category.dart';
import '../../controllers/item_controller.dart';
import '../../controllers/category_controller.dart';
import '../../config/app_theme.dart';
import 'edit_category_screen.dart';
import '../widgets/custom_button.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category category;
  
  const CategoryDetailsScreen({super.key, required this.category});
  
  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  bool _isLoading = false;
  String _errorMessage = '';
  int _itemCount = 0;
  
  @override
  void initState() {
    super.initState();
    _loadCategoryStats();
  }
  
  Future<void> _loadCategoryStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Obtener la cantidad de ítems en esta categoría
      final items = await _itemController.filterByCategory(widget.category.id!);
      setState(() {
        _itemCount = items.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar estadísticas: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Iconos para diferentes tipos de categorías
    IconData getCategoryIcon(String name) {
      name = name.toLowerCase();
      if (name.contains('electr')) {
        return Icons.devices;
      } else if (name.contains('mueble') || name.contains('mobil')) {
        return Icons.chair;
      } else if (name.contains('ropa') || name.contains('vest')) {
        return Icons.checkroom;
      } else if (name.contains('joyer') || name.contains('joy')) {
        return Icons.diamond;
      } else if (name.contains('libro') || name.contains('document')) {
        return Icons.menu_book;
      } else if (name.contains('cocina') || name.contains('coc')) {
        return Icons.kitchen;
      } else if (name.contains('deporte') || name.contains('activ')) {
        return Icons.sports_soccer;
      } else if (name.contains('juguete') || name.contains('juego')) {
        return Icons.toys;
      } else if (name.contains('arte') || name.contains('decora')) {
        return Icons.palette;
      } else if (name.contains('mascota') || name.contains('animal')) {
        return Icons.pets;
      } else if (name.contains('herram') || name.contains('tool')) {
        return Icons.build;
      } else {
        return Icons.category;
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Categoría'),
        backgroundColor: AppTheme.categoryColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onPressed: () => _showDeleteConfirmation(context),
            mouseCursor: SystemMouseCursors.click,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading && _errorMessage.isEmpty 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.categoryColor))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con icono y nombre
                  Container(
                    color: AppTheme.categoryColor,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            getCategoryIcon(widget.category.name),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.category.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (_itemCount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$_itemCount ${_itemCount == 1 ? 'item' : 'items'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mensaje de error (si existe)
                        if (_errorMessage.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.error_outline, color: AppTheme.errorColor),
                                    SizedBox(width: 8),
                                    Text(
                                      'Error',
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _loadCategoryStats,
                                    child: const Text('Reintentar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        // Descripción
                        if (widget.category.description.isNotEmpty) ...[
                          const Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.category.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondaryColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Estadísticas
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppTheme.categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Items en esta categoría',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '$_itemCount',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Metadatos
                        if (widget.category.createdAt != null) ...[
                          const Text(
                            'Información adicional',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow('Fecha de registro', _formatDate(widget.category.createdAt!)),
                                if (widget.category.updatedAt != null)
                                  _buildInfoRow('Última actualización', _formatDate(widget.category.updatedAt!)),
                                _buildInfoRow('ID', '#${widget.category.id}'),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Botones de acción
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Editar',
                                icon: Icons.edit,
                                onPressed: () => _navigateToEditScreen(context),
                                color: AppTheme.secondaryColor,
                                height: 50,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                text: 'Eliminar',
                                icon: Icons.delete,
                                onPressed: () => _showDeleteConfirmation(context),
                                color: AppTheme.errorColor,
                                isOutlined: true,
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Formatear fecha
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // Navegar a pantalla de edición
  void _navigateToEditScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(category: widget.category),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
    }
  }
  
  // Mostrar diálogo de confirmación para eliminar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Eliminar categoría?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Estás seguro de que deseas eliminar "${widget.category.name}"? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Eliminar',
                      onPressed: () => _deleteCategory(),
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Eliminar categoría
  void _deleteCategory() async {
    // Cerrar diálogo de confirmación
    Navigator.pop(context);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Convertir el ID a int para asegurarnos
      final categoryId = widget.category.id!;
      
      print('Iniciando eliminación de categoría ID: $categoryId');
      await _categoryController.deleteCategory(categoryId);
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoría eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la pantalla anterior con resultado = true para actualizar la lista
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Capturar y mostrar error
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al eliminar la categoría: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}