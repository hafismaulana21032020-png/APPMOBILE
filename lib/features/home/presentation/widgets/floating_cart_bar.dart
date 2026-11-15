import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';

class FloatingCartBar extends StatelessWidget {
  final int itemCount;
  final int totalPrice;
  final VoidCallback onViewCart;

  const FloatingCartBar({
    super.key,
    this.itemCount = 2,
    this.totalPrice = 43000,
    required this.onViewCart,
  });

  String get _formattedTotalPrice => AppFormatters.formatRupiah(totalPrice);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info Item & Total Harga
          Expanded(
            child: Text(
              '$itemCount Item • $_formattedTotalPrice',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Lihat Keranjang
          ElevatedButton(
            onPressed: onViewCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonYellow,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Lihat Keranjang',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
