// views/widgets/item_list_card.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/item.dart';
import 'custom_card.dart';

class ItemListCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  
  const ItemListCard({super.key, 
    required this.item,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = item.getImageUrlsList();
    bool hasImages = imageUrls.isNotEmpty;
    
    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Si hay imágenes, mostrar la primera
          if (hasImages)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadius),
                topRight: Radius.circular(AppTheme.borderRadius),
              ),
              child: Image.network(
                imageUrls.first,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 40),
                    ),
                  );
                },
              ),
            ),
          
          // Detalles del item
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y valor
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTheme.titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '€${item.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Descripción
                if (item.description.isNotEmpty) ...[
                  Text(
                    item.description,
                    style: AppTheme.bodyStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Categoría y ubicación
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (item.categoryName != null)
                      _buildChip(
                        item.categoryName!,
                        Icons.category,
                        AppTheme.categoryColor,
                      ),
                    if (item.locationName != null)
                      _buildChip(
                        item.locationName!,
                        Icons.place,
                        AppTheme.locationColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}