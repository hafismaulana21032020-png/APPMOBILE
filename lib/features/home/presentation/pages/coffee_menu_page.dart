import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../widgets/coffee_list_item_card.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';

class CoffeeMenuPage extends StatefulWidget {
  const CoffeeMenuPage({super.key});

  @override
  State<CoffeeMenuPage> createState() => _CoffeeMenuPageState();
}

class _CoffeeMenuPageState extends State<CoffeeMenuPage> {
  String? _selectedSubcategory;
  int _cartItemCount = 2;
  int _cartTotalPrice = 43000;
  int _currentNavIndex = 0;

  List<ProductModel> get _hotCoffeeProducts => breakfreeMenuItems
      .where((p) => p.category == 'kopi' && p.subcategory == 'Hot Coffee')
      .toList();

  List<ProductModel> get _iceCoffeeProducts => breakfreeMenuItems
      .where((p) => p.category == 'kopi' && p.subcategory == 'Ice Coffee')
      .toList();

  List<ProductModel> get _iceCubeProducts => breakfreeMenuItems
      .where((p) => p.category == 'kopi' && p.subcategory == 'Ice Cube')
      .toList();

  void _onAddToCart(ProductModel product) {
    setState(() {
      _cartItemCount++;
      _cartTotalPrice += product.price;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} berhasil ditambahkan!'),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onViewCart() {
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    final showHot = _selectedSubcategory == null || _selectedSubcategory == 'Hot Coffee';
    final showIce = _selectedSubcategory == null || _selectedSubcategory == 'Ice Coffee';
    final showCube = _selectedSubcategory == null || _selectedSubcategory == 'Ice Cube';

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
                  // Header Bar (Back button + Kategori: Kopi)
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.darkText),
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Kategori: Kopi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subcategory Filter Pills (Hot Coffee, Ice Coffee, Ice Cube)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: coffeeSubcategories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final subcat = coffeeSubcategories[index];
                        final isSelected = _selectedSubcategory == subcat;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSubcategory = isSelected ? null : subcat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBrown : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : AppColors.inputBorderColor,
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              subcat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.darkBrown,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ==================== SECTION: HOT COFFEE ====================
                  if (showHot) ...[
                    Row(
                      children: const [
                        Icon(Icons.coffee_rounded, size: 16, color: AppColors.primaryBrown),
                        SizedBox(width: 6),
                        Text(
                          'Hot Coffee',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._hotCoffeeProducts.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CoffeeListItemCard(
                          product: product,
                          onAddToCart: () => _onAddToCart(product),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ==================== SECTION: ICE COFFEE ====================
                  if (showIce) ...[
                    Row(
                      children: const [
                        Icon(Icons.local_drink_rounded, size: 16, color: Color(0xFF4FC3F7)),
                        SizedBox(width: 6),
                        Text(
                          'Ice Coffee',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._iceCoffeeProducts.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CoffeeListItemCard(
                          product: product,
                          onAddToCart: () => _onAddToCart(product),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ==================== SECTION: ICE CUBE COFFEE ====================
                  if (showCube) ...[
                    Row(
                      children: const [
                        Icon(Icons.ac_unit_rounded, size: 16, color: Color(0xFF4FC3F7)),
                        SizedBox(width: 6),
                        Text(
                          'Ice Cube Coffee',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._iceCubeProducts.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CoffeeListItemCard(
                          product: product,
                          onAddToCart: () => _onAddToCart(product),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Bottom padding buffer for floating cart
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Floating Cart Bar di atas Bottom Nav Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingCartBar(
                itemCount: _cartItemCount,
                totalPrice: _cartTotalPrice,
                onViewCart: _onViewCart,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentNavIndex,
        orderBadgeCount: _cartItemCount,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.cart);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.account);
          } else {
            setState(() {
              _currentNavIndex = index;
            });
          }
        },
      ),
    );
  }
}

