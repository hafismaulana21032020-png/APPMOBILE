import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/domain/services/favorite_service.dart';
import '../../../home/domain/services/menu_service.dart';
import '../../../home/presentation/widgets/floating_cart_bar.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../../home/presentation/widgets/non_coffee_list_item_card.dart';
import '../../../home/presentation/widgets/product_order_bottom_sheet.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    MenuService.instance.fetchMenu(force: true);
    FavoriteService.instance.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        FavoriteService.instance,
        MenuService.instance,
        CartService.instance,
      ]),
      builder: (context, _) {
        final favorites = FavoriteService.instance.resolvedFavoriteProducts;
        final isLoading = FavoriteService.instance.isLoading;
        final cartCount = CartService.instance.totalItemCount;
        final cartSubtotal = CartService.instance.subtotal;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
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
                              'Menu Favorit Saya',
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
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primaryBrown,
                            ),
                            onPressed: () {
                              MenuService.instance.fetchMenu(force: true);
                              FavoriteService.instance.fetchFavorites();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: isLoading && favorites.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryBrown,
                              ),
                            )
                          : favorites.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 72,
                                          height: 72,
                                          decoration: const BoxDecoration(
                                            color: AppColors.cardBgColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.favorite_border_rounded,
                                            size: 34,
                                            color: AppColors.primaryBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Belum Ada Menu Favorit',
                                          style: TextStyle(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Ketuk ikon hati di katalog menu untuk menyimpan kopi atau makanan favoritmu agar lebih cepat dipesan.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.secondaryText,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pushNamed(context, AppRoutes.menu),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryBrown,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 22,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Jelajahi Menu BreakFree',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    await MenuService.instance.fetchMenu(force: true);
                                    await FavoriteService.instance.fetchFavorites();
                                  },
                                  color: AppColors.primaryBrown,
                                  child: ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                      18,
                                      6,
                                      18,
                                      cartCount > 0 ? 100 : 28,
                                    ),
                                    itemCount: favorites.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, idx) {
                                      final product = favorites[idx];
                                      return NonCoffeeListItemCard(
                                        product: product,
                                        onAddToCart: () =>
                                            ProductOrderBottomSheet.show(
                                          context,
                                          product,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),

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
            currentIndex: 3,
            orderBadgeCount: cartCount,
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: 3,
            ),
          ),
        );
      },
    );
  }
}
