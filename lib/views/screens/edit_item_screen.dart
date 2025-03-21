// views/screens/edit_item_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../controllers/item_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/location_controller.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../widgets/image_picker_widget.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;
  
  const EditItemScreen({super.key, required this.item});
  
  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  
  late String _name;
  late String _description;
  late double _value;
  int? _categoryId;
  int? _locationId;
  List<File> _newImageFiles = [];
  
  List<Category> _categories = [];
  List<Location> _locations = [];
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    // Inicializar con los valores del item
    _name = widget.item.name;
    _description = widget.item.description;
    _value = widget.item.value;
    _categoryId = widget.item.categoryId;
    _locationId = widget.item.locationId;
    
    _loadCategoriesAndLocations();
  }
  
  Future<void> _loadCategoriesAndLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Cargar categorías y ubicaciones en paralelo
      final categoriesFuture = _categoryController.getAllCategories();
      final locationsFuture = _locationController.getAllLocations();
      
      // Esperar a que ambas terminen
      final results = await Future.wait([categoriesFuture, locationsFuture]);
      
      setState(() {
        _categories = results[0] as List<Category>;
  _locations = results[1] as List<Location>; // Assuming this is the type
  _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Item'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildForm(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategoriesAndLocations,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
              onSaved: (value) {
                if (value != null) {
                  _name = value;
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Valor
            TextFormField(
              initialValue: _value.toString(),
              decoration: const InputDecoration(
                labelText: 'Valor (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un valor';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
              onSaved: (value) {
                if (value != null) {
                  _value = double.tryParse(value) ?? _value;
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Categoría
            DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _categoryId,
              hint: const Text('Selecciona una categoría'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Sin categoría'),
                ),
                ..._categories.map((category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _categoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Ubicación
            DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              value: _locationId,
              hint: const Text('Selecciona una ubicación'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Sin ubicación'),
                ),
                ..._locations.map((location) {
                  return DropdownMenuItem<int?>(
                    value: location.id,
                    child: Text(location.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _locationId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Descripción
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              onSaved: (value) {
                _description = value ?? '';
              },
            ),
            const SizedBox(height: 24),
            
            // Imágenes existentes
            if (widget.item.getImageUrlsList().isNotEmpty) ...[
              const Text(
                'Imágenes existentes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildExistingImages(),
              const SizedBox(height: 24),
            ],
            
            // Selector de nuevas imágenes
            ImagePickerWidget(
              images: _newImageFiles,
              onImagesChanged: (images) {
                setState(() {
                  _newImageFiles = images;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Botón de guardar
            ElevatedButton.icon(
              onPressed: _updateItem,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExistingImages() {
    List<String> imageUrls = widget.item.getImageUrlsList();
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      try {
        final updatedItem = Item(
          id: widget.item.id,
          name: _name,
          description: _description,
          value: _value,
          categoryId: _categoryId,
          locationId: _locationId,
          imageUrls: widget.item.imageUrls,
        );
        
        await _itemController.updateItem(updatedItem, _newImageFiles);
        
        // Volver a la pantalla anterior con resultado positivo
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al actualizar el item: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}