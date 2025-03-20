// views/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/item_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/location_controller.dart';
import '../../models/item.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Datos para estadísticas
  double _totalInventoryValue = 0.0;
  int _totalItems = 0;
  int _totalCategories = 0;
  int _totalLocations = 0;
  
  // Datos agrupados
  Map<String, double> _valueByCategory = {};
  Map<String, double> _valueByLocation = {};
  Map<String, int> _itemsByCategory = {};
  Map<String, int> _itemsByLocation = {};
  
  // Item más valioso
  Item? _mostValuableItem;
  
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Cargar datos
      final items = await _itemController.getAllItems();
      final categories = await _categoryController.getAllCategories();
      final locations = await _locationController.getAllLocations();
      
      // Calcular estadísticas básicas
      _totalItems = items.length;
      _totalCategories = categories.length;
      _totalLocations = locations.length;
      
      // Calcular valor total del inventario y encontrar item más valioso
      _totalInventoryValue = 0.0;
      Item? mostValuable;
      
      for (var item in items) {
        _totalInventoryValue += item.value;
        
        if (mostValuable == null || item.value > mostValuable.value) {
          mostValuable = item;
        }
      }
      
      _mostValuableItem = mostValuable;
      
      // Inicializar mapas
      _valueByCategory = {};
      _valueByLocation = {};
      _itemsByCategory = {};
      _itemsByLocation = {};
      
      // Inicializar contadores por categoría
      for (var category in categories) {
        _valueByCategory[category.name] = 0.0;
        _itemsByCategory[category.name] = 0;
      }
      
      // Inicializar contadores por ubicación
      for (var location in locations) {
        _valueByLocation[location.name] = 0.0;
        _itemsByLocation[location.name] = 0;
      }
      
      // Agregar valores por categoría y ubicación
      for (var item in items) {
        // Por categoría
        if (item.categoryName != null) {
          _valueByCategory[item.categoryName!] = 
              (_valueByCategory[item.categoryName!] ?? 0.0) + item.value;
          _itemsByCategory[item.categoryName!] = 
              (_itemsByCategory[item.categoryName!] ?? 0) + 1;
        }
        
        // Por ubicación
        if (item.locationName != null) {
          _valueByLocation[item.locationName!] = 
              (_valueByLocation[item.locationName!] ?? 0.0) + item.value;
          _itemsByLocation[item.locationName!] = 
              (_itemsByLocation[item.locationName!] ?? 0) + 1;
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estadísticas: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _buildStatisticsView(),
    );
  }
  
  Widget _buildStatisticsView() {
    // Formatear moneda
    final currencyFormat = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 2,
    );
    
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Resumen general
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Inventario',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    'Valor Total del Inventario',
                    currencyFormat.format(_totalInventoryValue),
                    Icons.euro,
                    Colors.green,
                  ),
                  _buildStatRow(
                    'Número Total de Items',
                    _totalItems.toString(),
                    Icons.inventory,
                    Colors.blue,
                  ),
                  _buildStatRow(
                    'Número de Categorías',
                    _totalCategories.toString(),
                    Icons.category,
                    Colors.orange,
                  ),
                  _buildStatRow(
                    'Número de Ubicaciones',
                    _totalLocations.toString(),
                    Icons.place,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Item más valioso
          if (_mostValuableItem != null)
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Item Más Valioso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'Nombre',
                      _mostValuableItem!.name,
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildStatRow(
                      'Valor',
                      currencyFormat.format(_mostValuableItem!.value),
                      Icons.euro,
                      Colors.green,
                    ),
                    if (_mostValuableItem!.categoryName != null)
                      _buildStatRow(
                        'Categoría',
                        _mostValuableItem!.categoryName!,
                        Icons.category,
                        Colors.orange,
                      ),
                    if (_mostValuableItem!.locationName != null)
                      _buildStatRow(
                        'Ubicación',
                        _mostValuableItem!.locationName!,
                        Icons.place,
                        Colors.green,
                      ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Por Categoría
          if (_valueByCategory.isNotEmpty)
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor por Categoría',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    ..._valueByCategory.entries
                        .where((entry) => entry.value > 0)
                        .map((entry) => _buildStatRow(
                              entry.key,
                              currencyFormat.format(entry.value),
                              Icons.euro,
                              Colors.blue,
                            )),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Por Ubicación
          if (_valueByLocation.isNotEmpty)
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor por Ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    ..._valueByLocation.entries
                        .where((entry) => entry.value > 0)
                        .map((entry) => _buildStatRow(
                              entry.key,
                              currencyFormat.format(entry.value),
                              Icons.euro,
                              Colors.green,
                            )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}