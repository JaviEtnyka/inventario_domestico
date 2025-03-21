// views/screens/item_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../controllers/item_controller.dart';
import '../../config/app_theme.dart';
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
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: imageUrls.isNotEmpty ? 300 : 0,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                onPressed: () => _navigateToEditScreen(context),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onPressed: () => _showDeleteConfirmation(context),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrls.isNotEmpty
                  ? _buildImageGallery(imageUrls)
                  : Container(color: AppTheme.primaryColor),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del item y valor
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.inventoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.inventoryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          currencyFormat.format(item.value),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.inventoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categoría y ubicación en cards
                  Row(
                    children: [
                      // Categoría
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Categoría',
                          value: item.categoryName ?? 'Sin categoría',
                          icon: Icons.category_outlined,
                          color: AppTheme.categoryColor,
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Ubicación
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Ubicación',
                          value: item.locationName ?? 'Sin ubicación',
                          icon: Icons.place_outlined,
                          color: AppTheme.locationColor,
                          context: context,
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
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                      child: Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor,
                          height: 1.5,
                        ),
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
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                          height: 50,
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
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageGallery(List<String> imageUrls) {
    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
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
            ),
            // Sombra gradiente para que el texto sea más legible
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            if (imageUrls.length > 1)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${index + 1}/${imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Eliminar item?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Estás seguro de que deseas eliminar "${item.name}"? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Eliminar',
                      onPressed: () => _deleteItem(context),
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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