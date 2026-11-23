import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../controllers/home_tab_controller.dart';
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
        items.add(found.first);
      }
    }
    // Jika ada yang belum ditemukan, fallback ke item teratas
    if (items.isEmpty) {
      return breakfreeMenuItems.take(6).toList();
    }
    return items;
  }

  void _onProductTap(BuildContext context, ProductModel product) {
    ProductOrderBottomSheet.show(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final popularList = _popularItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Terpopuler di BreakFree',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                letterSpacing: -0.3,
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

              return Container(
                width: 148,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onProductTap(context, product),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto Menu
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 104,
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
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
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
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBrown,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _onProductTap(context, product),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBrown,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 17,
                                        ),
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
  }
}
