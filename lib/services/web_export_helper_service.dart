import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebExportHelper {
  // Exportar contenido como archivo descargable en la web
  static void exportToFile(String content, String fileName, String mimeType) {
    if (kIsWeb) {
      // Crear un blob con el contenido
      final blob = html.Blob([content], mimeType);
      
      // Crear una URL para el blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Crear un enlace de descarga
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      // Añadir el enlace al DOM
      html.document.body?.children.add(anchor);
      
      // Simular clic en el enlace para iniciar la descarga
      anchor.click();
      
      // Limpiar
      html.Url.revokeObjectUrl(url);
      anchor.remove();
    }
  }
  
  // Exportar contenido CSV
  static void exportCsv(String csvContent, String fileName) {
    exportToFile(csvContent, fileName, 'text/csv');
  }
  
  // Exportar contenido JSON
  static void exportJson(String jsonContent, String fileName) {
    exportToFile(jsonContent, fileName, 'application/json');
  }
  
  // Para Excel, tendríamos que generar el archivo Excel en el navegador,
  // lo que sería más complejo y posiblemente requeriría una biblioteca adicional
}