// views/screens/categories_screen.dart
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../controllers/category_controller.dart';
import '../../config/app_theme.dart';
import 'category_details_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with AutomaticKeepAliveClientMixin {
  final CategoryController _categoryController = CategoryController();
  late Future<List<Category>> _categoriesFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  
  @override
  bool get wantKeepAlive => true;
  
  @override
void initState() {
  super.initState();
  _loadCategories();
}

@override
void didUpdateWidget(CategoriesScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  // Esto se ejecutará cuando el widget se reconstruya con una nueva key
  _loadCategories();
}
  
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      _categoriesFuture = _categoryController.getAllCategories();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las categorías: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar categorías...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  hintStyle: TextStyle(color: AppTheme.textSecondaryColor.withOpacity(0.7)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                  _loadCategories();
                },
              ),
            ),
          ),
          
          // Lista de categorías
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(
                  color: AppTheme.categoryColor,
                ))
              : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.categoryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadCategories();
      },
      color: AppTheme.categoryColor,
      child: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: AppTheme.categoryColor,
            ));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadCategories,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.categoryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          
          List<Category> categories = snapshot.data ?? [];
          
          // Filtrar categorías si hay una búsqueda
          if (_searchQuery.isNotEmpty) {
            categories = categories.where((category) => 
              category.name.toLowerCase().contains(_searchQuery) ||
              category.description.toLowerCase().contains(_searchQuery)
            ).toList();
          }
          
          if (categories.isEmpty) {
            return _buildEmptyState();
          }
          
          // Mostrar como lista en lugar de cuadrícula
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryListItem(category);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryListItem(Category category) {
    // Lista de iconos temáticos para diferentes categorías
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
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(category: category),
          ),
        ).then((result) {
          if (result == true) {
            setState(() {
              _loadCategories();
            });
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Icono
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.categoryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  getCategoryIcon(category.name),
                  color: AppTheme.categoryColor,
                  size: 36,
                ),
              ),
            ),
            
            // Información
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    
                    if (category.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Flecha
            const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.chevron_right,
                color: AppTheme.categoryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 64,
              color: AppTheme.categoryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay categorías disponibles' 
                : 'No se encontraron resultados para "$_searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _searchQuery.isEmpty 
                  ? 'Comienza añadiendo tu primera categoría con el botón + de abajo'
                  : 'Intenta con otra búsqueda o vuelve a la lista completa',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                _loadCategories();
              },
              icon: const Icon(Icons.close),
              label: const Text('Limpiar búsqueda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.categoryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}