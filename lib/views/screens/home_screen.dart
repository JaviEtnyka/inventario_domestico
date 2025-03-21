// views/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'inventory_screen.dart';
import 'categories_screen.dart';
import 'locations_screen.dart';
import 'settings_screen.dart';
import 'add_item_screen.dart';
import 'add_category_screen.dart';
import 'add_location_screen.dart';
import 'statistics_screen.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../controllers/item_controller.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    Icons.inventory_2_outlined,
    Icons.category_outlined,
    Icons.place_outlined,
    Icons.settings_outlined,
  ];
  
  final List<Color> _colors = [
    AppTheme.inventoryColor,
    AppTheme.categoryColor,
    AppTheme.locationColor,
    AppTheme.textSecondaryColor,
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
      const SettingsScreen(),
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _shouldShowFab() ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  bool _shouldShowFab() {
    return _selectedIndex < 3;
  }
  
  Widget _buildCustomAppBar() {
    // Formatear valor para mostrar en el AppBar
    final currencyFormat = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 2,
    );
    
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: _colors[_selectedIndex],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Título y subtítulo
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_selectedIndex == 0 && !_isLoadingValue)
                      Text(
                        'Valor total: ${currencyFormat.format(_totalValue)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            
            // Campo de búsqueda (visible solo cuando se activa)
            if (_isSearchVisible)
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
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
              ),
            
            // Iconos de acción
            if (!_isSearchVisible) ...[
              // Solo mostrar búsqueda en pantallas relevantes (no en Ajustes)
  //            if (_selectedIndex < 3)
  //              ActionButton(
  //                icon: Icons.search,
   //               color: Colors.white,
  //                onPressed: () {
   //                 setState(() {
    //                  _isSearchVisible = true;
     //               });
      //            },
       ////           size: 38,
         //       ),
       //       const SizedBox(width: 8),
              ActionButton(
                icon: Icons.bar_chart,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  );
                },
                tooltip: 'Estadísticas',
                size: 38,
              ),
              const SizedBox(width: 8),
              ActionButton(
                icon: Icons.info_outline,
                color: Colors.white,
                onPressed: () {
                  _showAppInfo(context);
                },
                size: 38,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        notchMargin: 8,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        color: Colors.transparent,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, _icons[0], _titles[0]),
              _buildNavItem(1, _icons[1], _titles[1]),
              const SizedBox(width: 50),
              _buildNavItem(2, _icons[2], _titles[2]),
              _buildNavItem(3, _icons[3], _titles[3]),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label, {bool isDisabled = false}) {
  final isSelected = _selectedIndex == index;
  final color = isDisabled 
      ? Colors.grey.withOpacity(0.5) 
      : (isSelected ? _colors[index % _colors.length] : AppTheme.textSecondaryColor);
  
  return Expanded(
    child: InkWell(
      onTap: isDisabled 
          ? null 
          : () {
              setState(() {
                _selectedIndex = index;
              });
            },
      child: SizedBox(
        height: 56, // Establece una altura fija para el contenedor
        child: Column(
          mainAxisSize: MainAxisSize.min, // Usa el espacio mínimo necesario
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6), // Reduce el padding
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon, 
                color: color,
                size: isSelected ? 22 : 20, // Tamaño de icono reducido
              ),
            ),
            const SizedBox(height: 2), // Reduce el espacio vertical
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11, // Reduce el tamaño de la fuente
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1, // Limita a una sola línea
              overflow: TextOverflow.ellipsis, // Maneja el desbordamiento de texto
            ),
          ],
        ),
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
      // Recargar la pantalla actual y actualizar valor total
      setState(() {
        // Recrear instancias de pantallas para forzar su recarga
        _screens[0] = const InventoryScreen(key: Key('inventory_refresh'));
        _screens[1] = const CategoriesScreen(key: Key('categories_refresh'));
        _screens[2] = const LocationsScreen(key: Key('locations_refresh'));
        
        // Actualizar el valor total independientemente de la pantalla activa
        _loadTotalValue();
      });
    }
  });
}
  
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2, color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventario Doméstico',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Una aplicación para gestionar el inventario de los objetos de valor de tu hogar. Te permite organizar tus pertenencias por categorías y ubicaciones.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Desarrollada con Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Cerrar',
                color: AppTheme.primaryColor,
                onPressed: () => Navigator.pop(context),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}