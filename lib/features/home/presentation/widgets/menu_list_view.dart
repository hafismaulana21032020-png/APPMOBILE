import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import 'product_order_bottom_sheet.dart';

class MenuTabContent extends StatefulWidget {
  final String initialCategory;

  const MenuTabContent({
    super.key,
    this.initialCategory = 'Semua',
  });

  @override
  State<MenuTabContent> createState() => _MenuTabContentState();
}

class _MenuTabContentState extends State<MenuTabContent> {
  static const List<String> _categories = [
    'Semua',
    'Kopi',
    'Non-Kopi',
    'Makanan',
    'Snack',
  ];

  static const List<String> _bestSellerIds = [
    'ic-3', // Breakfree Aren Latte
    'nk-s-5', // Signature Matcha
    'm-np-3', // Nasi Ayam Krispi
    'snack-2', // French Fries
  ];

  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(covariant MenuTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _bestSellerItems {
    return _bestSellerIds
        .map(
          (id) => breakfreeMenuItems.firstWhere(
            (item) => item.id == id,
            orElse: () => breakfreeMenuItems.first,
          ),
        )
        .toList();
  }

  List<ProductModel> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return breakfreeMenuItems.where((product) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  String? _detailRouteForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'kopi':
        return AppRoutes.coffeeMenu;
      case 'non-kopi':
        return AppRoutes.nonCoffee;
      case 'makanan':
        return AppRoutes.foodMenu;
      case 'snack':
        return AppRoutes.snackMenu;
      default:
        return null;
    }
  }

  void _showProductDetailSheet(ProductModel product) {
    ProductOrderBottomSheet.show(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final isAllDefaultView =
        _selectedCategory == 'Semua' && _searchQuery.trim().isEmpty;
    final filtered = _filteredItems;
    final detailRoute = _detailRouteForCategory(_selectedCategory);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BreakFree • Malang',
            style: AppTextStyles.brandSubtitle,
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftar menu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Temukan teman yang pas untuk jeda kopimu.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar ('Cari nama menu...')
          Container(
            constraints: const BoxConstraints(minHeight: 46),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: 'Cari nama menu...',
                hintStyle: AppTextStyles.inputHint,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.iconColor,
                  size: 21,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.secondaryText,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Wrapping Category Filter Chips (Semua, Kopi, Non-Kopi, Makanan, Snack)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBrown : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.inputBorderColor,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.darkBrown,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // Smooth AnimatedSwitcher when switching categories or searching
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: Column(
              key: ValueKey<String>('$_selectedCategory|$_searchQuery'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAllDefaultView) ...[
                  const Text(
                    'Menu terlaris',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Beberapa pilihan favorit untuk jedamu.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._bestSellerItems.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MenuCatalogCard(
                        product: product,
                        onTap: () => _showProductDetailSheet(product),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Semua menu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...breakfreeMenuItems
                      .where((item) => !_bestSellerIds.contains(item.id))
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MenuCatalogCard(
                            product: product,
                            onTap: () => _showProductDetailSheet(product),
                          ),
                        ),
                      ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _searchQuery.trim().isNotEmpty
                              ? 'Hasil pencarian (${filtered.length})'
                              : 'Menu $_selectedCategory',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      if (detailRoute != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, detailRoute),
                          child: const Text(
                            'Lihat lengkap',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Text(
                          'Menu tidak ditemukan',
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MenuCatalogCard(
                          product: product,
                          onTap: () => _showProductDetailSheet(product),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Padding bawah agar item terakhir tidak tertutup floating cart
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MenuCatalogCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _MenuCatalogCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle =
        product.tag != null ? '${product.name} (${product.tag})' : product.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(
                    product.image.isNotEmpty
                        ? product.image
                        : AppAssets.breakfreeArenLatte,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.cardBgColor,
                      child: const Center(
                        child: Icon(
                          Icons.coffee_rounded,
                          size: 26,
                          color: AppColors.primaryBrown,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.formattedPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

