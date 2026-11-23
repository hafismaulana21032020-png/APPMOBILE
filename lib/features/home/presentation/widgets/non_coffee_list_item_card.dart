import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_model.dart';

class NonCoffeeListItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const NonCoffeeListItemCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
          ),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Thumbnail Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.asset(
                product.image.isNotEmpty ? product.image : AppAssets.grapeFizz,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.cardBgColor,
                  child: const Center(
                    child: Icon(Icons.local_cafe_rounded, size: 28, color: AppColors.primaryBrown),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        product.formattedPrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(8),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+ Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

