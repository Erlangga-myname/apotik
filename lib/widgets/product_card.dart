import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';

/// Product display card widget
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine stock status color
    Color stockColor;
    String stockStatus;
    
    if (product.isOutOfStock) {
      stockColor = AppColors.stockOut;
      stockStatus = 'Out of Stock';
    } else if (product.isLowStock) {
      stockColor = AppColors.stockLow;
      stockStatus = 'Low Stock';
    } else {
      stockColor = AppColors.stockHigh;
      stockStatus = 'In Stock';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Product icon/placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.categoryName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatCurrency(product.price),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Stock and expiry info
              Row(
                children: [
                  // Stock status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: stockColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2, size: 14, color: stockColor),
                        const SizedBox(width: 4),
                        Text(
                          '${product.stock} - $stockStatus',
                          style: TextStyle(
                            fontSize: 12,
                            color: stockColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expiry status
                  if (product.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.error, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning, size: 14, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            'Expired',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (product.isExpiringSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.warning, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            'Expiring Soon',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        'Exp: ${DateFormatter.formatDate(product.expiryDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
}
