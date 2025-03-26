// views/screens/edit_location_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../controllers/location_controller.dart';
import '../../models/location.dart';
import '../../services/image_service.dart';
import '../../services/api_service.dart';
import '../widgets/image_picker_widget.dart';

class EditLocationScreen extends StatefulWidget {
  final Location location;
  
  const EditLocationScreen({super.key, required this.location});
  
  @override
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationController _locationController = LocationController();
  
  late String _name;
  late String _description;
  List<File> _newImageFiles = [];
  List<String> _existingImageUrls = [];
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Inicializar con los valores de la ubicación
    _name = widget.location.name;
    _description = widget.location.description;
    // Crear una copia de las URLs de imágenes existentes que podamos modificar
    _existingImageUrls = List.from(widget.location.imageUrls ?? []);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ubicación'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.place),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    
                    // Descripción
                    TextFormField(
                      initialValue: _description,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Imágenes existentes
                    if (_existingImageUrls.isNotEmpty) ...[
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
                      onPressed: _updateLocation,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildExistingImages() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _existingImageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _existingImageUrls[index],
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
                // Botón para eliminar la imagen existente
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // Eliminar la imagen de la lista local
                        _existingImageUrls.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _updateLocation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Procesar las nuevas imágenes si hay
        List<String> allImageUrls = List.from(_existingImageUrls);
        
        if (_newImageFiles.isNotEmpty) {
          // Optimizar imágenes antes de subirlas
          List<File> optimizedImages = await ImageService.optimizeImages(_newImageFiles);
          
          // Subir las nuevas imágenes
          List<String> newImageUrls = await ApiService.uploadMultipleImages(optimizedImages);
          
          // Añadir a la lista existente
          allImageUrls.addAll(newImageUrls);
        }
        
        final updatedLocation = Location(
          id: widget.location.id,
          name: _name,
          description: _description,
          imageUrls: allImageUrls,
        );
        
        // Actualizar la ubicación
        await _locationController.updateLocation(updatedLocation);
        
        Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}