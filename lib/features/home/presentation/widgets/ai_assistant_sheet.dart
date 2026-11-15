import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';

/// Displays the BreakFree AI Barista assistant recommendation bottom sheet.
void showAiAssistantSheet(BuildContext context) {
  final recommendations = <ProductModel>[
    breakfreeMenuItems.firstWhere(
      (p) => p.id == 'ic-3',
      orElse: () => breakfreeMenuItems.first,
    ),
    breakfreeMenuItems.firstWhere(
      (p) => p.id == 'nk-s-5',
      orElse: () => breakfreeMenuItems.first,
    ),
    breakfreeMenuItems.firstWhere(
      (p) => p.id == 'm-np-2',
      orElse: () => breakfreeMenuItems.first,
    ),
  ];

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBrown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asisten AI BreakFree',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'Rekomendasi menu favorit hari ini untukmu',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...recommendations.map(
                (product) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
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
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          CartService.instance.addProduct(product);
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} masuk ke keranjang belanja!',
                              ),
                              backgroundColor: AppColors.primaryBrown,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Lihat',
                                textColor: AppColors.buttonYellow,
                                onPressed: () =>
                                    Navigator.pushNamed(context, AppRoutes.cart),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBrown,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '+ Tambah',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      );
    },
  );
}

