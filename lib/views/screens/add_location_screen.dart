// views/screens/add_location_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../controllers/location_controller.dart';
import '../../models/location.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';
import '../widgets/image_picker_widget.dart';
import '../../config/app_theme.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationController _locationController = LocationController();
  
  String _name = '';
  String _description = '';
  List<File> _imageFiles = [];
  
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Ubicación'),
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
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      maxLines: 3,
                      onSaved: (value) => _description = value ?? '',
                    ),
                    const SizedBox(height: 24),
                    
                    // Selector de imágenes
                    const Text(
                      'Imágenes de la ubicación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      images: _imageFiles,
                      onImagesChanged: (images) {
                        setState(() {
                          _imageFiles = images;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Botón de guardar
                    ElevatedButton.icon(
                      onPressed: _saveLocation,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Ubicación'),
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
  
  Future<void> _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Procesar imágenes si hay
        List<String> imageUrls = [];
        
        if (_imageFiles.isNotEmpty) {
          // Optimizar imágenes antes de subirlas
          List<File> optimizedImages = await ImageService.optimizeImages(_imageFiles);
          
          // Subir las imágenes
          imageUrls = await ApiService.uploadMultipleImages(optimizedImages);
        }
        
        final location = Location(
          name: _name,
          description: _description,
          imageUrls: imageUrls.isEmpty ? null : imageUrls,
        );
        
        await _locationController.createLocation(location);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la ubicación: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}