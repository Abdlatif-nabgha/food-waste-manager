import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import 'package:intl/intl.dart';

import '../../utils/category_icon_helper.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onConsume;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onConsume,
    required this.onDelete,
    required this.onEdit,
  });

  Color _getStatusColor() {
    switch (product.status) {
      case 'FRESH':
        return AppColors.success;
      case 'EXPIRING_SOON':
        return AppColors.warning;
      case 'EXPIRED':
        return AppColors.error;
      case 'CONSUMED':
        return AppColors.consumed;
      default:
        return AppColors.textLight;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isConsumed = product.status == 'CONSUMED';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isConsumed ? AppColors.textLighter : AppColors.textDark,
                      decoration: isConsumed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.status.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category_rounded, size: 16, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  CategoryIconHelper.formatNameWithIcon(product.categoryName),
                  style: const TextStyle(color: AppColors.textLight),
                ),
                const Spacer(),
                Icon(Icons.production_quantity_limits_rounded, size: 16, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  'Qty: ${product.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_busy_rounded, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${_formatDate(product.expiryDate)}',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isConsumed)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                if (!isConsumed)
                  TextButton.icon(
                    onPressed: onConsume,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Consume'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.success),
                  ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
