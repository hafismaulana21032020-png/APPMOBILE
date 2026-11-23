import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../../domain/services/menu_service.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_nav_helper.dart';
import '../widgets/non_coffee_list_item_card.dart';
import '../widgets/product_order_bottom_sheet.dart';

class NonCoffeeMenuPage extends StatefulWidget {
  const NonCoffeeMenuPage({super.key});

  @override
  State<NonCoffeeMenuPage> createState() => _NonCoffeeMenuPageState();
}

class _NonCoffeeMenuPageState extends State<NonCoffeeMenuPage> {
  String _selectedSubcategory = 'Semua';

  @override
  void initState() {
    super.initState();
    MenuService.instance.fetchMenu(force: true);
  }

  List<ProductModel> get _coklatProducts => breakfreeMenuItems
      .where((p) => p.category == 'Non-Kopi' && p.subcategory == 'Coklat')
      .map((p) => MenuService.instance.resolveProduct(p))
      .toList();

  List<ProductModel> get _tehBuahProducts => breakfreeMenuItems
      .where((p) => p.category == 'Non-Kopi' && p.subcategory == 'Teh & Buah')
      .map((p) => MenuService.instance.resolveProduct(p))
      .toList();

  List<ProductModel> get _signatureProducts => breakfreeMenuItems
      .where((p) => p.category == 'Non-Kopi' && p.subcategory == 'Signature')
      .map((p) => MenuService.instance.resolveProduct(p))
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
    final showCoklat =
        _selectedSubcategory == 'Semua' || _selectedSubcategory == 'Coklat';
    final showTehBuah =
        _selectedSubcategory == 'Semua' || _selectedSubcategory == 'Teh & Buah';
    final showSignature =
        _selectedSubcategory == 'Semua' || _selectedSubcategory == 'Signature';

    return AnimatedBuilder(
      animation: Listenable.merge([CartService.instance, MenuService.instance]),
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
              // Header Bar (Back button + Kategori: Non-Kopi)
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
                      'Kategori: Non-Kopi',
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

              // Filter Chips (Semua, Coklat, Teh & Buah, Signature)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: nonCoffeeSubcategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final subcat = nonCoffeeSubcategories[index];
                    final isSelected = _selectedSubcategory == subcat;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubcategory = subcat;
                        });
                      },
                      child: Container(
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
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ==================== SECTION: COKLAT & HERBAL ====================
              if (showCoklat) ...[
                _buildSectionHeader(
                  title: 'Coklat & Herbal',
                  count: _coklatProducts.length,
                ),
                const SizedBox(height: 12),
                ..._coklatProducts.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NonCoffeeListItemCard(
                      product: product,
                      onAddToCart: () => _onAddToCart(product),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ==================== SECTION: TEH & BUAH ====================
              if (showTehBuah) ...[
                _buildSectionHeader(
                  title: 'Teh & Buah',
                  count: _tehBuahProducts.length,
                ),
                const SizedBox(height: 12),
                ..._tehBuahProducts.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NonCoffeeListItemCard(
                      product: product,
                      onAddToCart: () => _onAddToCart(product),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ==================== SECTION: SIGNATURE ====================
              if (showSignature) ...[
                _buildSectionHeader(
                  title: 'Signature',
                  count: _signatureProducts.length,
                ),
                const SizedBox(height: 12),
                ..._signatureProducts.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NonCoffeeListItemCard(
                      product: product,
                      onAddToCart: () => _onAddToCart(product),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
          if (cartCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingCartBar(
                itemCount: cartCount,
                totalPrice: cartSubtotal,
                onViewCart: () => Navigator.pushNamed(context, AppRoutes.cart),
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
