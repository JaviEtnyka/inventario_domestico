// views/screens/home_screen.dart (con ajustes)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'inventory_screen.dart';
import 'categories_screen.dart';
import 'locations_screen.dart';
import 'settings_screen.dart';
import 'add_item_screen.dart';
import 'add_category_screen.dart';
import 'add_location_screen.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../controllers/item_controller.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  String _searchQuery = '';
  final ItemController _itemController = ItemController();
  double _totalValue = 0.0;
  bool _isLoadingValue = true;
  
  late List<Widget> _screens;
  
  final List<String> _titles = [
    'Inventario',
    'Categorías',
    'Ubicaciones',
    'Ajustes',
  ];
  
  final List<IconData> _icons = [
    Icons.inventory,
    Icons.category,
    Icons.place,
    Icons.settings,
  ];
  
  final List<Color> _colors = [
    AppTheme.inventoryColor,
    AppTheme.categoryColor,
    AppTheme.locationColor,
    Colors.grey[700]!,
  ];
  
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTotalValue();
    
    // Inicializar las pantallas
    _screens = [
      const InventoryScreen(),
      const CategoriesScreen(),
      const LocationsScreen(),
      SettingsScreen(),
    ];
  }
  
  Future<void> _loadTotalValue() async {
    setState(() {
      _isLoadingValue = true;
    });
    
    try {
      final value = await _itemController.getTotalInventoryValue();
      setState(() {
        _totalValue = value;
        _isLoadingValue = false;
      });
    } catch (e) {
      print('Error al cargar valor total: $e');
      setState(() {
        _isLoadingValue = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Color de la barra de estado basado en el índice seleccionado
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top + 60),
        child: _buildCustomAppBar(),
      ),
      body: SafeArea(
        top: false,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _shouldShowFab() ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  bool _shouldShowFab() {
    // No mostrar FAB en la pantalla de Ajustes
    return _selectedIndex < 3;
  }
  
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: _colors[_selectedIndex],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Título
            if (!_isSearchVisible)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _titles[_selectedIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedIndex == 0 && !_isLoadingValue)
                      Text(
                        'Valor total: €${_totalValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            
            // Campo de búsqueda (visible solo cuando se activa)
            if (_isSearchVisible)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _isSearchVisible = false;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            
            // Iconos de acción
            if (!_isSearchVisible) ...[
              // Solo mostrar búsqueda en pantallas relevantes (no en Ajustes)
              if (_selectedIndex < 3)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = true;
                    });
                  },
                ),
                IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
            tooltip: 'Estadísticas',
          ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  _showAppInfo(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      notchMargin: 8,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botón Inventario
            _buildNavItem(0, _icons[0], _titles[0]),
            
            // Botón Categorías
            _buildNavItem(1, _icons[1], _titles[1]),
            
            // Espacio para el botón flotante
            const SizedBox(width: 40),
            
            // Botón Ubicaciones
            _buildNavItem(2, _icons[2], _titles[2]),
            
            // Botón Ajustes
            _buildNavItem(3, _icons[3], _titles[3]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label, {bool isDisabled = false}) {
    final isSelected = _selectedIndex == index;
    final color = isDisabled 
        ? Colors.grey.withOpacity(0.5) 
        : (isSelected ? _colors[index % _colors.length] : Colors.grey);
    
    return Expanded(
      child: InkWell(
        onTap: isDisabled 
            ? null 
            : () {
                setState(() {
                  _selectedIndex = index;
                });
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _navigateToAddScreen(context);
      },
      backgroundColor: _colors[_selectedIndex],
      tooltip: 'Añadir ${_getSingularTitle(_selectedIndex)}',
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }
  
  // Obtener el título en singular
  String _getSingularTitle(int index) {
    if (index >= _titles.length - 1) return ''; // No singular para "Ajustes"
    
    String title = _titles[index];
    // Quitar la 's' final para obtener el singular
    return title.toLowerCase().substring(0, title.length - 1);
  }
  
  void _navigateToAddScreen(BuildContext context) {
    Widget screen;
    
    switch (_selectedIndex) {
      case 0:
        screen = const AddItemScreen();
        break;
      case 1:
        screen = const AddCategoryScreen();
        break;
      case 2:
        screen = const AddLocationScreen();
        break;
      default:
        screen = const AddItemScreen();
        break;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((result) {
      if (result == true) {
        // Recargar la pantalla actual
        setState(() {
          _screens[0] = const InventoryScreen();
          _screens[1] = const CategoriesScreen();
          _screens[2] = const LocationsScreen();
          
          // Si estamos en la pantalla de inventario, también actualizamos el valor total
          if (_selectedIndex == 0) {
            _loadTotalValue();
          }
        });
      }
    });
  }
  
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          AppConfig.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.info, color: AppTheme.primaryColor),
              title: Text('Versión'),
              subtitle: Text(AppConfig.appVersion),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Una aplicación para gestionar el inventario de los objetos de valor de tu hogar.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Desarrollada con Flutter',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}