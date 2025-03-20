// views/widgets/image_picker_widget.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/image_service.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<File> images;
  final Function(List<File>) onImagesChanged;
  
  const ImagePickerWidget({super.key, 
    required this.images,
    required this.onImagesChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotos:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Botones de cámara y galería
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _takePhoto(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImages(context),
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar Fotos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Mostrar imágenes seleccionadas
        images.isNotEmpty
            ? SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              images[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Eliminar imagen
                                List<File> updatedImages = List.from(images);
                                updatedImages.removeAt(index);
                                onImagesChanged(updatedImages);
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
              )
            : const Text('No hay fotos seleccionadas', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
  
  Future<void> _takePhoto(BuildContext context) async {
    try {
      final File? photo = await ImageService.takePhoto();
      if (photo != null) {
        List<File> updatedImages = List.from(images);
        updatedImages.add(photo);
        onImagesChanged(updatedImages);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar la foto: $e')),
      );
    }
  }
  
  Future<void> _pickImages(BuildContext context) async {
    try {
      final List<File> pickedImages = await ImageService.pickImages();
      if (pickedImages.isNotEmpty) {
        List<File> updatedImages = List.from(images);
        updatedImages.addAll(pickedImages);
        onImagesChanged(updatedImages);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }
}