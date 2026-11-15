import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_nav_helper.dart';
import '../widgets/menu_list_view.dart';

/// Standalone route page for [AppRoutes.menu] when navigated from secondary screens.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

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
                const MenuTabContent(),
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
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: 1,
            ),
          ),
        );
      },
    );
  }
}

