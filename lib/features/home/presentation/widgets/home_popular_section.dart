import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../../domain/services/menu_service.dart';
import '../controllers/home_tab_controller.dart';
import 'favorite_heart_button.dart';
import 'product_order_bottom_sheet.dart';

class HomePopularSection extends StatelessWidget {
  const HomePopularSection({super.key});

  static const List<String> _popularProductIds = [
    'ic-3', // Breakfree Aren Latte
    'ic-2', // Ice Kopi Susu
    'nk-s-5', // Signature Matcha
    'm-ig-1', // Indomie Goreng
    'snack-5', // Gyoza
    'hc-3', // Kopi Susu Sarijan
  ];

  List<ProductModel> get _popularItems {
    final List<ProductModel> items = [];
    for (final id in _popularProductIds) {
      final found = breakfreeMenuItems.where((item) => item.id == id);
      if (found.isNotEmpty) {
        items.add(MenuService.instance.resolveProduct(found.first));
      }
    }
    // Jika ada yang belum ditemukan, fallback ke item teratas
    if (items.isEmpty) {
      return breakfreeMenuItems.take(6).map((e) => MenuService.instance.resolveProduct(e)).toList();
    }
    return items;
  }

  void _onProductTap(BuildContext context, ProductModel product) {
    if (!product.isAvailable) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maaf, ${product.name} saat ini sedang habis (sold out).'),
          backgroundColor: const Color(0xFFC93B2B),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    ProductOrderBottomSheet.show(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MenuService.instance,
      builder: (context, _) {
        final popularList = _popularItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Terpopuler di BreakFree',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HomeTabController.instance.selectTab(1, category: 'Semua');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBrown,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primaryBrown,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Horizontal List Kartu Menu Populer
            SizedBox(
              height: 218,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: popularList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = popularList[index];
                  final isAvailable = product.isAvailable;

                  return Container(
                    width: 148,
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAvailable ? AppColors.borderLight : const Color(0xFFD6D1C7),
                        width: 1,
                      ),
                      boxShadow: isAvailable
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.035),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onProductTap(context, product),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto Menu & Overlay Sold Out
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 104,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ColorFiltered(
                                      colorFilter: isAvailable
                                          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                          : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                      child: Image.asset(
                                        product.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                          color: AppColors.cardBgColor,
                                          child: const Center(
                                            child: Icon(
                                              Icons.fastfood_rounded,
                                              color: AppColors.primaryBrown,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!isAvailable)
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFC93B2B),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'SOLD OUT',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: FavoriteHeartButton(
                                        product: product,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Info Menu & Tombol Tambah
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                                        height: 1.25,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AppFormatters.formatRupiah(
                                              product.price,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isAvailable ? AppColors.primaryBrown : const Color(0xFF8C827A),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isAvailable ? AppColors.primaryBrown : const Color(0xFFDDD7CF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isAvailable ? Icons.add : Icons.close_rounded,
                                            color: isAvailable ? Colors.white : const Color(0xFF8C827A),
                                            size: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
