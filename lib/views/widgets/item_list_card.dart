// Versión completa de item_list_card.dart corregida
import 'package:flutter/material.dart';
// Añadir para SystemMouseCursors
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/item.dart';

class ItemListCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  
  const ItemListCard({
    Key? key, 
    required this.item,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = item.getImageUrlsList();
    bool hasImages = imageUrls.isNotEmpty;
    
    // Formatear valor como moneda
    final currencyFormat = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 2,
    );
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Hace toda el área clicable
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
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight( // Añadido para igualar altura
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                SizedBox(
                  width: 90,
                  height: 90,
                  child: hasImages
                      ? Image.network(
                          imageUrls.first,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          ),
                        ),
                ),
                
                // Información
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        
                        // Valor
                        Text(
                          currencyFormat.format(item.value),
                          style: const TextStyle(
                            color: AppTheme.inventoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Categoría y ubicación
                        Flexible(
                          fit: FlexFit.loose,
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.start,
                            children: [
                              if (item.categoryName != null)
                                _buildChip(
                                  item.categoryName!,
                                  Icons.category_outlined,
                                  AppTheme.categoryColor,
                                ),
                              if (item.locationName != null)
                                _buildChip(
                                  item.locationName!,
                                  Icons.place_outlined,
                                  AppTheme.locationColor,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Flecha
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.withOpacity(0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}