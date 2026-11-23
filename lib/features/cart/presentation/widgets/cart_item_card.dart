import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isUnavailable;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    this.isUnavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnavailable ? const Color(0xFFFFF8F8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnavailable ? const Color(0xFFEF9A9A) : AppColors.inputBorderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: isUnavailable
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.cardBgColor,
                        child: Center(
                          child: Icon(
                            item.name.toLowerCase().contains('croissant')
                                ? Icons.bakery_dining_rounded
                                : Icons.coffee_rounded,
                            size: 28,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isUnavailable)
                    Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(
                        child: Text(
                          'HABIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Detail Produk: Nama, Opsi, Harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUnavailable ? const Color(0xFFC62828) : AppColors.darkText,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (isUnavailable) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: const Text(
                          'Sold Out',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.options,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.formattedPrice,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Stepper Pill (+ / -)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Kurang (-)
                GestureDetector(
                  onTap: onDecrement,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 16,
                      color: AppColors.darkBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Jumlah
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Tombol Tambah (+) - Bulatan Cokelat (dinonaktifkan jika habis)
                GestureDetector(
                  onTap: isUnavailable ? null : onIncrement,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isUnavailable ? Colors.grey.shade400 : AppColors.darkBrown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
