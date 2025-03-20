// views/screens/item_details_screen.dart (mejorado)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../controllers/item_controller.dart';
import '../../config/app_theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import 'edit_item_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;
  final ItemController _itemController = ItemController();
  
  ItemDetailsScreen({super.key, required this.item});
  
  @override
  Widget build(BuildContext context) {
    // Formatear el valor como moneda
    final currencyFormat = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 2,
    );
    
    // Obtener las URLs de las imágenes
    List<String> imageUrls = item.getImageUrlsList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería de imágenes
            if (imageUrls.isNotEmpty)
              _buildImageGallery(imageUrls),
            
            const SizedBox(height: 24),
            
            // Nombre y valor
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    currencyFormat.format(item.value),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Categoría y ubicación
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: 'Categoría',
                    value: item.categoryName ?? 'Sin categoría',
                    icon: Icons.category,
                    iconColor: AppTheme.categoryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    title: 'Ubicación',
                    value: item.locationName ?? 'Sin ubicación',
                    icon: Icons.place,
                    iconColor: AppTheme.locationColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Descripción
            if (item.description.isNotEmpty) ...[
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CustomCard(
                child: Text(
                  item.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Información adicional
            const Text(
              'Información Adicional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.purchaseDate != null)
                    _buildInfoRow('Fecha de compra', _formatDate(item.purchaseDate!)),
                  
                  if (item.dateAdded != null)
                    _buildInfoRow('Fecha de registro', _formatDate(item.dateAdded!)),
                  
                  if (item.lastUpdated != null)
                    _buildInfoRow('Última actualización', _formatDate(item.lastUpdated!)),
                  
                  _buildInfoRow('ID', '#${item.id}'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Editar',
                    icon: Icons.edit,
                    onPressed: () => _navigateToEditScreen(context),
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Eliminar',
                    icon: Icons.delete,
                    onPressed: () => _showDeleteConfirmation(context),
                    color: AppTheme.errorColor,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Construir galería de imágenes
  Widget _buildImageGallery(List<String> imageUrls) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar imagen',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  
  // Construir fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Formatear fecha
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // Navegar a pantalla de edición
  void _navigateToEditScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
    }
  }
  
  // Mostrar diálogo de confirmación para eliminar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este item? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _deleteItem(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  
  // Eliminar item
  void _deleteItem(BuildContext context) async {
    try {
      await _itemController.deleteItem(item.id!);
      Navigator.pop(context); // Cerrar diálogo
      
      // Mostrar snackbar de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el item: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}