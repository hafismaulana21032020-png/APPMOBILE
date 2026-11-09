import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:breakfree_app/features/home/data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../widgets/category_filter_list.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'kopi';
  String _searchQuery = '';

  int _cartItemCount = 2;
  int _cartTotalPrice = 43000;

  List<ProductModel> get _filteredProducts {
    return breakfreeMenuItems.where((product) {
      final matchesCategory =
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Utama Scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Bar (BreakFree / Malang, Indonesia)
                  const HomeHeader(),
                  const SizedBox(height: 14),

                  // Promo Banner Card (PROMO MAHASISWA / Diskon 20% Hari Ini!)
                  const HomePromoBanner(),
                  const SizedBox(height: 14),

                  // Search Bar
                  HomeSearchBar(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Category Filter List (kopi, Non-Kopi, Makanan, Snack)
                  CategoryFilterList(
                    categories: breakfreeCategories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      if (cat.toLowerCase() == 'kopi') {
                        Navigator.pushNamed(context, AppRoutes.coffeeMenu);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Judul Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.coffeeMenu),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Grid Produk 2 Kolom
                  if (_filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
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
                      itemCount: _filteredProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onAddToCart: () => _onAddToCart(product),
                        );
                      },
                    ),

                  // Padding bawah agar item paling bawah tidak tertutup floating cart
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
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.cart);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.account);
          }
        },
      ),
    );
  }
}
