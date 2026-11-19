import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../controllers/home_tab_controller.dart';
import '../widgets/ai_assistant_sheet.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_bundle_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_story_card.dart';
import '../widgets/home_voucher_card.dart';
import '../widgets/menu_list_view.dart';
import '../widgets/product_card.dart';
import '../widgets/product_order_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const ProductModel _bundleIceKopiSusu = ProductModel(
    id: 'bundle-ice-kopi-susu',
    name: '2 Ice Kopi Susu',
    price: 28000,
    category: 'kopi',
    subcategory: 'Paket Berdua (2 Cup)',
    description: 'Hemat Rp4.000 dari harga satuan untuk dinikmati berdua.',
    image: AppAssets.breakfreeArenLatte,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return breakfreeMenuItems.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();
  }

  void _onAddToCart(ProductModel product) {
    ProductOrderBottomSheet.show(context, product);
  }

  void _onToggleVoucher() {
    final cartService = CartService.instance;
    final isAlreadyApplied = cartService.appliedPromoCode == 'BREAK20';
    cartService.applyPromoCode(isAlreadyApplied ? null : 'BREAK20');

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAlreadyApplied
              ? 'Voucher BREAK20 dilepas'
              : 'Voucher BREAK20 diterapkan! Berlaku di keranjang.',
        ),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 2),
        action: isAlreadyApplied
            ? null
            : SnackBarAction(
                label: 'Keranjang',
                textColor: AppColors.buttonYellow,
                onPressed: _onViewCart,
              ),
      ),
    );
  }

  void _showAboutBreakFreeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tentang BreakFree Malang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BreakFree hadir di Malang sebagai tempat singgah nyaman untuk jeda kuliah, kerja, maupun nongkrong santai. Dari Kopi Susu Sarijan hingga menu hangat rumahan, semua diracik segar setiap hari.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      HomeTabController.instance.selectTab(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Jelajahi Daftar Menu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  void _onViewCart() {
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  Widget _buildHomeTab(bool isVoucherApplied) {
    final results = _searchResults;

    return SingleChildScrollView(
      key: const ValueKey<String>('home_tab_view'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          const SizedBox(height: 14),

          const HomePromoBanner(),
          const SizedBox(height: 14),

          HomeSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _searchQuery.trim().isNotEmpty
                ? Column(
                    key: ValueKey<String>('search_$_searchQuery'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil pencarian (${results.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'Tidak ada menu yang sesuai',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: results.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 230,
                          ),
                          itemBuilder: (context, index) {
                            final product = results[index];
                            return ProductCard(
                              product: product,
                              onAddToCart: () => _onAddToCart(product),
                            );
                          },
                        ),
                    ],
                  )
                : Column(
                    key: const ValueKey<String>('home_featured_content'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terpopuler di Malang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      HomeVoucherCard(
                        isApplied: isVoucherApplied,
                        onApplyTap: _onToggleVoucher,
                      ),
                      const SizedBox(height: 12),
                      HomeBundleCard(
                        onTap: () => _onAddToCart(_bundleIceKopiSusu),
                      ),
                      const SizedBox(height: 14),
                      HomeStoryCard(
                        onExploreTap: _showAboutBreakFreeSheet,
                      ),
                    ],
                  ),
          ),

          // Padding bawah agar konten tidak tertutup floating cart bar
          const SizedBox(height: 84),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        CartService.instance,
        HomeTabController.instance,
      ]),
      builder: (context, _) {
        final cartCount = CartService.instance.totalItemCount;
        final cartSubtotal = CartService.instance.subtotal;
        final isVoucherApplied =
            CartService.instance.appliedPromoCode == 'BREAK20';
        final tabController = HomeTabController.instance;
        final activeTab = tabController.currentIndex;
        final movingForward =
            tabController.currentIndex >= tabController.previousIndex;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 340),
                  reverseDuration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final isIncoming = child.key ==
                        ValueKey<String>(
                          activeTab == 1 ? 'menu_tab_view' : 'home_tab_view',
                        );
                    final offsetBegin = movingForward
                        ? (isIncoming
                            ? const Offset(0.25, 0)
                            : const Offset(-0.25, 0))
                        : (isIncoming
                            ? const Offset(-0.25, 0)
                            : const Offset(0.25, 0));
                    final slide = Tween<Offset>(
                      begin: offsetBegin,
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: activeTab == 1
                      ? const MenuTabContent(
                          key: ValueKey<String>('menu_tab_view'),
                        )
                      : _buildHomeTab(isVoucherApplied),
                ),
                if (cartCount > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FloatingCartBar(
                      itemCount: cartCount,
                      totalPrice: cartSubtotal,
                      onViewCart: _onViewCart,
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: activeTab,
            orderBadgeCount: cartCount,
            onTap: (index) {
              if (index == 0 || index == 1) {
                tabController.selectTab(index);
              } else if (index == 2) {
                showAiAssistantSheet(context);
              } else if (index == 3) {
                Navigator.pushNamed(context, AppRoutes.account);
              }
            },
          ),
        );
      },
    );
  }
}
