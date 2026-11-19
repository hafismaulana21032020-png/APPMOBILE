import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_nav_helper.dart';
import '../widgets/non_coffee_list_item_card.dart';
import '../widgets/product_order_bottom_sheet.dart';

class SnackMenuPage extends StatefulWidget {
  const SnackMenuPage({super.key});

  @override
  State<SnackMenuPage> createState() => _SnackMenuPageState();
}

class _SnackMenuPageState extends State<SnackMenuPage> {
  final String _selectedSubcategory = 'Semua';

  List<ProductModel> get _snackProducts => breakfreeMenuItems
      .where((p) => p.category.toLowerCase() == 'snack')
      .toList();

  void _onAddToCart(ProductModel product) {
    ProductOrderBottomSheet.show(context, product);
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrown,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count menu',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final cartCount = CartService.instance.totalItemCount;
        final cartSubtotal = CartService.instance.subtotal;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                    vertical: AppDimensions.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar (Back button + Kategori: Snack)
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.inputBorderColor,
                                width: 1.0,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: AppColors.darkText,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Kategori: Snack',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter Chip: Semua
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: snackSubcategories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final subcat = snackSubcategories[index];
                            final isSelected = _selectedSubcategory == subcat;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBrown
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppColors.inputBorderColor,
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                subcat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkBrown,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section Header: Camilan Favorit
                      _buildSectionHeader(
                        title: 'Camilan Favorit',
                        count: _snackProducts.length,
                      ),
                      const SizedBox(height: 12),

                      // List Snack Cards
                      ..._snackProducts.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NonCoffeeListItemCard(
                            product: product,
                            onAddToCart: () => _onAddToCart(product),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // Floating Cart Bar di atas Bottom Nav Bar
                if (cartCount > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FloatingCartBar(
                      itemCount: cartCount,
                      totalPrice: cartSubtotal,
                      onViewCart: () =>
                          Navigator.pushNamed(context, AppRoutes.cart),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: 1,
            orderBadgeCount: cartCount,
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: -1,
            ),
          ),
        );
      },
    );
  }
}

