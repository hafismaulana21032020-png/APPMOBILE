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
import '../widgets/indomie_item_card.dart';
import '../widgets/non_coffee_list_item_card.dart';
import '../widgets/product_order_bottom_sheet.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({super.key});

  @override
  State<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  String _selectedSubcategory = 'Semua';

  @override
  void initState() {
    super.initState();
    MenuService.instance.fetchMenu(force: true);
  }

  ProductModel? get _indomieGorengProduct {
    final p = breakfreeMenuItems
        .cast<ProductModel?>()
        .firstWhere((p) => p?.id == 'm-ig-1', orElse: () => null);
    return p != null ? MenuService.instance.resolveProduct(p) : null;
  }

  ProductModel? get _indomieNyemekProduct {
    final p = breakfreeMenuItems
        .cast<ProductModel?>()
        .firstWhere((p) => p?.id == 'm-in-1', orElse: () => null);
    return p != null ? MenuService.instance.resolveProduct(p) : null;
  }

  List<ProductModel> get _paketHematProducts => breakfreeMenuItems
      .where((p) => p.category == 'Makanan' && p.subcategory == 'Paket')
      .map((p) => MenuService.instance.resolveProduct(p))
      .toList();

  ProductModel? get _addonTelur {
    final p = breakfreeMenuItems
        .cast<ProductModel?>()
        .firstWhere((p) => p?.id == 'm-addon-1', orElse: () => null);
    return p != null ? MenuService.instance.resolveProduct(p) : null;
  }

  ProductModel? get _addonNasi {
    final p = breakfreeMenuItems
        .cast<ProductModel?>()
        .firstWhere((p) => p?.id == 'm-addon-2', orElse: () => null);
    return p != null ? MenuService.instance.resolveProduct(p) : null;
  }

  void _onAddToCart(ProductModel product, [String? extra, int? customPrice]) {
    ProductOrderBottomSheet.show(
      context,
      product,
      initialOption: extra,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String countText,
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
          countText,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildAddonCard({
    required String title,
    required String price,
    required VoidCallback onAdd,
    bool isAvailable = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? AppColors.inputBorderColor : const Color(0xFFD6D1C7),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFFF7F5F2) : const Color(0xFFE2DDD5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: isAvailable ? AppColors.darkBrown : const Color(0xFF8C827A),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isAvailable ? onAdd : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isAvailable ? AppColors.primaryBrown : const Color(0xFFDDD8CE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        isAvailable ? Icons.add : Icons.close_rounded,
                        size: 16,
                        color: isAvailable ? Colors.white : const Color(0xFF7A726A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                  ),
                ),
              ),
              if (!isAvailable) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: const Text(
                    'Habis',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isAvailable ? AppColors.darkBrown : const Color(0xFF8C827A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showGoreng =
        _selectedSubcategory == 'Semua' || _selectedSubcategory == 'Goreng';
    final showNyemek =
        _selectedSubcategory == 'Semua' || _selectedSubcategory == 'Nyemek';
    final showPaket =
        _selectedSubcategory == 'Semua' || _selectedSubcategory == 'Paket';
    final showAddons = _selectedSubcategory == 'Semua';

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
              // Header Bar (Back button + Kategori: Makanan)
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
                      'Kategori: Makanan',
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

              // Filter Chips (Semua, Goreng, Nyemek, Paket)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: foodSubcategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final subcat = foodSubcategories[index];
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

              // ==================== SECTION: INDOMIE GORENG ====================
              if (showGoreng && _indomieGorengProduct != null) ...[
                _buildSectionHeader(
                  title: 'Indomie Goreng',
                  countText: '1 menu',
                ),
                const SizedBox(height: 12),
                IndomieItemCard(
                  product: _indomieGorengProduct!,
                  levelOptions: const [
                    IndomieLevelOption(level: 'Ori', price: 12000),
                    IndomieLevelOption(level: 'Level 1', price: 13000),
                    IndomieLevelOption(level: 'Level 2', price: 14000),
                    IndomieLevelOption(level: 'Level 3', price: 15000),
                  ],
                  onAddToCart: (prod, opt) =>
                      _onAddToCart(prod, opt.level, opt.price),
                ),
                const SizedBox(height: 20),
              ],

              // ==================== SECTION: INDOMIE NYEMEK ====================
              if (showNyemek && _indomieNyemekProduct != null) ...[
                _buildSectionHeader(
                  title: 'Indomie Nyemek',
                  countText: '1 menu',
                ),
                const SizedBox(height: 12),
                IndomieItemCard(
                  product: _indomieNyemekProduct!,
                  levelOptions: const [
                    IndomieLevelOption(level: 'Ori', price: 16000),
                    IndomieLevelOption(level: 'Level 1', price: 17000),
                    IndomieLevelOption(level: 'Level 2', price: 18000),
                    IndomieLevelOption(level: 'Level 3', price: 19000),
                  ],
                  onAddToCart: (prod, opt) =>
                      _onAddToCart(prod, opt.level, opt.price),
                ),
                const SizedBox(height: 20),
              ],

              // ==================== SECTION: NASI & PAKET HEMAT ====================
              if (showPaket && _paketHematProducts.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Nasi & Paket Hemat',
                  countText: '${_paketHematProducts.length} pilihan',
                ),
                const SizedBox(height: 12),
                ..._paketHematProducts.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NonCoffeeListItemCard(
                      product: product,
                      onAddToCart: () => _onAddToCart(product),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ==================== SECTION: ADD-ONS ====================
              if (showAddons) ...[
                _buildSectionHeader(
                  title: 'Add-ons',
                  countText: 'Tambahan',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAddonCard(
                        title: _addonTelur?.name ?? 'Telur',
                        price: _addonTelur?.formattedPrice ?? 'Rp 3.000',
                        isAvailable: _addonTelur?.isAvailable ?? true,
                        onAdd: () {
                          if (_addonTelur != null) {
                            _onAddToCart(_addonTelur!);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAddonCard(
                        title: _addonNasi?.name ?? 'Nasi',
                        price: _addonNasi?.formattedPrice ?? 'Rp 5.000',
                        isAvailable: _addonNasi?.isAvailable ?? true,
                        onAdd: () {
                          if (_addonNasi != null) {
                            _onAddToCart(_addonNasi!);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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

