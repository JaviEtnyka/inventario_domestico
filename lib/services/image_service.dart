// services/image_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../config/app_config.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Tomar una foto con la cámara del dispositivo
  static Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConfig.maxImageWidth.toDouble(),
        maxHeight: AppConfig.maxImageHeight.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );
      
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        return file;
      }
      return null;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }
  
  /// Seleccionar imágenes de la galería
  static Future<List<File>> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: AppConfig.maxImageWidth.toDouble(),
        maxHeight: AppConfig.maxImageHeight.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );
      
      List<File> files = [];
      for (var xFile in pickedFiles) {
        files.add(File(xFile.path));
      }
      
      return files;
    } catch (e) {
      print('Error al seleccionar imágenes: $e');
      return [];
    }
  }
  
  /// Optimizar una imagen reduciendo su tamaño y calidad
  static Future<File> optimizeImage(File imageFile) async {
    try {
      // Verificar que el archivo existe
      if (!await imageFile.exists()) {
        print('El archivo no existe');
        return imageFile;
      }
      
      // Leer los bytes de la imagen
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        print('El archivo está vacío');
        return imageFile;
      }
      
      // Intentar decodificar la imagen
      final image = img.decodeImage(bytes);
      if (image == null) {
        print('No se pudo decodificar la imagen');
        return imageFile;
      }
      
      // Redimensionar si es muy grande
      img.Image resized;
      if (image.width > AppConfig.maxImageWidth || image.height > AppConfig.maxImageHeight) {
        int newWidth, newHeight;
        
        if (image.width > image.height) {
          // Imagen horizontal
          newWidth = AppConfig.maxImageWidth;
          newHeight = (image.height * AppConfig.maxImageWidth ~/ image.width);
        } else {
          // Imagen vertical o cuadrada
          newHeight = AppConfig.maxImageHeight;
          newWidth = (image.width * AppConfig.maxImageHeight ~/ image.height);
        }
        
        resized = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
        );
      } else {
        // No necesita redimensionarse
        resized = image;
      }
      
      // Comprimir la imagen
      final compressed = img.encodeJpg(resized, quality: AppConfig.imageQuality);
      
      // Crear un archivo temporal para guardar la imagen optimizada
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/optimized_$timestamp.jpg';
      final outputFile = File(outputPath);
      
      // Escribir los bytes comprimidos al archivo
      await outputFile.writeAsBytes(compressed);
      
      // Verificar que el archivo se creó correctamente
      if (await outputFile.exists()) {
        return outputFile;
      } else {
        print('No se pudo crear el archivo optimizado');
        return imageFile;
      }
    } catch (e) {
      print('Error al optimizar imagen: $e');
      return imageFile; // Devolver la imagen original en caso de error
    }
  }
  
  /// Optimizar varias imágenes a la vez
  static Future<List<File>> optimizeImages(List<File> imageFiles) async {
    List<File> optimizedFiles = [];
    
    for (var file in imageFiles) {
      try {
        File optimized = await optimizeImage(file);
        optimizedFiles.add(optimized);
      } catch (e) {
        print('Error al optimizar imagen: $e');
        // Si falla la optimización, agregamos la original
        optimizedFiles.add(file);
      }
    }
    
    return optimizedFiles;
  }
  
  /// Crear un widget de vista previa para una imagen local
  static Widget buildImagePreview(File imageFile, {double size = 120}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        imageFile,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error al mostrar imagen: $error');
          return Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[700]),
          );
        },
      ),
    );
  }
  
  /// Crear un widget de vista previa para una imagen de red
  static Widget buildNetworkImagePreview(String imageUrl, {double size = 120}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error al cargar imagen de red: $error');
          return Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[700]),
          );
        },
      ),
    );
  }
  
  /// Eliminar un archivo de imagen temporal
  static Future<bool> deleteTemporaryImage(File imageFile) async {
    try {
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error al eliminar imagen temporal: $e');
      return false;
    }
  }
}