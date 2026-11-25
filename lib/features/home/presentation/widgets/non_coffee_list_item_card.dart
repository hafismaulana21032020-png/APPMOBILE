import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_model.dart';
import 'favorite_heart_button.dart';

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
    final isAvailable = product.isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable ? onAddToCart : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.65,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAvailable ? AppColors.inputBorderColor : const Color(0xFFD6D1C7),
                width: 1.0,
              ),
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColorFiltered(
                          colorFilter: isAvailable
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
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
                        if (!isAvailable)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC93B2B),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SOLD OUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(width: 12),

          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                        ),
                      ),
                    ),
                    FavoriteHeartButton(
                      product: product,
                      size: 18,
                      withBackground: false,
                    ),
                  ],
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
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              product.formattedPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                              ),
                            ),
                          ),
                          if (!isAvailable) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFFFCDD2)),
                              ),
                              child: const Text(
                                'Habis',
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
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isAvailable ? onAddToCart : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: isAvailable ? AppColors.primaryBrown : const Color(0xFFDDD8CE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAvailable ? '+ Add' : 'Sold Out',
                            style: TextStyle(
                              color: isAvailable ? Colors.white : const Color(0xFF7A726A),
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
),
);
  }
}

