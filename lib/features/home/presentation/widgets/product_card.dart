import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLg),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 110,
              child: Image.asset(
                product.image.isNotEmpty ? product.image : AppAssets.coffeeBanner,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.cardBgColor,
                  child: const Center(
                    child: Icon(Icons.coffee, size: 36, color: AppColors.primaryBrown),
                  ),
                ),
              ),
            ),
          ),

          // Deskripsi & Tombol Tambah
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.tag != null
                            ? '${product.name} (${product.tag})'
                            : product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.formattedPrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Tombol + Tambah
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonYellow,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '+ Tambah',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
