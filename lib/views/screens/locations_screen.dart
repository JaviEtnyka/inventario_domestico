// views/screens/locations_screen.dart
import 'package:flutter/material.dart';
import '../../models/location.dart';
import '../../controllers/location_controller.dart';
import '../../config/app_theme.dart';
import 'location_details_screen.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> with AutomaticKeepAliveClientMixin {
  final LocationController _locationController = LocationController();
  late Future<List<Location>> _locationsFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadLocations();
  }
  
  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      _locationsFuture = _locationController.getAllLocations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las ubicaciones: $e';
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
                  hintText: 'Buscar ubicaciones...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  hintStyle: TextStyle(color: AppTheme.textSecondaryColor.withOpacity(0.7)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                  _loadLocations();
                },
              ),
            ),
          ),
          
          // Lista de ubicaciones
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(
                  color: AppTheme.locationColor,
                ))
              : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildLocationList(),
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
            onPressed: _loadLocations,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.locationColor,
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
  
  Widget _buildLocationList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadLocations();
      },
      color: AppTheme.locationColor,
      child: FutureBuilder<List<Location>>(
        future: _locationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: AppTheme.locationColor,
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
                    onPressed: _loadLocations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.locationColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          
          List<Location> locations = snapshot.data ?? [];
          
          // Filtrar ubicaciones si hay una búsqueda
          if (_searchQuery.isNotEmpty) {
            locations = locations.where((location) => 
              location.name.toLowerCase().contains(_searchQuery) ||
              location.description.toLowerCase().contains(_searchQuery)
            ).toList();
          }
          
          if (locations.isEmpty) {
            return _buildEmptyState();
          }
          
          // Mostrar como lista en lugar de cuadrícula
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return _buildLocationListItem(location);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildLocationListItem(Location location) {
    // Iconos para diferentes tipos de ubicaciones
    IconData getLocationIcon(String name) {
      name = name.toLowerCase();
      if (name.contains('sala') || name.contains('salón')) {
        return Icons.weekend;
      } else if (name.contains('cocina')) {
        return Icons.kitchen;
      } else if (name.contains('baño')) {
        return Icons.bathtub;
      } else if (name.contains('dormitorio') || name.contains('habitación')) {
        return Icons.bed;
      } else if (name.contains('garaje')) {
        return Icons.garage;
      } else if (name.contains('jardín') || name.contains('terraza')) {
        return Icons.deck;
      } else if (name.contains('oficina') || name.contains('despacho')) {
        return Icons.business_center;
      } else {
        return Icons.place;
      }
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetailsScreen(location: location),
          ),
        ).then((result) {
          if (result == true) {
            setState(() {
              _loadLocations();
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
                color: AppTheme.locationColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  getLocationIcon(location.name),
                  color: AppTheme.locationColor,
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
                      location.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    
                    if (location.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        location.description,
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
                color: AppTheme.locationColor,
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
              color: AppTheme.locationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.place_outlined,
              size: 64,
              color: AppTheme.locationColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay ubicaciones disponibles' 
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
                  ? 'Comienza añadiendo tu primera ubicación con el botón + de abajo'
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
                _loadLocations();
              },
              icon: const Icon(Icons.close),
              label: const Text('Limpiar búsqueda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.locationColor,
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