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
    final isAvailable = product.isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable ? onAddToCart : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.65,
          child: Container(
            decoration: BoxDecoration(
              color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isAvailable ? AppColors.inputBorderColor : const Color(0xFFD6D1C7),
                width: 1.0,
              ),
              boxShadow: isAvailable
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk & Badge Sold Out
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusLg),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 110,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColorFiltered(
                          colorFilter: isAvailable
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
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
                        if (!isAvailable)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC93B2B),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'SOLD OUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.formattedPrice,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isAvailable ? AppColors.secondaryText : const Color(0xFF8C827A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (!isAvailable)
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
                            ),
                          ],
                        ),

                        // Tombol + Tambah / Habis
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: isAvailable ? onAddToCart : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAvailable
                                  ? AppColors.buttonYellow
                                  : const Color(0xFFDDD8CE),
                              disabledBackgroundColor: const Color(0xFFDDD8CE),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isAvailable ? '+ Tambah' : 'Sold Out',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? AppColors.darkBrown : const Color(0xFF7A726A),
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
          ),
        ),
      ),
    );
  }
}
