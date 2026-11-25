import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_model.dart';
import 'favorite_heart_button.dart';

class CoffeeListItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const CoffeeListItemCard({
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.65,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isAvailable ? AppColors.inputBorderColor : const Color(0xFFD6D1C7),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gambar Thumbnail Produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: SizedBox(
                    width: 68,
                    height: 68,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColorFiltered(
                          colorFilter: isAvailable
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                          child: Image.asset(
                            product.image.isNotEmpty ? product.image : AppAssets.breakfreeArenLatte,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.cardBgColor,
                              child: const Center(
                                child: Icon(Icons.coffee, size: 28, color: AppColors.primaryBrown),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                        ),
                      ),
                    ),
                    FavoriteHeartButton(
                      product: product,
                      size: 17,
                      withBackground: false,
                    ),
                  ],
                ),
                if (product.tag != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    product.tag!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        product.formattedPrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
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
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tombol + Add / Sold Out
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: isAvailable ? onAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? AppColors.primaryBrown : const Color(0xFFDDD8CE),
                disabledBackgroundColor: const Color(0xFFDDD8CE),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isAvailable ? '+ Add' : 'Sold Out',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.white : const Color(0xFF7A726A),
                ),
              ),
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

