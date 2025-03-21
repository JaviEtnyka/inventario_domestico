// views/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../controllers/item_controller.dart';
import '../../config/app_theme.dart';
import '../widgets/item_list_card.dart';
import 'item_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with AutomaticKeepAliveClientMixin {
  final ItemController _itemController = ItemController();
  late Future<List<Item>> _itemsFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  
  @override
  bool get wantKeepAlive => true;

  @override
void didUpdateWidget(InventoryScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  // Esto se ejecutará cuando el widget se reconstruya con una nueva key
  _loadItems();
}
@override
void initState() {
  super.initState();
  _loadItems();
}
  
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      if (_searchQuery.isEmpty) {
        _itemsFuture = _itemController.getAllItems();
      } else {
        _itemsFuture = _itemController.searchItems(_searchQuery);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los items: $e';
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
          _buildSearchBar(),
          
          // Resultado del inventario
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ))
              : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildItemList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
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
            hintText: 'Buscar en el inventario...',
            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            hintStyle: TextStyle(color: AppTheme.textSecondaryColor.withOpacity(0.7)),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            _loadItems();
          },
        ),
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
            onPressed: _loadItems,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
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
  
  Widget _buildItemList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadItems();
      },
      color: AppTheme.primaryColor,
      child: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
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
                    onPressed: _loadItems,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return _buildEmptyState();
          }
          
          // Mostrar siempre en formato lista con imagen
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemListCard(
                item: item,
                onTap: () => _navigateToDetails(item),
              );
            },
          );
        },
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
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay items en el inventario' 
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
                  ? 'Comienza añadiendo tu primer item con el botón + de abajo'
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
                _loadItems();
              },
              icon: const Icon(Icons.close),
              label: const Text('Limpiar búsqueda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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
  
  void _navigateToDetails(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(item: item),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _loadItems();
        });
      }
    });
  }
}